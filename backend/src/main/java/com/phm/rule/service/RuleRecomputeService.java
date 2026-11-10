package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.phm.rule.common.BizException;
import com.phm.rule.common.OperatorHolder;
import com.phm.rule.entity.FaultRule;
import com.phm.rule.entity.FaultRuleRef;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleGroup;
import com.phm.rule.entity.RuleGroupItem;
import com.phm.rule.expression.ExprEngine;
import com.phm.rule.expression.ExprException;
import com.phm.rule.expression.MemoryCatalog;
import com.phm.rule.mapper.FaultRuleMapper;
import com.phm.rule.mapper.FaultRuleRefMapper;
import com.phm.rule.mapper.RuleAtomMapper;
import com.phm.rule.mapper.RuleGroupItemMapper;
import com.phm.rule.mapper.RuleGroupMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 原子或命名组改完之后，重算受影响的展开式和故障规则，保证引擎执行的内容和编辑器一致。
 */
@Service
public class RuleRecomputeService {

    private final CatalogService catalogService;
    private final ExprEngine engine = new ExprEngine();
    private final RuleGroupMapper groupMapper;
    private final RuleGroupItemMapper groupItemMapper;
    private final FaultRuleMapper faultMapper;
    private final FaultRuleRefMapper refMapper;
    private final RuleAtomMapper atomMapper;

    /**
     * @param catalogService  目录
     * @param groupMapper     命名组
     * @param groupItemMapper 组成员
     * @param faultMapper     故障规则
     * @param refMapper       引入清单
     * @param atomMapper      原子
     */
    public RuleRecomputeService(CatalogService catalogService, RuleGroupMapper groupMapper,
                                RuleGroupItemMapper groupItemMapper, FaultRuleMapper faultMapper,
                                FaultRuleRefMapper refMapper, RuleAtomMapper atomMapper) {
        this.catalogService = catalogService;
        this.groupMapper = groupMapper;
        this.groupItemMapper = groupItemMapper;
        this.faultMapper = faultMapper;
        this.refMapper = refMapper;
        this.atomMapper = atomMapper;
    }

    /**
     * 原子表达式变化后，重算包含它的命名组，再重算引用了该原子或这些组的故障。
     *
     * @param atomId 原子主键
     */
    public void afterAtomChanged(Long atomId) {
        List<RuleGroupItem> items = groupItemMapper.selectList(new LambdaQueryWrapper<RuleGroupItem>()
                .eq(RuleGroupItem::getAtomId, atomId));
        Set<Long> groupIds = new LinkedHashSet<Long>();
        for (RuleGroupItem item : items) {
            groupIds.add(item.getGroupId());
        }
        MemoryCatalog cat = catalogService.load();
        for (Long groupId : groupIds) {
            refreshGroup(groupId, cat);
        }
        cat = catalogService.load();
        refreshFaults(atomId, groupIds, cat);
    }

    /**
     * 命名组组合式变化后，重算引用该组的故障。组自己的展开式由保存逻辑先写好。
     *
     * @param groupId 组主键
     */
    public void afterGroupChanged(Long groupId) {
        Set<Long> groupIds = new LinkedHashSet<Long>();
        groupIds.add(groupId);
        refreshFaults(null, groupIds, catalogService.load());
    }

    private void refreshGroup(Long groupId, MemoryCatalog cat) {
        RuleGroup group = groupMapper.selectById(groupId);
        if (group == null) {
            return;
        }
        try {
            String[] compiled = engine.compileGroup(group.getGroupExpr(), cat);
            LambdaUpdateWrapper<RuleGroup> u = new LambdaUpdateWrapper<RuleGroup>();
            u.eq(RuleGroup::getId, group.getId()).eq(RuleGroup::getRev, group.getRev())
                    .set(RuleGroup::getGroupExpr, compiled[0])
                    .set(RuleGroup::getExpandExpr, compiled[1])
                    .set(RuleGroup::getGroupDesc, compiled[2])
                    .set(RuleGroup::getRev, group.getRev() + 1)
                    .set(RuleGroup::getUpdateBy, OperatorHolder.get())
                    .set(RuleGroup::getUpdateTime, LocalDateTime.now());
            if (groupMapper.update(null, u) != 1) {
                throw BizException.conflict("命名组已被他人修改，请刷新后重试");
            }
        } catch (ExprException ex) {
            throw BizException.bad("命名组 " + group.getGroupCode() + " 无法重算：" + ex.getMessage());
        }
    }

    private void refreshFaults(Long atomId, Set<Long> groupIds, MemoryCatalog cat) {
        Set<Long> faultIds = new LinkedHashSet<Long>();
        if (atomId != null) {
            List<FaultRuleRef> direct = refMapper.selectList(new LambdaQueryWrapper<FaultRuleRef>()
                    .eq(FaultRuleRef::getAtomId, atomId));
            for (FaultRuleRef ref : direct) {
                faultIds.add(ref.getFaultRuleId());
            }
        }
        if (groupIds != null && !groupIds.isEmpty()) {
            List<FaultRuleRef> via = refMapper.selectList(new LambdaQueryWrapper<FaultRuleRef>()
                    .in(FaultRuleRef::getGroupId, groupIds));
            for (FaultRuleRef ref : via) {
                faultIds.add(ref.getFaultRuleId());
            }
        }
        for (Long faultId : faultIds) {
            refreshFault(faultId, cat);
        }
    }

    private void refreshFault(Long faultId, MemoryCatalog cat) {
        FaultRule fault = faultMapper.selectById(faultId);
        if (fault == null || fault.getRuleExpr() == null || fault.getRuleExpr().trim().isEmpty()) {
            return;
        }
        List<FaultRuleRef> refs = refMapper.selectList(new LambdaQueryWrapper<FaultRuleRef>()
                .eq(FaultRuleRef::getFaultRuleId, faultId)
                .orderByAsc(FaultRuleRef::getSeqNo));
        List<String> codes = new ArrayList<String>();
        for (FaultRuleRef ref : refs) {
            if ("GROUP".equals(ref.getRefType())) {
                RuleGroup g = groupMapper.selectById(ref.getGroupId());
                codes.add(g == null ? null : g.getGroupCode());
            } else {
                codes.add(codeOfAtom(ref.getAtomId()));
            }
        }
        try {
            String expanded = engine.expandAlias(fault.getRuleExpr(), codes, cat);
            String desc = engine.explainAlias(fault.getRuleExpr(), codes, fault.getGzdm(), cat);
            String canon = engine.canonicalAlias(fault.getRuleExpr(), codes);
            LambdaUpdateWrapper<FaultRule> u = new LambdaUpdateWrapper<FaultRule>();
            u.eq(FaultRule::getId, fault.getId()).eq(FaultRule::getRev, fault.getRev())
                    .set(FaultRule::getRuleExpr, canon)
                    .set(FaultRule::getFaultRule, expanded)
                    .set(FaultRule::getRuleDesc, desc)
                    .set(FaultRule::getRev, fault.getRev() + 1)
                    .set(FaultRule::getUpdateBy, OperatorHolder.get())
                    .set(FaultRule::getUpdateTime, LocalDateTime.now());
            if (faultMapper.update(null, u) != 1) {
                throw BizException.conflict("故障规则已被他人修改，请刷新后重试");
            }
        } catch (ExprException ex) {
            throw BizException.bad("故障 " + fault.getGzdm() + " 的组合式无法随原子更新重算：" + ex.getMessage());
        }
    }

    private String codeOfAtom(Long atomId) {
        if (atomId == null) {
            return null;
        }
        RuleAtom atom = atomMapper.selectById(atomId);
        return atom == null ? null : atom.getAtomCode();
    }
}
