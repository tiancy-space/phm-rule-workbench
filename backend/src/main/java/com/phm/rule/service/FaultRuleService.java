package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.phm.rule.common.BizException;
import com.phm.rule.common.OperatorHolder;
import com.phm.rule.dto.ExprCheckRequest;
import com.phm.rule.dto.ExprPreviewRequest;
import com.phm.rule.dto.FaultCreateRequest;
import com.phm.rule.dto.FaultSaveRequest;
import com.phm.rule.dto.RefItem;
import com.phm.rule.dto.SimulateRequest;
import com.phm.rule.entity.DisposeFlow;
import com.phm.rule.entity.DisposeFlowBind;
import com.phm.rule.entity.DisposeFlowVer;
import com.phm.rule.entity.DisposeStep;
import com.phm.rule.entity.FaultPreSkip;
import com.phm.rule.entity.FaultRule;
import com.phm.rule.entity.FaultRuleRef;
import com.phm.rule.entity.PreFilterRule;
import com.phm.rule.mapper.PreFilterRuleMapper;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleGroup;
import com.phm.rule.expression.AtomView;
import com.phm.rule.expression.ExprEngine;
import com.phm.rule.expression.ExprException;
import com.phm.rule.expression.MemoryCatalog;
import com.phm.rule.expression.ParamView;
import com.phm.rule.mapper.DisposeFlowBindMapper;
import com.phm.rule.mapper.DisposeFlowMapper;
import com.phm.rule.mapper.DisposeFlowVerMapper;
import com.phm.rule.mapper.DisposeStepMapper;
import com.phm.rule.mapper.FaultPreSkipMapper;
import com.phm.rule.mapper.FaultRuleMapper;
import com.phm.rule.mapper.FaultRuleRefMapper;
import com.phm.rule.mapper.RuleAtomMapper;
import com.phm.rule.mapper.RuleGroupMapper;
import com.phm.rule.mapper.RuleQueryMapper;
import com.phm.rule.vo.ExprPreviewVO;
import com.phm.rule.vo.FaultDetailVO;
import com.phm.rule.vo.FaultListItemVO;
import com.phm.rule.vo.SimResultVO;
import com.phm.rule.vo.StatsVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 故障规则维护。保存时校验组合式、展开零 JSON，并按修订号做乐观锁。
 * 处置等级改为「无需干预」时，若仍挂着流程则拒绝。
 */
@Service
public class FaultRuleService {

    private static final Set<String> MODES = new HashSet<String>(Arrays.asList("CONDITIONAL", "DIRECT", "DISABLED", "PENDING"));
    private static final Set<String> CZ = new HashSet<String>(Arrays.asList("CHECK", "WATCH", "NONE"));
    private static final Set<String> JK = new HashSet<String>(Arrays.asList("A", "B", "C", "D"));
    private static final Set<String> LY = new HashSet<String>(Arrays.asList("TCMS", "6A"));

    private final FaultRuleMapper faultMapper;
    private final FaultRuleRefMapper refMapper;
    private final FaultPreSkipMapper skipMapper;
    private final RuleAtomMapper atomMapper;
    private final RuleGroupMapper groupMapper;
    private final RuleQueryMapper queryMapper;
    private final DisposeFlowBindMapper bindMapper;
    private final DisposeFlowMapper flowMapper;
    private final DisposeFlowVerMapper verMapper;
    private final DisposeStepMapper stepMapper;
    private final PreFilterRuleMapper preMapper;
    private final CatalogService catalogService;
    private final ExprEngine engine = new ExprEngine();

    /**
     * @param faultMapper    故障
     * @param refMapper      引入清单
     * @param skipMapper     豁免
     * @param atomMapper     原子
     * @param groupMapper    命名组
     * @param queryMapper    自定义 SQL
     * @param bindMapper     流程绑定
     * @param flowMapper     流程
     * @param verMapper      版本
     * @param stepMapper     步骤
     * @param catalogService 目录
     */
    public FaultRuleService(FaultRuleMapper faultMapper, FaultRuleRefMapper refMapper, FaultPreSkipMapper skipMapper,
                            RuleAtomMapper atomMapper, RuleGroupMapper groupMapper, RuleQueryMapper queryMapper,
                            DisposeFlowBindMapper bindMapper, DisposeFlowMapper flowMapper,                             DisposeFlowVerMapper verMapper,
                            DisposeStepMapper stepMapper, PreFilterRuleMapper preMapper,
                            CatalogService catalogService) {
        this.faultMapper = faultMapper;
        this.refMapper = refMapper;
        this.skipMapper = skipMapper;
        this.atomMapper = atomMapper;
        this.groupMapper = groupMapper;
        this.queryMapper = queryMapper;
        this.bindMapper = bindMapper;
        this.flowMapper = flowMapper;
        this.verMapper = verMapper;
        this.stepMapper = stepMapper;
        this.preMapper = preMapper;
        this.catalogService = catalogService;
    }

    /**
     * 故障底账列表，带流程角标和豁免数量。筛选条件都可空。
     *
     * @param cx       车型
     * @param ly       来源
     * @param ruleMode 判定模式
     * @param czdj     处置等级
     * @param keyword  代码、名称或模型
     * @return 列表
     */
    public List<FaultListItemVO> list(String cx, String ly, String ruleMode, String czdj, String keyword) {
        LambdaQueryWrapper<FaultRule> q = new LambdaQueryWrapper<FaultRule>().orderByAsc(FaultRule::getCx)
                .orderByAsc(FaultRule::getLy).orderByAsc(FaultRule::getGzdm);
        if (notBlank(cx)) {
            q.eq(FaultRule::getCx, cx.trim());
        }
        if (notBlank(ly) && !"ALL".equalsIgnoreCase(ly)) {
            q.eq(FaultRule::getLy, ly.trim());
        }
        if (notBlank(ruleMode)) {
            q.eq(FaultRule::getRuleMode, ruleMode.trim());
        }
        if (notBlank(czdj)) {
            q.eq(FaultRule::getCzdj, czdj.trim());
        }
        if (notBlank(keyword)) {
            String k = keyword.trim();
            q.and(w -> w.like(FaultRule::getGzdm, k).or().like(FaultRule::getGzmc, k).or().like(FaultRule::getMxmc, k));
        }
        List<FaultRule> rows = faultMapper.selectList(q);
        Map<Long, Integer> refCounts = counts(refMapper.selectList(null), true);
        Map<Long, Integer> skipCounts = new HashMap<Long, Integer>();
        for (FaultPreSkip s : skipMapper.selectList(null)) {
            Integer c = skipCounts.get(s.getFaultRuleId());
            skipCounts.put(s.getFaultRuleId(), c == null ? 1 : c + 1);
        }
        Map<Long, DisposeFlowBind> binds = new HashMap<Long, DisposeFlowBind>();
        for (DisposeFlowBind b : bindMapper.selectList(null)) {
            binds.put(b.getFaultRuleId(), b);
        }
        Map<Long, DisposeFlow> flows = new HashMap<Long, DisposeFlow>();
        for (DisposeFlow f : flowMapper.selectList(null)) {
            flows.put(f.getId(), f);
        }
        Map<Long, Integer> steps = stepCountByFlow();
        List<FaultListItemVO> out = new ArrayList<FaultListItemVO>();
        for (FaultRule row : rows) {
            FaultListItemVO vo = new FaultListItemVO();
            vo.setId(row.getId());
            vo.setCx(row.getCx());
            vo.setLy(row.getLy());
            vo.setGzdm(row.getGzdm());
            vo.setGzmc(row.getGzmc());
            vo.setMxmc(row.getMxmc());
            vo.setJkdj(row.getJkdj());
            vo.setCzdj(row.getCzdj());
            vo.setRuleMode(row.getRuleMode());
            vo.setIsEnabled(row.getIsEnabled());
            vo.setRev(row.getRev());
            vo.setConfigNote(row.getConfigNote());
            vo.setRefCount(refCounts.containsKey(row.getId()) ? refCounts.get(row.getId()) : 0);
            vo.setSkipCount(skipCounts.containsKey(row.getId()) ? skipCounts.get(row.getId()) : 0);
            DisposeFlowBind bind = binds.get(row.getId());
            if (bind != null) {
                DisposeFlow flow = flows.get(bind.getFlowId());
                if (flow != null) {
                    vo.setFlowId(flow.getId());
                    vo.setFlowCode(flow.getFlowCode());
                    vo.setFlowName(flow.getFlowName());
                    vo.setFlowStatus(flow.getFlowStatus());
                    vo.setPubVerNo(flow.getPubVerNo());
                    vo.setIsTemplate(flow.getIsTemplate());
                    vo.setStepCount(steps.containsKey(flow.getId()) ? steps.get(flow.getId()) : 0);
                }
            }
            out.add(vo);
        }
        return out;
    }

    /**
     * @return 顶部统计
     */
    public StatsVO stats() {
        StatsVO vo = new StatsVO();
        List<FaultRule> faults = faultMapper.selectList(null);
        vo.setFaults(faults.size());
        for (FaultRule f : faults) {
            if ("CONDITIONAL".equals(f.getRuleMode())) {
                vo.setConditional(vo.getConditional() + 1);
            } else if ("DIRECT".equals(f.getRuleMode())) {
                vo.setDirect(vo.getDirect() + 1);
            } else if ("DISABLED".equals(f.getRuleMode())) {
                vo.setDisabled(vo.getDisabled() + 1);
            } else {
                vo.setPending(vo.getPending() + 1);
            }
        }
        vo.setAtoms(atomMapper.selectCount(null).intValue());
        vo.setGroups(groupMapper.selectCount(null).intValue());
        vo.setFlows(flowMapper.selectCount(null).intValue());
        vo.setEnabledPres(preMapper.selectCount(new LambdaQueryWrapper<PreFilterRule>().eq(PreFilterRule::getIsEnabled, 1)).intValue());
        return vo;
    }

    /**
     * 编辑页详情。组合式暂时不合法时仍返回基本信息，展示树为空。
     *
     * @param id 主键
     * @return 详情
     */
    public FaultDetailVO detail(Long id) {
        FaultRule fault = must(id);
        return toDetail(fault);
    }

    /**
     * 新增故障。同车型、来源、代码若曾被逻辑删除，则恢复该行。
     *
     * @param req 请求
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FaultDetailVO create(FaultCreateRequest req) {
        String cx = req.getCx().trim();
        String ly = req.getLy().trim();
        String gzdm = req.getGzdm().trim();
        if (!LY.contains(ly)) {
            throw BizException.bad("来源只能是 TCMS 或 6A");
        }
        String jk = req.getJkdj() == null || req.getJkdj().trim().isEmpty() ? "D" : req.getJkdj().trim();
        if (!JK.contains(jk)) {
            throw BizException.bad("健康等级只能是 A/B/C/D");
        }
        FaultRule old = queryMapper.selectFaultAny(cx, ly, gzdm);
        if (old != null && (old.getDelFlag() == null || old.getDelFlag() == 0)) {
            throw BizException.bad("该车型、来源、故障代码已存在");
        }
        if (old != null) {
            queryMapper.restoreFault(old.getId());
            faultMapper.update(null, new LambdaUpdateWrapper<FaultRule>()
                    .eq(FaultRule::getId, old.getId())
                    .set(FaultRule::getGzmc, req.getGzmc().trim())
                    .set(FaultRule::getMxmc, blank(req.getMxmc()))
                    .set(FaultRule::getJkdj, jk)
                    .set(FaultRule::getCzdj, "WATCH")
                    .set(FaultRule::getRuleMode, "PENDING")
                    .set(FaultRule::getIsEnabled, 0)
                    .set(FaultRule::getRuleExpr, null)
                    .set(FaultRule::getFaultRule, null)
                    .set(FaultRule::getRuleDesc, null)
                    .set(FaultRule::getRev, old.getRev() + 1)
                    .set(FaultRule::getUpdateBy, OperatorHolder.get())
                    .set(FaultRule::getUpdateTime, LocalDateTime.now()));
            queryMapper.deleteRefs(old.getId());
            queryMapper.deleteSkips(old.getId());
            return detail(old.getId());
        }
        FaultRule row = new FaultRule();
        row.setCx(cx);
        row.setLy(ly);
        row.setGzdm(gzdm);
        row.setGzmc(req.getGzmc().trim());
        row.setMxmc(blank(req.getMxmc()));
        row.setJkdj(jk);
        row.setCzdj("WATCH");
        row.setRuleMode("PENDING");
        row.setIsEnabled(0);
        row.setRev(1);
        faultMapper.insert(row);
        return detail(row.getId());
    }

    /**
     * 保存当前故障规则。
     *
     * @param id  主键
     * @param req 编辑内容
     * @return 保存后的详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FaultDetailVO save(Long id, FaultSaveRequest req) {
        FaultRule fault = must(id);
        if (!req.getRev().equals(fault.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        if (!MODES.contains(req.getRuleMode())) {
            throw BizException.bad("判定模式不正确");
        }
        if (!CZ.contains(req.getCzdj())) {
            throw BizException.bad("处置等级不正确");
        }
        if (!JK.contains(req.getJkdj())) {
            throw BizException.bad("健康等级不正确");
        }
        if ("NONE".equals(req.getCzdj())) {
            long binds = bindMapper.selectCount(new LambdaQueryWrapper<DisposeFlowBind>().eq(DisposeFlowBind::getFaultRuleId, id));
            if (binds > 0) {
                throw BizException.bad("该故障已挂处置流程，改为「无需干预」前请先在处置流程管理中删除该流程");
            }
        }
        List<ResolvedRef> resolved = resolve(req.getRefs());
        List<String> codes = new ArrayList<String>();
        for (ResolvedRef r : resolved) {
            codes.add(r.code);
        }
        String expr = req.getRuleExpr() == null ? "" : req.getRuleExpr();
        String canon = null;
        String expanded = null;
        String desc = null;
        MemoryCatalog cat = catalogService.load();
        if (expr.trim().isEmpty()) {
            if ("CONDITIONAL".equals(req.getRuleMode())) {
                throw BizException.bad("条件组合判定需要填写组合式");
            }
        } else {
            try {
                canon = engine.canonicalAlias(expr, codes);
                expanded = engine.expandAlias(expr, codes, cat);
                desc = engine.explainAlias(expr, codes, fault.getGzdm(), cat);
            } catch (ExprException ex) {
                throw BizException.bad("第 " + (ex.getPos() + 1) + " 字符：" + ex.getMessage());
            }
            if ("CONDITIONAL".equals(req.getRuleMode()) && (expanded == null || expanded.trim().isEmpty())) {
                throw BizException.bad("请先修正表达式");
            }
        }
        int enabled = ("CONDITIONAL".equals(req.getRuleMode()) || "DIRECT".equals(req.getRuleMode())) ? 1 : 0;
        int n = faultMapper.update(null, new LambdaUpdateWrapper<FaultRule>()
                .eq(FaultRule::getId, id).eq(FaultRule::getRev, req.getRev())
                .set(FaultRule::getMxmc, blank(req.getMxmc()))
                .set(FaultRule::getJkdj, req.getJkdj())
                .set(FaultRule::getCzdj, req.getCzdj())
                .set(FaultRule::getRuleMode, req.getRuleMode())
                .set(FaultRule::getRuleExpr, canon)
                .set(FaultRule::getFaultRule, expanded)
                .set(FaultRule::getRuleDesc, desc)
                .set(FaultRule::getIsEnabled, enabled)
                .set(FaultRule::getConfigNote, blank(req.getConfigNote()))
                .set(FaultRule::getRev, req.getRev() + 1)
                .set(FaultRule::getUpdateBy, OperatorHolder.get())
                .set(FaultRule::getUpdateTime, LocalDateTime.now()));
        if (n != 1) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        queryMapper.deleteRefs(id);
        int seq = 1;
        for (ResolvedRef r : resolved) {
            FaultRuleRef ref = new FaultRuleRef();
            ref.setFaultRuleId(id);
            ref.setSeqNo(seq++);
            ref.setRefType(r.type);
            ref.setAtomId(r.atomId);
            ref.setGroupId(r.groupId);
            refMapper.insert(ref);
        }
        queryMapper.deleteSkips(id);
        if (req.getSkipFilterIds() != null) {
            Set<Long> uniq = new LinkedHashSet<Long>(req.getSkipFilterIds());
            for (Long filterId : uniq) {
                if (filterId == null) {
                    continue;
                }
                if (preMapper.selectById(filterId) == null) {
                    throw BizException.bad("要豁免的前置规则不存在");
                }
                FaultPreSkip skip = new FaultPreSkip();
                skip.setFaultRuleId(id);
                skip.setFilterId(filterId);
                skipMapper.insert(skip);
            }
        }
        return detail(id);
    }

    /**
     * 逻辑删除。已绑定处置流程时不允许删。
     *
     * @param id  主键
     * @param rev 修订号
     */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id, Integer rev) {
        FaultRule fault = must(id);
        if (rev == null || !rev.equals(fault.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        long binds = bindMapper.selectCount(new LambdaQueryWrapper<DisposeFlowBind>().eq(DisposeFlowBind::getFaultRuleId, id));
        if (binds > 0) {
            throw BizException.bad("该故障已挂处置流程，请先解绑或删除流程");
        }
        faultMapper.deleteById(id);
    }

    /**
     * 组合式预览，不落库。
     *
     * @param req 组合式和引入清单
     * @return 展开结果或错误位置
     */
    public ExprPreviewVO preview(ExprPreviewRequest req) {
        ExprPreviewVO vo = new ExprPreviewVO();
        List<String> codes = new ArrayList<String>();
        if (req.getRefs() != null) {
            for (RefItem item : req.getRefs()) {
                codes.add(item.getCode());
            }
        }
        MemoryCatalog cat = catalogService.load();
        try {
            String text = req.getRuleExpr() == null ? "" : req.getRuleExpr();
            vo.setOk(true);
            vo.setCanonicalExpr(engine.canonicalAlias(text, codes));
            vo.setFaultRule(engine.expandAlias(text, codes, cat));
            vo.setRefExpr(engine.refExpr(text, codes, cat));
            vo.setRuleDesc(engine.explainAlias(text, codes, req.getGzdm() == null ? "" : req.getGzdm(), cat));
            vo.setDisplay(engine.display(text, codes, cat));
            vo.setMessage("语法校验通过");
        } catch (ExprException ex) {
            vo.setOk(false);
            vo.setPos(ex.getPos());
            vo.setMessage(ex.getMessage());
        }
        return vo;
    }

    /**
     * 零 JSON 反解析。
     *
     * @param req 表达式
     * @return 校验结果
     */
    public ExprPreviewVO check(ExprCheckRequest req) {
        ExprPreviewVO vo = new ExprPreviewVO();
        String text = req.getText() == null ? "" : req.getText();
        try {
            ExprEngine.ZeroSummary sum = engine.summarizeZero(text, catalogService.load());
            vo.setOk(true);
            vo.setCanonicalZero(sum.canonical);
            vo.setFaultRule(sum.canonical);
            vo.setCondCount(sum.count);
            vo.setFields(sum.fields);
            vo.setWindowCount(sum.windows);
            String collapsed = text.replaceAll("\\s+", " ").trim();
            vo.setSameAsExpect(req.getExpect() != null && text.trim().equals(req.getExpect().trim()));
            if (!sum.canonical.equals(collapsed)) {
                vo.setCanonicalZero(sum.canonical);
            }
            vo.setMessage("反解析通过");
        } catch (ExprException ex) {
            vo.setOk(false);
            vo.setPos(ex.getPos());
            vo.setMessage(ex.getMessage());
        }
        return vo;
    }

    /**
     * 用给定测点做一次试算，同时执行继承到的前置规则。
     *
     * @param id  故障主键
     * @param req 测点与时间窗
     * @return 命中情况
     */
    public SimResultVO simulate(Long id, SimulateRequest req) {
        FaultRule fault = must(id);
        return evalSim(fault, req.getValues(), req.getWindows());
    }

    /**
     * 搜索一组能命中或不能命中的样例值。
     *
     * @param id      故障主键
     * @param wantHit 是否要命中样例
     * @return 样例值和试算结果
     */
    public SimResultVO sample(Long id, boolean wantHit) {
        FaultRule fault = must(id);
        MemoryCatalog cat = catalogService.load();
        List<String> codes = refCodes(fault.getId());
        List<String> fields = new ArrayList<String>();
        List<AtomView> atoms = new ArrayList<AtomView>();
        if (fault.getRuleExpr() != null && !fault.getRuleExpr().trim().isEmpty()) {
            try {
                for (String code : engine.inlinedAtomCodes(fault.getRuleExpr(), codes, cat)) {
                    AtomView a = cat.find(code);
                    if (a != null) {
                        atoms.add(a);
                        if (!a.isWindow() && a.field != null && !fields.contains(a.field)) {
                            fields.add(a.field);
                        }
                    }
                }
            } catch (ExprException ignored) {
                // 表达式不合法时只给前置规则填默认值
            }
        }
        for (PreFilterRule pre : queryMapper.selectInheritedFilters(id)) {
            if (!fields.contains(pre.getParamCol())) {
                fields.add(pre.getParamCol());
            }
        }
        Map<String, List<String>> candidates = new LinkedHashMap<String, List<String>>();
        for (String field : fields) {
            candidates.put(field, candidatesOf(field, atoms, cat));
        }
        Map<String, String> values = new LinkedHashMap<String, String>();
        for (String field : fields) {
            values.put(field, defaultValue(field));
        }
        Map<String, Boolean> windows = new LinkedHashMap<String, Boolean>();
        for (AtomView a : atoms) {
            if (a.isWindow()) {
                for (String code : a.codes) {
                    windows.put(a.code + ":" + code, Boolean.FALSE);
                }
            }
        }
        SimResultVO current = evalSim(fault, values, windows);
        int seed = 41;
        for (int i = 0; i < 12000 && current.isHit() != wantHit; i++) {
            for (String field : fields) {
                List<String> cs = candidates.get(field);
                seed = seed * 1664525 + 1013904223;
                values.put(field, cs.get(Math.floorMod(seed, cs.size())));
            }
            for (String key : windows.keySet()) {
                seed = seed * 1664525 + 1013904223;
                windows.put(key, Math.floorMod(seed, 2) == 1);
            }
            current = evalSim(fault, values, windows);
        }
        current.setValues(values);
        current.setWindows(windows);
        return current;
    }

    private SimResultVO evalSim(FaultRule fault, Map<String, String> values, Map<String, Boolean> windows) {
        if (values == null) {
            values = new HashMap<String, String>();
        }
        if (windows == null) {
            windows = new HashMap<String, Boolean>();
        }
        MemoryCatalog cat = catalogService.load();
        SimResultVO vo = new SimResultVO();
        int preOk = 0;
        List<PreFilterRule> pres = queryMapper.selectInheritedFilters(fault.getId());
        for (PreFilterRule pre : pres) {
            boolean ok = engine.compare(values.get(pre.getParamCol()), pre.getCmpOp(), pre.getCmpVal());
            if (ok) {
                preOk++;
            }
            SimResultVO.Row row = new SimResultVO.Row();
            row.setKind("PRE");
            row.setCode(pre.getFilterCode());
            row.setText(pre.getFilterName() + " · " + pre.getFilterExpr());
            row.setOk(ok);
            vo.getRows().add(row);
        }
        vo.setPreTotal(pres.size());
        vo.setPreOk(preOk);
        vo.setPrePassed(preOk == pres.size());
        boolean combo = true;
        if ("DIRECT".equals(fault.getRuleMode())) {
            combo = true;
        } else if (!"CONDITIONAL".equals(fault.getRuleMode()) || fault.getRuleExpr() == null || fault.getRuleExpr().trim().isEmpty()) {
            combo = false;
        } else {
            List<String> codes = refCodes(fault.getId());
            try {
                combo = engine.evalAlias(fault.getRuleExpr(), codes, values, windows, cat);
                for (String code : engine.inlinedAtomCodes(fault.getRuleExpr(), codes, cat)) {
                    AtomView a = cat.find(code);
                    SimResultVO.Row row = new SimResultVO.Row();
                    row.setKind("ATOM");
                    row.setCode(code);
                    row.setText(engine.atomText(a, cat));
                    row.setOk(engine.evalAtom(a, values, windows, cat));
                    vo.getRows().add(row);
                }
            } catch (ExprException ex) {
                combo = false;
            }
        }
        vo.setComboPassed(combo);
        vo.setHit(vo.isPrePassed() && combo && ("CONDITIONAL".equals(fault.getRuleMode()) || "DIRECT".equals(fault.getRuleMode())));
        vo.setSummary(vo.isHit() ? "命中 · 报出故障 " + fault.getGzdm()
                : "未命中 · 前置 " + preOk + "/" + pres.size() + " 通过 · 组合判定 " + (combo ? "成立" : "不成立"));
        return vo;
    }

    private List<String> candidatesOf(String field, List<AtomView> atoms, MemoryCatalog cat) {
        LinkedHashSet<String> cs = new LinkedHashSet<String>();
        cs.add(defaultValue(field));
        ParamView p = cat.param(field);
        if (p != null && p.enumDict != null) {
            for (String part : p.enumDict.split(";")) {
                String[] kv = part.split(":", 2);
                if (kv.length == 2 && !kv[0].trim().isEmpty()) {
                    cs.add(kv[0].trim());
                }
            }
        }
        cs.add("0");
        cs.add("1");
        cs.add("-");
        cs.add("K123");
        cs.add("8100");
        for (AtomView a : atoms) {
            if (field.equals(a.field) && a.value != null) {
                cs.add(a.value.trim());
                try {
                    double n = Double.parseDouble(a.value.trim());
                    cs.add(String.valueOf((int) (n + 1)));
                    cs.add(String.valueOf((int) (n - 1)));
                } catch (NumberFormatException ignored) {
                    // 非数值目标值不推导相邻数
                }
            }
        }
        return new ArrayList<String>(cs);
    }

    private String defaultValue(String code) {
        if ("CC".equals(code)) {
            return "K123";
        }
        if ("TRAIN_STATUS".equals(code) || "IS_ZDX".equals(code) || "ZZZT_0".equals(code)) {
            return "0";
        }
        if ("YX_YBDY".equals(code)) {
            return "25000";
        }
        if (code.contains("WD")) {
            return "70";
        }
        if (code.contains("ST")) {
            return "1";
        }
        return "50";
    }

    private FaultDetailVO toDetail(FaultRule fault) {
        FaultDetailVO vo = new FaultDetailVO();
        vo.setId(fault.getId());
        vo.setCx(fault.getCx());
        vo.setLy(fault.getLy());
        vo.setGzdm(fault.getGzdm());
        vo.setGzmc(fault.getGzmc());
        vo.setMxmc(fault.getMxmc());
        vo.setJkdj(fault.getJkdj());
        vo.setCzdj(fault.getCzdj());
        vo.setRuleMode(fault.getRuleMode());
        vo.setRuleExpr(fault.getRuleExpr());
        vo.setFaultRule(fault.getFaultRule());
        vo.setRuleDesc(fault.getRuleDesc());
        vo.setIsEnabled(fault.getIsEnabled());
        vo.setRev(fault.getRev());
        vo.setConfigNote(fault.getConfigNote());
        vo.setSsxt(fault.getSsxt());
        vo.setSsbj(fault.getSsbj());
        vo.setDescription(fault.getDescription());
        vo.setVersion(fault.getVersion());
        vo.setRemark(fault.getRemark());
        MemoryCatalog cat = catalogService.load();
        List<String> codes = new ArrayList<String>();
        List<FaultRuleRef> refs = refMapper.selectList(new LambdaQueryWrapper<FaultRuleRef>()
                .eq(FaultRuleRef::getFaultRuleId, fault.getId()).orderByAsc(FaultRuleRef::getSeqNo));
        for (FaultRuleRef ref : refs) {
            FaultDetailVO.RefVO item = new FaultDetailVO.RefVO();
            item.setSeqNo(ref.getSeqNo());
            item.setAlias("A" + ref.getSeqNo());
            item.setRefType(ref.getRefType());
            if ("GROUP".equals(ref.getRefType())) {
                RuleGroup g = groupMapper.selectById(ref.getGroupId());
                if (g != null) {
                    item.setCode(g.getGroupCode());
                    item.setName(g.getGroupName());
                    item.setExpr(g.getExpandExpr());
                    item.setScopeCx(g.getScopeCx());
                    codes.add(g.getGroupCode());
                }
            } else {
                RuleAtom a = atomMapper.selectById(ref.getAtomId());
                if (a != null) {
                    item.setCode(a.getAtomCode());
                    item.setName(a.getAtomName());
                    item.setExpr(a.getAtomExpr());
                    item.setScopeCx(a.getScopeCx());
                    codes.add(a.getAtomCode());
                }
            }
            vo.getRefs().add(item);
        }
        if (fault.getRuleExpr() != null && !fault.getRuleExpr().trim().isEmpty()) {
            try {
                vo.setRefExpr(engine.refExpr(fault.getRuleExpr(), codes, cat));
                vo.setDisplay(engine.display(fault.getRuleExpr(), codes, cat));
            } catch (ExprException ignored) {
                vo.setRefExpr(null);
            }
        }
        for (FaultPreSkip skip : skipMapper.selectList(new LambdaQueryWrapper<FaultPreSkip>().eq(FaultPreSkip::getFaultRuleId, fault.getId()))) {
            PreFilterRule pre = findPre(skip.getFilterId());
            FaultDetailVO.SkipVO s = new FaultDetailVO.SkipVO();
            s.setFilterId(skip.getFilterId());
            s.setSkipReason(skip.getSkipReason());
            if (pre != null) {
                s.setFilterCode(pre.getFilterCode());
                s.setFilterName(pre.getFilterName());
            }
            vo.getSkips().add(s);
        }
        for (PreFilterRule pre : queryMapper.selectInheritedFilters(fault.getId())) {
            FaultDetailVO.PreBriefVO b = new FaultDetailVO.PreBriefVO();
            b.setId(pre.getId());
            b.setFilterCode(pre.getFilterCode());
            b.setFilterName(pre.getFilterName());
            b.setExecTiming(pre.getExecTiming());
            b.setPriority(pre.getPriority());
            b.setFilterExpr(pre.getFilterExpr());
            b.setScopeCx(pre.getScopeCx());
            b.setScopeLy(pre.getScopeLy());
            vo.getInheritedFilters().add(b);
        }
        DisposeFlowBind bind = bindMapper.selectOne(new LambdaQueryWrapper<DisposeFlowBind>().eq(DisposeFlowBind::getFaultRuleId, fault.getId()));
        if (bind != null) {
            DisposeFlow flow = flowMapper.selectById(bind.getFlowId());
            if (flow != null) {
                vo.setFlowId(flow.getId());
                vo.setFlowName(flow.getFlowName());
                vo.setFlowStatus(flow.getFlowStatus());
                vo.setPubVerNo(flow.getPubVerNo());
                vo.setIsTemplate(flow.getIsTemplate());
                Integer cnt = stepCountByFlow().get(flow.getId());
                vo.setStepCount(cnt == null ? 0 : cnt);
            }
        }
        return vo;
    }

    private PreFilterRule findPre(Long id) {
        return preMapper.selectById(id);
    }

    private List<String> refCodes(Long faultId) {
        List<String> codes = new ArrayList<String>();
        List<FaultRuleRef> refs = refMapper.selectList(new LambdaQueryWrapper<FaultRuleRef>()
                .eq(FaultRuleRef::getFaultRuleId, faultId).orderByAsc(FaultRuleRef::getSeqNo));
        for (FaultRuleRef ref : refs) {
            if ("GROUP".equals(ref.getRefType())) {
                RuleGroup g = groupMapper.selectById(ref.getGroupId());
                codes.add(g == null ? null : g.getGroupCode());
            } else {
                RuleAtom a = atomMapper.selectById(ref.getAtomId());
                codes.add(a == null ? null : a.getAtomCode());
            }
        }
        return codes;
    }

    private List<ResolvedRef> resolve(List<RefItem> items) {
        List<ResolvedRef> out = new ArrayList<ResolvedRef>();
        if (items == null) {
            return out;
        }
        for (RefItem item : items) {
            if (item == null || item.getCode() == null) {
                throw BizException.bad("引入项缺少编号");
            }
            ResolvedRef r = new ResolvedRef();
            r.code = item.getCode().trim();
            if ("GROUP".equalsIgnoreCase(item.getRefType())) {
                RuleGroup g = groupMapper.selectOne(new LambdaQueryWrapper<RuleGroup>().eq(RuleGroup::getGroupCode, r.code));
                if (g == null) {
                    throw BizException.bad("命名组不存在：" + r.code);
                }
                r.type = "GROUP";
                r.groupId = g.getId();
            } else {
                RuleAtom a = atomMapper.selectOne(new LambdaQueryWrapper<RuleAtom>().eq(RuleAtom::getAtomCode, r.code));
                if (a == null) {
                    throw BizException.bad("原子不存在：" + r.code);
                }
                r.type = "ATOM";
                r.atomId = a.getId();
            }
            out.add(r);
        }
        return out;
    }

    private Map<Long, Integer> stepCountByFlow() {
        Map<Long, DisposeFlowVer> latest = new HashMap<Long, DisposeFlowVer>();
        for (DisposeFlowVer ver : verMapper.selectList(null)) {
            DisposeFlowVer old = latest.get(ver.getFlowId());
            if (old == null || ver.getVerNo() > old.getVerNo()) {
                latest.put(ver.getFlowId(), ver);
            }
        }
        Map<Long, Integer> counts = new HashMap<Long, Integer>();
        if (latest.isEmpty()) {
            return counts;
        }
        for (DisposeStep step : stepMapper.selectList(null)) {
            for (Map.Entry<Long, DisposeFlowVer> e : latest.entrySet()) {
                if (e.getValue().getId().equals(step.getFlowVerId())) {
                    Integer c = counts.get(e.getKey());
                    counts.put(e.getKey(), c == null ? 1 : c + 1);
                }
            }
        }
        return counts;
    }

    private Map<Long, Integer> counts(List<FaultRuleRef> refs, boolean ignored) {
        Map<Long, Integer> map = new HashMap<Long, Integer>();
        for (FaultRuleRef ref : refs) {
            Integer c = map.get(ref.getFaultRuleId());
            map.put(ref.getFaultRuleId(), c == null ? 1 : c + 1);
        }
        return map;
    }

    private FaultRule must(Long id) {
        FaultRule row = faultMapper.selectById(id);
        if (row == null) {
            throw BizException.notFound("故障规则不存在");
        }
        return row;
    }

    private boolean notBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }

    private String blank(String s) {
        return s == null || s.trim().isEmpty() ? null : s.trim();
    }

    private static final class ResolvedRef {
        private String type;
        private String code;
        private Long atomId;
        private Long groupId;
    }
}
