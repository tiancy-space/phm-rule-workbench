package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.phm.rule.common.BizException;
import com.phm.rule.entity.DisposeBranch;
import com.phm.rule.entity.DisposeCard;
import com.phm.rule.entity.DisposeFlowBind;
import com.phm.rule.entity.DisposeStep;
import com.phm.rule.entity.FaultRule;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleGroup;
import com.phm.rule.entity.RuleParamMeta;
import com.phm.rule.entity.SimEvent;
import com.phm.rule.entity.SimEventAnswer;
import com.phm.rule.entity.SimEventPoint;
import com.phm.rule.expression.AtomView;
import com.phm.rule.expression.ExprEngine;
import com.phm.rule.expression.MemoryCatalog;
import com.phm.rule.mapper.DisposeBranchMapper;
import com.phm.rule.mapper.DisposeCardMapper;
import com.phm.rule.mapper.DisposeFlowBindMapper;
import com.phm.rule.mapper.DisposeStepMapper;
import com.phm.rule.mapper.FaultRuleMapper;
import com.phm.rule.mapper.RuleAtomMapper;
import com.phm.rule.mapper.RuleGroupMapper;
import com.phm.rule.mapper.RuleParamMetaMapper;
import com.phm.rule.mapper.SimEventAnswerMapper;
import com.phm.rule.mapper.SimEventMapper;
import com.phm.rule.mapper.SimEventPointMapper;
import com.phm.rule.vo.TrialVO;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 历史故障试跑。用模拟事件的曲线、状态和关联故障，计算数据卡统计和判断步骤的系统预判。
 * 求值规则与原型 cardData / preJudge 一致，越限时长按 2 秒一个采样点估算。
 */
@Service
public class TrialService {

    private static final DateTimeFormatter TS = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private final SimEventMapper eventMapper;
    private final SimEventPointMapper pointMapper;
    private final SimEventAnswerMapper answerMapper;
    private final FaultRuleMapper faultMapper;
    private final DisposeFlowBindMapper bindMapper;
    private final DisposeStepMapper stepMapper;
    private final DisposeCardMapper cardMapper;
    private final DisposeBranchMapper branchMapper;
    private final RuleParamMetaMapper paramMapper;
    private final RuleAtomMapper atomMapper;
    private final RuleGroupMapper groupMapper;
    private final FlowService flowService;
    private final CatalogService catalogService;
    private final ExprEngine engine = new ExprEngine();

    /**
     * @param eventMapper    事件
     * @param pointMapper    数据点
     * @param answerMapper   预置答案
     * @param faultMapper    故障
     * @param bindMapper     绑定
     * @param stepMapper     步骤
     * @param cardMapper     数据卡
     * @param branchMapper   出口
     * @param paramMapper    参数
     * @param flowService    取正在编辑的流程版本
     * @param catalogService 目录
     */
    public TrialService(SimEventMapper eventMapper, SimEventPointMapper pointMapper, SimEventAnswerMapper answerMapper,
                        FaultRuleMapper faultMapper, DisposeFlowBindMapper bindMapper, DisposeStepMapper stepMapper,
                        DisposeCardMapper cardMapper, DisposeBranchMapper branchMapper, RuleParamMetaMapper paramMapper,
                        RuleAtomMapper atomMapper, RuleGroupMapper groupMapper,
                        FlowService flowService, CatalogService catalogService) {
        this.eventMapper = eventMapper;
        this.pointMapper = pointMapper;
        this.answerMapper = answerMapper;
        this.faultMapper = faultMapper;
        this.bindMapper = bindMapper;
        this.stepMapper = stepMapper;
        this.cardMapper = cardMapper;
        this.branchMapper = branchMapper;
        this.paramMapper = paramMapper;
        this.atomMapper = atomMapper;
        this.groupMapper = groupMapper;
        this.flowService = flowService;
        this.catalogService = catalogService;
    }

    /**
     * 某故障的预置试跑事件。
     *
     * @param faultId 故障主键
     * @return 事件列表，不含曲线点
     */
    public List<TrialVO> list(Long faultId) {
        List<SimEvent> events = eventMapper.selectList(new LambdaQueryWrapper<SimEvent>()
                .eq(faultId != null, SimEvent::getFaultRuleId, faultId)
                .orderByAsc(SimEvent::getEventCode));
        List<TrialVO> out = new ArrayList<TrialVO>();
        for (SimEvent event : events) {
            out.add(brief(event));
        }
        return out;
    }

    /**
     * 事件详情，带曲线、状态、故障点和预置答案。
     *
     * @param id 事件主键
     * @return 详情
     */
    public TrialVO detail(Long id) {
        SimEvent event = must(id);
        TrialVO vo = brief(event);
        List<SimEventPoint> points = pointMapper.selectList(new LambdaQueryWrapper<SimEventPoint>()
                .eq(SimEventPoint::getEventId, id).orderByAsc(SimEventPoint::getOffsetSec));
        for (SimEventPoint p : points) {
            if ("SERIES".equals(p.getPointType()) && p.getNumVal() != null) {
                List<double[]> ser = vo.getSeries().get(p.getObjCode());
                if (ser == null) {
                    ser = new ArrayList<double[]>();
                    vo.getSeries().put(p.getObjCode(), ser);
                }
                ser.add(new double[]{p.getOffsetSec(), p.getNumVal().doubleValue()});
            } else if ("STATE".equals(p.getPointType())) {
                List<TrialVO.StatePoint> ser = vo.getStates().get(p.getObjCode());
                if (ser == null) {
                    ser = new ArrayList<TrialVO.StatePoint>();
                    vo.getStates().put(p.getObjCode(), ser);
                }
                TrialVO.StatePoint sp = new TrialVO.StatePoint();
                sp.setT(p.getOffsetSec());
                sp.setVal(p.getTxtVal());
                ser.add(sp);
            } else if ("FAULT".equals(p.getPointType())) {
                TrialVO.FaultHit hit = new TrialVO.FaultHit();
                hit.setCode(p.getObjCode());
                hit.setT(p.getOffsetSec());
                vo.getFaults().add(hit);
            }
        }
        for (SimEventAnswer a : answerMapper.selectList(new LambdaQueryWrapper<SimEventAnswer>().eq(SimEventAnswer::getEventId, id))) {
            vo.getAnswers().put(a.getStepCode(), a.getAnswerLabel());
        }
        return vo;
    }

    /**
     * 计算某一步在该事件下的数据卡和系统预判。
     *
     * @param eventId 事件
     * @param stepId  步骤，属于该故障当前编辑中的流程
     * @return 统计和预判
     */
    public TrialVO.StepEval evaluate(Long eventId, Long stepId) {
        TrialVO event = detail(eventId);
        DisposeStep step = stepMapper.selectById(stepId);
        if (step == null) {
            throw BizException.notFound("步骤不存在");
        }
        DisposeFlowBind bind = bindMapper.selectOne(new LambdaQueryWrapper<DisposeFlowBind>()
                .eq(DisposeFlowBind::getFaultRuleId, event.getFaultRuleId()));
        if (bind != null) {
            if (!flowService.workingVersion(bind.getFlowId()).getId().equals(step.getFlowVerId())) {
                throw BizException.bad("步骤不属于当前正在编辑的流程版本，请刷新后再试");
            }
        }
        TrialVO.StepEval eval = new TrialVO.StepEval();
        eval.setStepId(step.getId());
        eval.setStepCode(step.getStepCode());
        eval.setStepType(step.getStepType());
        eval.setRecordedAnswer(event.getAnswers().get(step.getStepCode()));
        List<DisposeCard> cards = cardMapper.selectList(new LambdaQueryWrapper<DisposeCard>()
                .eq(DisposeCard::getStepId, stepId).orderByAsc(DisposeCard::getSeqNo));
        Map<Long, CardStat> stats = new HashMap<Long, CardStat>();
        for (DisposeCard card : cards) {
            CardStat stat = compute(card, event);
            stats.put(card.getId(), stat);
            eval.getCards().add(stat.view);
        }
        if ("JUDGE".equals(step.getStepType())) {
            fillPrejudge(step, event, stats, eval);
        }
        return eval;
    }

    private void fillPrejudge(DisposeStep step, TrialVO event, Map<Long, CardStat> stats, TrialVO.StepEval eval) {
        MemoryCatalog cat = catalogService.load();
        Map<String, String> values = t0Values(event);
        Map<String, Boolean> windows = windowHits(event, cat);
        List<DisposeBranch> branches = branchMapper.selectList(new LambdaQueryWrapper<DisposeBranch>()
                .eq(DisposeBranch::getStepId, step.getId()).orderByAsc(DisposeBranch::getSeqNo));
        List<String> why = new ArrayList<String>();
        boolean auto = false;
        for (DisposeBranch b : branches) {
            String src = b.getCondSrc() == null ? "NONE" : b.getCondSrc();
            if ("NONE".equals(src)) {
                continue;
            }
            if ("ELSE".equals(src)) {
                if (auto) {
                    eval.setPrejudgeLabel(b.getBranchLabel());
                    eval.setPrejudgeReason(join(why, "；") + "，走「" + b.getBranchLabel() + "」");
                    return;
                }
                continue;
            }
            auto = true;
            boolean ok = false;
            String text;
            if ("CARD".equals(src)) {
                CardStat st = stats.get(b.getCondCardId());
                Double raw = st == null ? null : st.raw.get(b.getCondStat());
                Double cmpVal = raw == null ? null : Math.round(raw * 10.0) / 10.0;
                ok = cmpVal != null && cardCmp(cmpVal, b.getCondOp(), b.getCondVal());
                String shown = st == null ? "—" : st.view.getStats().get(b.getCondStat());
                String name = st == null ? "" : (st.view.getParamName() == null ? "关联故障" : st.view.getParamName());
                text = name + " " + b.getCondStat() + " = " + (shown == null ? "—" : shown) + "，"
                        + (ok ? "满足" : "不满足") + " " + b.getCondOp() + " " + b.getCondVal();
            } else {
                AtomView atom = "GROUP".equals(src) ? groupView(b.getCondGroupId(), cat) : atomView(b.getCondAtomId(), cat);
                ok = engine.evalAtom(atom, values, windows, cat);
                String title = atom != null && atom.isGroup() ? "命名组「" + atom.name + "」" : engine.atomText(atom, cat);
                text = title + " → " + (ok ? "成立" : "不成立");
            }
            why.add(text);
            if (ok) {
                eval.setPrejudgeLabel(b.getBranchLabel());
                eval.setPrejudgeReason(text + "，走「" + b.getBranchLabel() + "」");
                return;
            }
        }
        if (auto) {
            eval.setPrejudgeReason(join(why, "；") + "，无分支成立，需专家判断");
        }
    }

    private CardStat compute(DisposeCard card, TrialVO event) {
        CardStat stat = new CardStat();
        TrialVO.CardEval view = new TrialVO.CardEval();
        stat.view = view;
        view.setCardId(card.getId());
        view.setCardCode(card.getCardCode());
        view.setCardKind(card.getCardKind());
        view.setParamCol(card.getParamCol());
        view.setLimitOp(card.getLimitOp());
        view.setLimitVal(card.getLimitVal());
        view.setTargetVal(card.getTargetVal());
        RuleParamMeta meta = card.getParamId() == null ? null : paramMapper.selectById(card.getParamId());
        if (meta != null) {
            view.setParamName(meta.getParamName());
            view.setUnit(meta.getUnit());
            view.setEnumDict(meta.getEnumDict());
        }
        int lo = -safe(card.getWinPreSec());
        int hi = safe(card.getWinPostSec());
        if ("NUM".equals(card.getCardKind())) {
            List<double[]> pts = new ArrayList<double[]>();
            List<double[]> all = event.getSeries().get(card.getParamCol());
            if (all != null) {
                for (double[] p : all) {
                    if (p[0] >= lo && p[0] <= hi) {
                        pts.add(p);
                    }
                }
            }
            if (pts.isEmpty()) {
                view.setNone(true);
                return stat;
            }
            view.setPoints(pts);
            double[] vs = new double[pts.size()];
            for (int i = 0; i < pts.size(); i++) {
                vs[i] = pts.get(i)[1];
            }
            putNum(stat, "T0值", nearest(pts, 0), meta, false);
            putNum(stat, "最大", max(vs), meta, false);
            putNum(stat, "最小", min(vs), meta, false);
            putNum(stat, "平均", avg(vs), meta, false);
            putNum(stat, "首值", vs[0], meta, false);
            putNum(stat, "末值", vs[vs.length - 1], meta, false);
            putNum(stat, "变化量", vs[vs.length - 1] - vs[0], meta, false);
            if (card.getLimitVal() != null && !card.getLimitVal().trim().isEmpty()) {
                int n = 0;
                for (double[] p : pts) {
                    if (engine.compare(trimNum(p[1]), card.getLimitOp(), card.getLimitVal())) {
                        n++;
                    }
                }
                putNum(stat, "越限时长", n * 2.0, meta, true);
            }
            return stat;
        }
        if ("STATE".equals(card.getCardKind())) {
            List<TrialVO.StatePoint> ch = event.getStates().get(card.getParamCol());
            if (ch == null || ch.isEmpty()) {
                view.setNone(true);
                return stat;
            }
            Collections.sort(ch, new Comparator<TrialVO.StatePoint>() {
                public int compare(TrialVO.StatePoint a, TrialVO.StatePoint b) {
                    return Integer.compare(a.getT(), b.getT());
                }
            });
            String t0 = stateAt(ch, 0);
            stat.raw.put("T0值", t0 == null ? null : parseMaybe(t0));
            view.getStats().put("T0值", enumText(meta, t0));
            int changes = 0;
            for (TrialVO.StatePoint p : ch) {
                if (p.getT() > lo && p.getT() <= hi) {
                    changes++;
                    view.getChanges().add("T0" + (p.getT() >= 0 ? "+" : "") + p.getT() + "s → " + p.getVal());
                }
            }
            putNum(stat, "变位次数", changes, meta, false);
            int occ = 0;
            for (int t = lo; t < hi; t++) {
                if (String.valueOf(card.getTargetVal()).equals(String.valueOf(stateAt(ch, t)))) {
                    occ++;
                }
            }
            putNum(stat, "占用时长", occ, meta, true);
            stat.raw.put("是否出现过", occ > 0 ? 1.0 : 0.0);
            view.getStats().put("是否出现过", occ > 0 ? "是" : "否");
            return stat;
        }
        List<String> codes = new ArrayList<String>();
        if (card.getRelGzdm() != null) {
            for (String c : card.getRelGzdm().split("[,，\\s]+")) {
                if (!c.trim().isEmpty()) {
                    codes.add(c.trim());
                }
            }
        }
        int hits = 0;
        int after = 0;
        for (TrialVO.FaultHit f : event.getFaults()) {
            if (codes.contains(f.getCode()) && f.getT() >= lo && f.getT() <= hi) {
                hits++;
                view.getHits().add(f.getCode() + " @ T0" + (f.getT() >= 0 ? "+" : "") + f.getT() + "s");
                if (f.getT() > 0) {
                    after++;
                }
            }
        }
        putNum(stat, "出现次数", hits, null, false);
        putNum(stat, "T0后再次出现", after, null, false);
        return stat;
    }

    private void putNum(CardStat stat, String name, double value, RuleParamMeta meta, boolean seconds) {
        stat.raw.put(name, value);
        String unit = seconds ? " s" : (name.contains("次数") || "T0后再次出现".equals(name) ? " 次"
                : (meta != null && meta.getUnit() != null && !meta.getUnit().isEmpty() ? " " + meta.getUnit() : ""));
        if ("变位次数".equals(name) || "出现次数".equals(name) || "T0后再次出现".equals(name)) {
            unit = " 次";
        }
        if ("越限时长".equals(name) || "占用时长".equals(name)) {
            unit = " s";
        }
        stat.view.getStats().put(name, fmt(value) + unit);
    }

    private Map<String, String> t0Values(TrialVO event) {
        Map<String, String> values = new HashMap<String, String>();
        for (Map.Entry<String, List<double[]>> e : event.getSeries().entrySet()) {
            values.put(e.getKey(), trimNum(nearest(e.getValue(), 0)));
        }
        for (Map.Entry<String, List<TrialVO.StatePoint>> e : event.getStates().entrySet()) {
            String v = stateAt(e.getValue(), 0);
            if (v != null) {
                values.put(e.getKey(), v);
            }
        }
        return values;
    }

    private Map<String, Boolean> windowHits(TrialVO event, MemoryCatalog cat) {
        Map<String, Boolean> windows = new HashMap<String, Boolean>();
        for (AtomView atom : cat.all()) {
            if (!atom.isWindow()) {
                continue;
            }
            for (String code : atom.codes) {
                boolean hit = false;
                for (TrialVO.FaultHit f : event.getFaults()) {
                    if (code.equals(f.getCode()) && Math.abs(f.getT()) <= (atom.seconds == null ? 0 : atom.seconds)) {
                        hit = true;
                        break;
                    }
                }
                windows.put(atom.code + ":" + code, hit);
            }
        }
        return windows;
    }

    /**
     * 数据卡条件的比较。两边都能当成数字时，等于和不等于按数值比，和原型的 cmp 一致。
     */
    private boolean cardCmp(double actual, String op, String target) {
        Double b = parseMaybe(target);
        boolean num = b != null && target != null && !target.trim().isEmpty();
        if ("==".equals(op) || "!=".equals(op)) {
            boolean eq = num ? actual == b : String.valueOf(actual).equals(target);
            return "==".equals(op) ? eq : !eq;
        }
        if (!num) {
            return false;
        }
        if (">".equals(op)) {
            return actual > b;
        }
        if (">=".equals(op)) {
            return actual >= b;
        }
        if ("<".equals(op)) {
            return actual < b;
        }
        if ("<=".equals(op)) {
            return actual <= b;
        }
        return false;
    }

    private AtomView atomView(Long id, MemoryCatalog cat) {
        if (id == null) {
            return null;
        }
        RuleAtom row = atomMapper.selectById(id);
        return row == null ? null : cat.find(row.getAtomCode());
    }

    private AtomView groupView(Long id, MemoryCatalog cat) {
        if (id == null) {
            return null;
        }
        RuleGroup row = groupMapper.selectById(id);
        return row == null ? null : cat.find(row.getGroupCode());
    }

    private double nearest(List<double[]> ser, double t) {
        double[] best = ser.get(0);
        for (double[] p : ser) {
            if (Math.abs(p[0] - t) < Math.abs(best[0] - t)) {
                best = p;
            }
        }
        return best[1];
    }

    private String stateAt(List<TrialVO.StatePoint> ch, int t) {
        String v = null;
        for (TrialVO.StatePoint p : ch) {
            if (p.getT() <= t) {
                v = p.getVal();
            }
        }
        return v;
    }

    private String enumText(RuleParamMeta meta, String v) {
        if (v == null) {
            return "—";
        }
        if (meta != null && meta.getEnumDict() != null) {
            for (String part : meta.getEnumDict().split(";")) {
                String[] kv = part.split(":", 2);
                if (kv.length == 2 && kv[0].trim().equals(v)) {
                    return v + " " + kv[1].trim();
                }
            }
        }
        return v;
    }

    private String fmt(double v) {
        if (Math.abs(v) >= 100) {
            return String.valueOf(Math.round(v));
        }
        return String.valueOf(Math.round(v * 10.0) / 10.0);
    }

    private String trimNum(double v) {
        if (v == Math.rint(v)) {
            return String.valueOf((long) v);
        }
        return String.valueOf(v);
    }

    private Double parseMaybe(String v) {
        try {
            return Double.valueOf(v);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private int safe(Integer n) {
        return n == null ? 0 : n;
    }

    private double max(double[] vs) {
        double m = vs[0];
        for (double v : vs) {
            m = Math.max(m, v);
        }
        return m;
    }

    private double min(double[] vs) {
        double m = vs[0];
        for (double v : vs) {
            m = Math.min(m, v);
        }
        return m;
    }

    private double avg(double[] vs) {
        double s = 0;
        for (double v : vs) {
            s += v;
        }
        return s / vs.length;
    }

    private String join(List<String> parts, String sep) {
        StringBuilder sb = new StringBuilder();
        for (String p : parts) {
            if (sb.length() > 0) {
                sb.append(sep);
            }
            sb.append(p);
        }
        return sb.toString();
    }

    private TrialVO brief(SimEvent event) {
        TrialVO vo = new TrialVO();
        vo.setId(event.getId());
        vo.setEventCode(event.getEventCode());
        vo.setFaultRuleId(event.getFaultRuleId());
        vo.setEventTitle(event.getEventTitle());
        vo.setExpectOutcome(event.getExpectOutcome());
        vo.setCc(event.getCc());
        vo.setSd(event.getSd());
        vo.setWz(event.getWz());
        vo.setJl(event.getJl());
        vo.setSjxm(event.getSjxm());
        vo.setFssj(event.getFssj() == null ? null : TS.format(event.getFssj()));
        vo.setIsSample(event.getIsSample());
        FaultRule fault = faultMapper.selectById(event.getFaultRuleId());
        if (fault != null) {
            vo.setCx(fault.getCx());
            vo.setLy(fault.getLy());
            vo.setGzdm(fault.getGzdm());
        }
        return vo;
    }

    private SimEvent must(Long id) {
        SimEvent event = eventMapper.selectById(id);
        if (event == null) {
            throw BizException.notFound("试跑事件不存在");
        }
        return event;
    }

    private static final class CardStat {
        private TrialVO.CardEval view;
        private final Map<String, Double> raw = new HashMap<String, Double>();
    }

}
