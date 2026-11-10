package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.phm.rule.common.BizException;
import com.phm.rule.common.OperatorHolder;
import com.phm.rule.common.Texts;
import com.phm.rule.dto.AtomSaveRequest;
import com.phm.rule.entity.DisposeBranch;
import com.phm.rule.entity.FaultRule;
import com.phm.rule.entity.FaultRuleRef;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleGroup;
import com.phm.rule.entity.RuleGroupItem;
import com.phm.rule.entity.RuleParamMeta;
import com.phm.rule.expression.AtomView;
import com.phm.rule.expression.ExprEngine;
import com.phm.rule.expression.MemoryCatalog;
import com.phm.rule.mapper.DisposeBranchMapper;
import com.phm.rule.mapper.FaultRuleMapper;
import com.phm.rule.mapper.FaultRuleRefMapper;
import com.phm.rule.mapper.RuleAtomMapper;
import com.phm.rule.mapper.RuleGroupItemMapper;
import com.phm.rule.mapper.RuleGroupMapper;
import com.phm.rule.mapper.RuleParamMetaMapper;
import com.phm.rule.mapper.RuleQueryMapper;
import com.phm.rule.vo.ReferenceVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 共享原子的增删改。保存时生成零 JSON 片段和中文名称，并同步重算引用方。
 */
@Service
public class AtomRuleService {

    private final RuleAtomMapper atomMapper;
    private final RuleParamMetaMapper paramMapper;
    private final RuleQueryMapper queryMapper;
    private final FaultRuleRefMapper refMapper;
    private final FaultRuleMapper faultMapper;
    private final RuleGroupItemMapper groupItemMapper;
    private final RuleGroupMapper groupMapper;
    private final DisposeBranchMapper branchMapper;
    private final CatalogService catalogService;
    private final RuleRecomputeService recomputeService;
    private final ExprEngine engine = new ExprEngine();

    /**
     * @param atomMapper       原子
     * @param paramMapper      参数
     * @param queryMapper      自定义 SQL
     * @param refMapper        故障引用
     * @param faultMapper      故障
     * @param groupItemMapper  组成员
     * @param groupMapper      命名组
     * @param branchMapper     流程分支
     * @param catalogService   目录
     * @param recomputeService 重算
     */
    public AtomRuleService(RuleAtomMapper atomMapper, RuleParamMetaMapper paramMapper, RuleQueryMapper queryMapper,
                           FaultRuleRefMapper refMapper, FaultRuleMapper faultMapper, RuleGroupItemMapper groupItemMapper,
                           RuleGroupMapper groupMapper, DisposeBranchMapper branchMapper, CatalogService catalogService,
                           RuleRecomputeService recomputeService) {
        this.atomMapper = atomMapper;
        this.paramMapper = paramMapper;
        this.queryMapper = queryMapper;
        this.refMapper = refMapper;
        this.faultMapper = faultMapper;
        this.groupItemMapper = groupItemMapper;
        this.groupMapper = groupMapper;
        this.branchMapper = branchMapper;
        this.catalogService = catalogService;
        this.recomputeService = recomputeService;
    }

    /**
     * 右栏原子池。scopeMode=FIT 时只留 ALL 和当前车型。
     *
     * @param keyword   名称、编码或参数
     * @param cx        当前车型
     * @param atomType  PARAM / WINDOW，空为全部
     * @param scopeMode FIT 或 ALL
     * @return 列表
     */
    public List<RuleAtom> list(String keyword, String cx, String atomType, String scopeMode) {
        LambdaQueryWrapper<RuleAtom> q = new LambdaQueryWrapper<RuleAtom>();
        if (atomType != null && !atomType.trim().isEmpty()) {
            q.eq(RuleAtom::getAtomType, atomType.trim());
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            String k = keyword.trim();
            q.and(w -> w.like(RuleAtom::getAtomCode, k).or().like(RuleAtom::getAtomName, k)
                    .or().like(RuleAtom::getParamCol, k).or().like(RuleAtom::getAtomExpr, k));
        }
        q.orderByAsc(RuleAtom::getAtomCode);
        List<RuleAtom> rows = atomMapper.selectList(q);
        if ("FIT".equalsIgnoreCase(scopeMode) && cx != null && !cx.trim().isEmpty()) {
            String model = cx.trim();
            List<RuleAtom> fit = new java.util.ArrayList<RuleAtom>();
            for (RuleAtom row : rows) {
                if (row.getScopeCx() == null || "ALL".equals(row.getScopeCx())
                        || Texts.splitComma(row.getScopeCx()).contains(model)) {
                    fit.add(row);
                }
            }
            return fit;
        }
        return rows;
    }

    /**
     * @param id 主键
     * @return 原子
     */
    public RuleAtom get(Long id) {
        RuleAtom row = atomMapper.selectById(id);
        if (row == null) {
            throw BizException.notFound("原子规则不存在");
        }
        return row;
    }

    /**
     * 直接引用、经命名组间接引用，以及流程分支引用。
     *
     * @param id 原子主键
     * @return 引用关系
     */
    public ReferenceVO references(Long id) {
        RuleAtom atom = get(id);
        ReferenceVO vo = new ReferenceVO();
        vo.setCode(atom.getAtomCode());
        vo.setName(atom.getAtomName());
        List<FaultRuleRef> direct = refMapper.selectList(new LambdaQueryWrapper<FaultRuleRef>().eq(FaultRuleRef::getAtomId, id));
        java.util.Set<Long> seen = new java.util.LinkedHashSet<Long>();
        for (FaultRuleRef ref : direct) {
            if (seen.add(ref.getFaultRuleId())) {
                addFault(vo, ref.getFaultRuleId(), "DIRECT");
            }
        }
        vo.setDirectFaults(seen.size());
        List<RuleGroupItem> items = groupItemMapper.selectList(new LambdaQueryWrapper<RuleGroupItem>().eq(RuleGroupItem::getAtomId, id));
        vo.setInGroups(items.size());
        for (RuleGroupItem item : items) {
            RuleGroup g = groupMapper.selectById(item.getGroupId());
            if (g != null) {
                vo.getGroups().add(g.getGroupCode() + " " + g.getGroupName());
                List<FaultRuleRef> via = refMapper.selectList(new LambdaQueryWrapper<FaultRuleRef>().eq(FaultRuleRef::getGroupId, g.getId()));
                for (FaultRuleRef ref : via) {
                    if (seen.add(ref.getFaultRuleId())) {
                        addFault(vo, ref.getFaultRuleId(), "GROUP");
                    }
                }
            }
        }
        long branches = branchMapper.selectCount(new LambdaQueryWrapper<DisposeBranch>().eq(DisposeBranch::getCondAtomId, id));
        vo.setInBranches((int) branches);
        return vo;
    }

    /**
     * 新建原子并生成表达式。
     *
     * @param req 请求
     * @return 新原子
     */
    @Transactional(rollbackFor = Exception.class)
    public RuleAtom create(AtomSaveRequest req) {
        RuleAtom row = new RuleAtom();
        row.setAtomCode(Texts.nextCode("R", 3, queryMapper.allAtomCodes()));
        row.setIsEnabled(1);
        row.setRev(1);
        apply(row, req);
        atomMapper.insert(row);
        return get(row.getId());
    }

    /**
     * 修改共享定义。成功后所有引用方的展开式一起更新。
     *
     * @param id  主键
     * @param req 请求
     * @return 更新后的原子
     */
    @Transactional(rollbackFor = Exception.class)
    public RuleAtom update(Long id, AtomSaveRequest req) {
        RuleAtom row = get(id);
        if (req.getRev() == null || !req.getRev().equals(row.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        apply(row, req);
        int n = atomMapper.update(null, new LambdaUpdateWrapper<RuleAtom>()
                .eq(RuleAtom::getId, id).eq(RuleAtom::getRev, req.getRev())
                .set(RuleAtom::getAtomName, row.getAtomName())
                .set(RuleAtom::getAtomType, row.getAtomType())
                .set(RuleAtom::getScopeCx, row.getScopeCx())
                .set(RuleAtom::getParamId, row.getParamId())
                .set(RuleAtom::getParamCol, row.getParamCol())
                .set(RuleAtom::getCmpOp, row.getCmpOp())
                .set(RuleAtom::getCmpVal, row.getCmpVal())
                .set(RuleAtom::getWinFn, row.getWinFn())
                .set(RuleAtom::getWinSec, row.getWinSec())
                .set(RuleAtom::getRelGzdm, row.getRelGzdm())
                .set(RuleAtom::getAtomExpr, row.getAtomExpr())
                .set(RuleAtom::getRemark, row.getRemark())
                .set(RuleAtom::getRev, req.getRev() + 1)
                .set(RuleAtom::getUpdateBy, OperatorHolder.get())
                .set(RuleAtom::getUpdateTime, LocalDateTime.now()));
        if (n != 1) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        recomputeService.afterAtomChanged(id);
        return get(id);
    }

    /**
     * 删除原子。仍被故障、命名组或分支引用时禁止。
     *
     * @param id 主键
     */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        ReferenceVO ref = references(id);
        if (ref.getDirectFaults() > 0 || ref.getInGroups() > 0 || ref.getInBranches() > 0) {
            String who = ref.getFaults().isEmpty() ? "命名组或流程分支" : ref.getFaults().get(0).getGzdm();
            throw BizException.bad("禁止删除：仍被 " + who + " 引用");
        }
        atomMapper.deleteById(id);
    }

    private void apply(RuleAtom row, AtomSaveRequest req) {
        String type = req.getAtomType() == null ? "" : req.getAtomType().trim();
        row.setScopeCx(Texts.scope(req.getScopeCx(), false));
        row.setRemark(req.getRemark() == null || req.getRemark().trim().isEmpty() ? null : req.getRemark().trim());
        MemoryCatalog cat = catalogService.load();
        if ("PARAM".equals(type)) {
            if (req.getParamCol() == null || req.getCmpOp() == null || req.getCmpVal() == null || req.getCmpVal().trim().isEmpty()) {
                throw BizException.bad("参数比较需要参数、比较符和目标值");
            }
            Texts.requireOp(req.getCmpOp());
            List<RuleParamMeta> found = paramMapper.selectList(new LambdaQueryWrapper<RuleParamMeta>()
                    .eq(RuleParamMeta::getParamCol, req.getParamCol().trim()));
            if (found.isEmpty()) {
                throw BizException.bad("参数编码不在元数据中：" + req.getParamCol());
            }
            RuleParamMeta param = found.get(0);
            row.setAtomType("PARAM");
            row.setParamId(param.getId());
            row.setParamCol(param.getParamCol());
            row.setCmpOp(req.getCmpOp());
            row.setCmpVal(req.getCmpVal().trim());
            row.setWinFn(null);
            row.setWinSec(null);
            row.setRelGzdm(null);
        } else if ("WINDOW".equals(type)) {
            if (req.getWinFn() == null || !Texts.WIN_FNS.contains(req.getWinFn())) {
                throw BizException.bad("请选择时间窗函数");
            }
            if (req.getWinSec() == null || req.getWinSec() <= 0) {
                throw BizException.bad("时间窗秒数须大于 0");
            }
            List<String> codes = Texts.splitComma(req.getRelGzdm() == null ? "" : req.getRelGzdm().replace('，', ','));
            if (codes.isEmpty()) {
                throw BizException.bad("请填写关联故障代码");
            }
            row.setAtomType("WINDOW");
            row.setParamId(null);
            row.setParamCol(null);
            row.setCmpOp(null);
            row.setCmpVal(null);
            row.setWinFn(req.getWinFn());
            row.setWinSec(req.getWinSec());
            row.setRelGzdm(Texts.join(codes));
        } else {
            throw BizException.bad("原子类型只能是 PARAM 或 WINDOW");
        }
        AtomView view = catalogService.toAtom(row);
        if (req.getAtomName() == null || req.getAtomName().trim().isEmpty()) {
            row.setAtomName(engine.atomText(view, cat));
        } else {
            row.setAtomName(req.getAtomName().trim());
        }
        view.name = row.getAtomName();
        row.setAtomExpr(engine.atomExpr(view, cat));
    }

    private void addFault(ReferenceVO vo, Long faultId, String via) {
        FaultRule f = faultMapper.selectById(faultId);
        if (f == null) {
            return;
        }
        ReferenceVO.FaultBrief b = new ReferenceVO.FaultBrief();
        b.setId(f.getId());
        b.setCx(f.getCx());
        b.setLy(f.getLy());
        b.setGzdm(f.getGzdm());
        b.setGzmc(f.getGzmc());
        b.setVia(via);
        vo.getFaults().add(b);
    }
}
