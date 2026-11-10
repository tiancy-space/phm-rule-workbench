package com.phm.rule.service;

import com.phm.rule.expression.AtomView;
import com.phm.rule.expression.ParamView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 处置流程发布前校验。规则与原型一致：出口、死循环、可达性、车型匹配、结束节点。
 * 黄色提示不阻断发布。
 */
public class FlowValidator {

    private static final String CIRC = "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳";
    private static final Set<String> NUM_STATS = new HashSet<String>(Arrays.asList(
            "T0值", "最大", "最小", "平均", "首值", "末值", "变化量", "越限时长"));
    private static final Set<String> STATE_STATS = new HashSet<String>(Arrays.asList("T0值", "变位次数", "占用时长", "是否出现过"));
    private static final Set<String> FAULT_STATS = new HashSet<String>(Arrays.asList("出现次数", "T0后再次出现"));
    private static final Set<String> CONCL = new HashSet<String>(Arrays.asList("MAINTAIN", "SPEED_LIMIT", "RESCUE", "RETURN_DEPOT"));

    /**
     * @param steps    按序号排列的步骤
     * @param cxs      绑定故障的车型
     * @param template 是否模板
     * @param bindings 绑定条数
     * @param atoms    原子主键到定义
     * @param groups   命名组主键到定义
     * @param params   参数主键到定义
     * @return 错误与提示
     */
    public Result validate(List<Step> steps, List<String> cxs, boolean template, int bindings,
                           Map<Long, AtomView> atoms, Map<Long, AtomView> groups, Map<Long, ParamView> params) {
        Result r = new Result();
        if (steps == null || steps.isEmpty()) {
            r.errors.add("流程没有任何步骤");
            return r;
        }
        Map<Long, Step> byId = new HashMap<Long, Step>();
        for (Step s : steps) {
            byId.put(s.id, s);
        }
        for (int i = 0; i < steps.size(); i++) {
            Step s = steps.get(i);
            String n = "步骤 " + circ(i);
            if (s.title == null || s.title.trim().isEmpty()) {
                r.errors.add(n + "：标题为空");
            }
            if (s.roles == null || s.roles.isEmpty()) {
                r.errors.add(n + "：未勾选任何角色");
            }
            if ("END".equals(s.type)) {
                if (s.conclusion == null || !CONCL.contains(s.conclusion)) {
                    r.errors.add(n + "：未选择结束结论");
                }
            } else {
                if (s.branches == null || s.branches.isEmpty()) {
                    r.errors.add(n + "：没有出口");
                } else {
                    if ("JUDGE".equals(s.type) && s.branches.size() < 2) {
                        r.errors.add(n + "：判断步骤至少需要 2 个分支");
                    }
                    int elses = 0;
                    for (Branch b : s.branches) {
                        if (b.label == null || b.label.trim().isEmpty()) {
                            r.errors.add(n + "：存在空白分支名称");
                        }
                        String label = b.label == null ? "" : b.label;
                        if (b.nextId == null) {
                            r.errors.add(n + "「" + label + "」分支没有出口");
                        } else if (!byId.containsKey(b.nextId)) {
                            r.errors.add(n + "「" + label + "」指向已删除的步骤");
                        } else if (b.nextId.equals(s.id)) {
                            r.errors.add(n + "「" + label + "」跳转到自身（死循环）");
                        }
                        if ("CARD".equals(b.condSrc)) {
                            Card cd = findCard(s, b.cardId);
                            if (cd == null) {
                                r.errors.add(n + "「" + label + "」条件引用的数据卡不存在");
                            } else if (!statsOf(cd.kind).contains(b.stat)) {
                                r.errors.add(n + "「" + label + "」条件统计项无效");
                            } else if (b.value == null || b.value.trim().isEmpty()) {
                                r.errors.add(n + "「" + label + "」条件未填阈值");
                            } else if (!cd.id.equals(b.cardId)) {
                                r.errors.add(n + "「" + label + "」数据卡不属于当前步骤");
                            }
                        }
                        if ("ATOM".equals(b.condSrc) || "GROUP".equals(b.condSrc)) {
                            AtomView a = "ATOM".equals(b.condSrc) ? atoms.get(b.refId) : groups.get(b.refId);
                            if (a == null) {
                                r.errors.add(n + "「" + label + "」引用的" + ("ATOM".equals(b.condSrc) ? "原子" : "命名组") + "不存在");
                            } else if (cxs != null) {
                                for (String cx : cxs) {
                                    if (!a.fits(cx)) {
                                        r.errors.add(n + "「" + label + "」引用的 " + a.code + " 适用 " + a.scopeCx + "，与车型 " + cx + " 不匹配");
                                    }
                                }
                            }
                        }
                        if ("ELSE".equals(b.condSrc)) {
                            elses++;
                        }
                    }
                    if ("JUDGE".equals(s.type) && elses > 1) {
                        r.warnings.add(n + "：存在多个「否则」分支，仅第一个生效");
                    }
                }
            }
            if (s.cards != null) {
                for (Card c : s.cards) {
                    if ("FAULT".equals(c.kind)) {
                        if (c.codes == null || c.codes.trim().isEmpty()) {
                            r.errors.add(n + " 数据卡 " + c.code + "：未填关联故障代码");
                        }
                    } else {
                        ParamView p = c.paramId == null ? null : params.get(c.paramId);
                        if (p == null) {
                            r.errors.add(n + " 数据卡 " + c.code + "：未选择参数");
                        } else if (cxs != null) {
                            for (String cx : cxs) {
                                if (!p.fits(cx)) {
                                    r.errors.add(n + " 数据卡「" + p.name + "」参数不适用于车型 " + cx);
                                }
                            }
                            if ("NUM".equals(c.kind) && !"NUMBER".equals(p.dataType)) {
                                r.warnings.add(n + " 数据卡「" + p.name + "」不是数值量，建议改为状态量取值");
                            }
                        }
                    }
                    if (c.pre == null || c.post == null || c.pre < 0 || c.post < 0) {
                        r.errors.add(n + " 数据卡 " + c.code + "：取数窗口无效");
                    }
                }
            }
        }
        boolean hasEnd = false;
        for (Step s : steps) {
            if ("END".equals(s.type)) {
                hasEnd = true;
                break;
            }
        }
        if (!hasEnd) {
            r.errors.add("至少需要一个结束节点");
        }
        Set<Long> reach = new HashSet<Long>();
        List<Long> queue = new ArrayList<Long>();
        queue.add(steps.get(0).id);
        while (!queue.isEmpty()) {
            Long id = queue.remove(0);
            if (!reach.add(id)) {
                continue;
            }
            Step s = byId.get(id);
            if (s == null || s.branches == null) {
                continue;
            }
            for (Branch b : s.branches) {
                if (b.nextId != null && byId.containsKey(b.nextId)) {
                    queue.add(b.nextId);
                }
            }
        }
        for (int i = 0; i < steps.size(); i++) {
            if (!reach.contains(steps.get(i).id)) {
                r.errors.add("步骤 " + circ(i) + "「" + steps.get(i).title + "」不可达（没有分支指向它）");
            }
        }
        Set<Long> ok = new HashSet<Long>();
        for (Step s : steps) {
            if ("END".equals(s.type)) {
                ok.add(s.id);
            }
        }
        boolean changed = true;
        while (changed) {
            changed = false;
            for (Step s : steps) {
                if (ok.contains(s.id) || s.branches == null) {
                    continue;
                }
                for (Branch b : s.branches) {
                    if (b.nextId != null && ok.contains(b.nextId)) {
                        ok.add(s.id);
                        changed = true;
                        break;
                    }
                }
            }
        }
        for (int i = 0; i < steps.size(); i++) {
            Step s = steps.get(i);
            if (reach.contains(s.id) && !ok.contains(s.id)) {
                r.errors.add("步骤 " + circ(i) + "「" + s.title + "」无法到达任何结束节点（死循环）");
            }
        }
        Map<Long, Integer> color = new HashMap<Long, Integer>();
        for (Step s : steps) {
            if (!color.containsKey(s.id)) {
                dfs(s.id, byId, color, r, steps);
            }
        }
        if (bindings == 0 && !template) {
            r.warnings.add("流程未绑定任何故障");
        }
        return r;
    }

    private void dfs(Long id, Map<Long, Step> byId, Map<Long, Integer> color, Result r, List<Step> steps) {
        color.put(id, 1);
        Step s = byId.get(id);
        if (s != null && s.branches != null) {
            for (Branch b : s.branches) {
                if (b.nextId == null || !byId.containsKey(b.nextId) || b.nextId.equals(id)) {
                    continue;
                }
                Integer c = color.get(b.nextId);
                if (c != null && c == 1) {
                    r.warnings.add("存在回环：步骤 " + circ(indexOf(steps, id)) + "「" + b.label + "」→ 步骤 "
                            + circ(indexOf(steps, b.nextId)) + "，请确认回环中有退出分支");
                } else if (c == null) {
                    dfs(b.nextId, byId, color, r, steps);
                }
            }
        }
        color.put(id, 2);
    }

    private int indexOf(List<Step> steps, Long id) {
        for (int i = 0; i < steps.size(); i++) {
            if (steps.get(i).id.equals(id)) {
                return i;
            }
        }
        return 0;
    }

    private Card findCard(Step s, Long id) {
        if (s.cards == null || id == null) {
            return null;
        }
        for (Card c : s.cards) {
            if (id.equals(c.id)) {
                return c;
            }
        }
        return null;
    }

    private Set<String> statsOf(String kind) {
        if ("STATE".equals(kind)) {
            return STATE_STATS;
        }
        if ("FAULT".equals(kind)) {
            return FAULT_STATS;
        }
        return NUM_STATS;
    }

    private String circ(int index) {
        if (index >= 0 && index < CIRC.length()) {
            return String.valueOf(CIRC.charAt(index));
        }
        return "(" + (index + 1) + ")";
    }

    /**
     * 校验结果。
     */
    public static class Result {
        /** 阻断发布的问题 */
        public List<String> errors = new ArrayList<String>();
        /** 不阻断发布的提示 */
        public List<String> warnings = new ArrayList<String>();
    }

    /** 校验用的步骤快照。 */
    public static class Step {
        public Long id;
        public String type;
        public String title;
        public List<String> roles = new ArrayList<String>();
        public String conclusion;
        public List<Card> cards = new ArrayList<Card>();
        public List<Branch> branches = new ArrayList<Branch>();
    }

    /** 数据卡快照。 */
    public static class Card {
        public Long id;
        public String code;
        public String kind;
        public Long paramId;
        public String codes;
        public Integer pre;
        public Integer post;
    }

    /** 出口快照。 */
    public static class Branch {
        public String label;
        public Long nextId;
        public String condSrc;
        public Long cardId;
        public String stat;
        public String value;
        public Long refId;
    }
}
