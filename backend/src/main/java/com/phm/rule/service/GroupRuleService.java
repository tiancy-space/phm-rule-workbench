package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.phm.rule.common.BizException;
import com.phm.rule.common.OperatorHolder;
import com.phm.rule.common.Texts;
import com.phm.rule.dto.GroupPreviewRequest;
import com.phm.rule.dto.GroupSaveRequest;
import com.phm.rule.entity.DisposeBranch;
import com.phm.rule.entity.FaultRule;
import com.phm.rule.entity.FaultRuleRef;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleGroup;
import com.phm.rule.entity.RuleGroupItem;
import com.phm.rule.expression.ExprAst;
import com.phm.rule.expression.ExprEngine;
import com.phm.rule.expression.ExprException;
import com.phm.rule.expression.MemoryCatalog;
import com.phm.rule.mapper.DisposeBranchMapper;
import com.phm.rule.mapper.FaultRuleMapper;
import com.phm.rule.mapper.FaultRuleRefMapper;
import com.phm.rule.mapper.RuleAtomMapper;
import com.phm.rule.mapper.RuleGroupMapper;
import com.phm.rule.mapper.RuleGroupItemMapper;
import com.phm.rule.mapper.RuleQueryMapper;
import com.phm.rule.vo.ExprPreviewVO;
import com.phm.rule.vo.ReferenceVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 命名条件组。组内只能引用原子，展开式和现场说法由表达式引擎生成。
 */
@Service
public class GroupRuleService {

    private final RuleGroupMapper groupMapper;
    private final RuleGroupItemMapper itemMapper;
    private final RuleAtomMapper atomMapper;
    private final RuleQueryMapper queryMapper;
    private final FaultRuleRefMapper refMapper;
    private final FaultRuleMapper faultMapper;
    private final DisposeBranchMapper branchMapper;
    private final CatalogService catalogService;
    private final RuleRecomputeService recomputeService;
    private final ExprEngine engine = new ExprEngine();

    /**
     * @param groupMapper      组
     * @param itemMapper       成员
     * @param atomMapper       原子
     * @param queryMapper      自定义 SQL
     * @param refMapper        故障引用
     * @param faultMapper      故障
     * @param branchMapper     分支
     * @param catalogService   目录
     * @param recomputeService 重算故障展开式
     */
    public GroupRuleService(RuleGroupMapper groupMapper, RuleGroupItemMapper itemMapper, RuleAtomMapper atomMapper,
                            RuleQueryMapper queryMapper, FaultRuleRefMapper refMapper, FaultRuleMapper faultMapper,
                            DisposeBranchMapper branchMapper, CatalogService catalogService,
                            RuleRecomputeService recomputeService) {
        this.groupMapper = groupMapper;
        this.itemMapper = itemMapper;
        this.atomMapper = atomMapper;
        this.queryMapper = queryMapper;
        this.refMapper = refMapper;
        this.faultMapper = faultMapper;
        this.branchMapper = branchMapper;
        this.catalogService = catalogService;
        this.recomputeService = recomputeService;
    }

    /**
     * @param keyword 名称或编号
     * @param cx      适配车型，空表示全部
     * @return 列表
     */
    public List<RuleGroup> list(String keyword, String cx) {
        LambdaQueryWrapper<RuleGroup> q = new LambdaQueryWrapper<RuleGroup>().orderByAsc(RuleGroup::getGroupCode);
        if (keyword != null && !keyword.trim().isEmpty()) {
            String k = keyword.trim();
            q.and(w -> w.like(RuleGroup::getGroupCode, k).or().like(RuleGroup::getGroupName, k)
                    .or().like(RuleGroup::getGroupExpr, k));
        }
        List<RuleGroup> rows = groupMapper.selectList(q);
        if (cx == null || cx.trim().isEmpty()) {
            return rows;
        }
        String model = cx.trim();
        List<RuleGroup> fit = new ArrayList<RuleGroup>();
        for (RuleGroup row : rows) {
            if ("ALL".equals(row.getScopeCx()) || Texts.splitComma(row.getScopeCx()).contains(model)) {
                fit.add(row);
            }
        }
        return fit;
    }

    /**
     * @param id 主键
     * @return 组
     */
    public RuleGroup get(Long id) {
        RuleGroup row = groupMapper.selectById(id);
        if (row == null) {
            throw BizException.notFound("命名条件组不存在");
        }
        return row;
    }

    /**
     * 编辑弹窗里的实时预览，不落库。
     *
     * @param req 组合式
     * @return 规范写法、展开式和中文
     */
    public ExprPreviewVO preview(GroupPreviewRequest req) {
        ExprPreviewVO vo = new ExprPreviewVO();
        try {
            String[] compiled = engine.compileGroup(req.getGroupExpr(), catalogService.load());
            vo.setOk(true);
            vo.setCanonicalExpr(compiled[0]);
            vo.setFaultRule(compiled[1]);
            vo.setRuleDesc(compiled[2]);
            vo.setMessage("组合式有效");
        } catch (ExprException ex) {
            vo.setOk(false);
            vo.setPos(ex.getPos());
            vo.setMessage(ex.getMessage());
        }
        return vo;
    }

    /**
     * @param req 请求
     * @return 新建的组
     */
    @Transactional(rollbackFor = Exception.class)
    public RuleGroup create(GroupSaveRequest req) {
        checkName(req.getGroupName(), 0L);
        RuleGroup row = new RuleGroup();
        row.setGroupCode(Texts.nextCode("G", 3, queryMapper.allGroupCodes()));
        row.setIsEnabled(1);
        row.setRev(1);
        fill(row, req);
        groupMapper.insert(row);
        rebuildItems(row);
        return get(row.getId());
    }

    /**
     * 修改组。引用该组的故障会重算展开式。
     *
     * @param id  主键
     * @param req 请求
     * @return 更新后的组
     */
    @Transactional(rollbackFor = Exception.class)
    public RuleGroup update(Long id, GroupSaveRequest req) {
        RuleGroup row = get(id);
        if (req.getRev() == null || !req.getRev().equals(row.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        checkName(req.getGroupName(), id);
        fill(row, req);
        int n = groupMapper.update(null, new LambdaUpdateWrapper<RuleGroup>()
                .eq(RuleGroup::getId, id).eq(RuleGroup::getRev, req.getRev())
                .set(RuleGroup::getGroupName, row.getGroupName())
                .set(RuleGroup::getScopeCx, row.getScopeCx())
                .set(RuleGroup::getGroupExpr, row.getGroupExpr())
                .set(RuleGroup::getExpandExpr, row.getExpandExpr())
                .set(RuleGroup::getGroupDesc, row.getGroupDesc())
                .set(RuleGroup::getRemark, row.getRemark())
                .set(RuleGroup::getRev, req.getRev() + 1)
                .set(RuleGroup::getUpdateBy, OperatorHolder.get())
                .set(RuleGroup::getUpdateTime, LocalDateTime.now()));
        if (n != 1) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        rebuildItems(get(id));
        recomputeService.afterGroupChanged(id);
        return get(id);
    }

    /**
     * 仍被故障或分支引用时禁止删除。
     *
     * @param id 主键
     */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        ReferenceVO ref = references(id);
        if (!ref.getFaults().isEmpty() || ref.getInBranches() > 0) {
            String who = ref.getFaults().isEmpty() ? "流程分支" : ref.getFaults().get(0).getGzdm();
            throw BizException.bad("禁止删除：仍被 " + who + " 引用");
        }
        queryMapper.deleteGroupItems(id);
        groupMapper.deleteById(id);
    }

    /**
     * @param id 组主键
     * @return 引用关系
     */
    public ReferenceVO references(Long id) {
        RuleGroup group = get(id);
        ReferenceVO vo = new ReferenceVO();
        vo.setCode(group.getGroupCode());
        vo.setName(group.getGroupName());
        List<FaultRuleRef> refs = refMapper.selectList(new LambdaQueryWrapper<FaultRuleRef>().eq(FaultRuleRef::getGroupId, id));
        Set<Long> seen = new LinkedHashSet<Long>();
        for (FaultRuleRef ref : refs) {
            if (seen.add(ref.getFaultRuleId())) {
                FaultRule f = faultMapper.selectById(ref.getFaultRuleId());
                if (f == null) {
                    continue;
                }
                ReferenceVO.FaultBrief b = new ReferenceVO.FaultBrief();
                b.setId(f.getId());
                b.setCx(f.getCx());
                b.setLy(f.getLy());
                b.setGzdm(f.getGzdm());
                b.setGzmc(f.getGzmc());
                b.setVia("DIRECT");
                vo.getFaults().add(b);
            }
        }
        vo.setDirectFaults(vo.getFaults().size());
        long branches = branchMapper.selectCount(new LambdaQueryWrapper<DisposeBranch>().eq(DisposeBranch::getCondGroupId, id));
        vo.setInBranches((int) branches);
        return vo;
    }

    private void fill(RuleGroup row, GroupSaveRequest req) {
        String name = req.getGroupName().trim();
        if (name.matches(".*[&|()].*")) {
            throw BizException.bad("组名称不能包含 & | ( )");
        }
        MemoryCatalog cat = catalogService.load();
        try {
            String[] compiled = engine.compileGroup(req.getGroupExpr(), cat);
            row.setGroupName(name);
            row.setScopeCx(Texts.scope(req.getScopeCx(), false));
            row.setGroupExpr(compiled[0]);
            row.setExpandExpr(compiled[1]);
            row.setGroupDesc(compiled[2]);
            row.setRemark(req.getRemark() == null || req.getRemark().trim().isEmpty() ? null : req.getRemark().trim());
        } catch (ExprException ex) {
            throw BizException.bad("第 " + (ex.getPos() + 1) + " 字符：" + ex.getMessage());
        }
    }

    private void checkName(String name, Long excludeId) {
        if (queryMapper.countGroupName(name.trim(), excludeId == null ? 0L : excludeId) > 0) {
            throw BizException.bad("组名称已存在");
        }
    }

    private void rebuildItems(RuleGroup row) {
        queryMapper.deleteGroupItems(row.getId());
        MemoryCatalog cat = catalogService.load();
        ExprAst ast = engine.logic().parseGroup(row.getGroupExpr(), cat.atomCodes());
        List<String> codes = new ArrayList<String>();
        collect(ast, codes);
        int seq = 1;
        for (String code : codes) {
            RuleAtom atom = atomMapper.selectOne(new LambdaQueryWrapper<RuleAtom>().eq(RuleAtom::getAtomCode, code));
            if (atom == null) {
                throw BizException.bad("原子库中不存在 " + code);
            }
            RuleGroupItem item = new RuleGroupItem();
            item.setGroupId(row.getId());
            item.setAtomId(atom.getId());
            item.setSeqNo(seq++);
            itemMapper.insert(item);
        }
    }

    private void collect(ExprAst ast, List<String> codes) {
        if (ast.isLeaf()) {
            if (ast.getRefCode() != null && !codes.contains(ast.getRefCode())) {
                codes.add(ast.getRefCode());
            }
            return;
        }
        for (ExprAst c : ast.getChildren()) {
            collect(c, codes);
        }
    }
}
