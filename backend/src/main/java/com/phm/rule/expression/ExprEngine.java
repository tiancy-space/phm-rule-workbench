package com.phm.rule.expression;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

/**
 * 零 JSON 与组合式的格式化、展开、中文释义和求值。行为对齐原型 V5.1 的 parseLogic / parseZeroJson /
 * atomExpr / atomText / expandAst / explainText / evaluateAtom。
 */
public class ExprEngine {

    private static final String CIRC = "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳";

    private final LogicParser logic = new LogicParser();
    private final ZeroJsonParser zero = new ZeroJsonParser();

    /**
     * @return 组合式解析器，供需要单独报错位置的调用方使用
     */
    public LogicParser logic() {
        return logic;
    }

    /**
     * @return 零 JSON 解析器
     */
    public ZeroJsonParser zero() {
        return zero;
    }

    /**
     * 把故障组合式整理成规范写法（补空格、按优先级加括号）。
     *
     * @param text     用户输入
     * @param refCodes A1 起的引用编号
     * @return 规范组合式
     */
    public String canonicalAlias(String text, List<String> refCodes) {
        return format(logic.parseAlias(text, refCodes), new LeafFmt() {
            @Override
            public String apply(ExprAst n) {
                return n.getAlias();
            }
        }, true);
    }

    /**
     * 展开成引擎执行的零 JSON。命名组会被内联，组名不会出现在结果里。
     *
     * @param text     组合式
     * @param refCodes A1 起的引用编号
     * @param catalog  目录
     * @return 零 JSON
     */
    public String expandAlias(String text, List<String> refCodes, ExprCatalog catalog) {
        ExprAst ast = logic.parseAlias(text, refCodes);
        return expandAst(ast, catalog);
    }

    /**
     * 引用式：命名组保留组名，仅供阅读，不入库。
     *
     * @param text     组合式
     * @param refCodes 引用编号
     * @param catalog  目录
     * @return 引用式
     */
    public String refExpr(String text, List<String> refCodes, ExprCatalog catalog) {
        ExprAst ast = logic.parseAlias(text, refCodes);
        return format(ast, new LeafFmt() {
            @Override
            public String apply(ExprAst n) {
                AtomView a = catalog.find(n.getRefCode());
                if (a != null && a.isGroup()) {
                    return a.name;
                }
                return atomExpr(a, catalog);
            }
        }, true);
    }

    /**
     * 中文判定逻辑释义（不含前置规则，前置由调用方另行列出）。
     *
     * @param text     组合式
     * @param refCodes 引用编号
     * @param gzdm     故障代码，写进标题
     * @param catalog  目录
     * @return 多行中文
     */
    public String explainAlias(String text, List<String> refCodes, String gzdm, ExprCatalog catalog) {
        ExprAst ast = logic.parseAlias(text, refCodes);
        return explain(ast, gzdm, catalog);
    }

    /**
     * 供梯形图使用的展示树。
     *
     * @param text     组合式
     * @param refCodes 引用编号
     * @param catalog  目录
     * @return 展示树
     */
    public DisplayNode display(String text, List<String> refCodes, ExprCatalog catalog) {
        return disp(logic.parseAlias(text, refCodes), catalog);
    }

    /**
     * 命名组的展开式与现场说法。
     *
     * @param groupExpr 以原子编号书写的组合式
     * @param catalog   目录
     * @return 下标 0 为规范组合式，1 为展开式，2 为中文说法
     */
    public String[] compileGroup(String groupExpr, ExprCatalog catalog) {
        ExprAst ast = logic.parseGroup(groupExpr, catalog.atomCodes());
        String canon = format(ast, new LeafFmt() {
            @Override
            public String apply(ExprAst n) {
                return n.getAlias();
            }
        }, true);
        String expanded = expandAst(ast, catalog);
        String desc = groupSummary(ast, catalog);
        return new String[]{canon, expanded, desc};
    }

    /**
     * 由原子字段生成入库表达式。
     *
     * @param atom    原子
     * @param catalog 用来决定数值是否加引号
     * @return 零 JSON 片段
     */
    public String atomExpr(AtomView atom, ExprCatalog catalog) {
        if (atom == null) {
            return "/*已删除*/";
        }
        if (atom.isGroup()) {
            try {
                return compileGroup(atom.groupExpr, catalog)[1];
            } catch (ExprException ex) {
                return "/*命名组表达式有误*/";
            }
        }
        if (atom.isWindow()) {
            StringBuilder sb = new StringBuilder();
            sb.append(atom.fn).append('(').append(atom.seconds);
            for (String code : atom.codes) {
                sb.append(", ").append(codeTok(code));
            }
            sb.append(')');
            return sb.toString();
        }
        ParamView p = paramOf(catalog, atom.field);
        if ("IN".equals(atom.op) || "NOT IN".equals(atom.op)) {
            String[] parts = splitList(atom.value);
            StringBuilder sb = new StringBuilder();
            sb.append(atom.field).append(' ').append(atom.op).append(" (");
            for (int i = 0; i < parts.length; i++) {
                if (i > 0) {
                    sb.append(", ");
                }
                sb.append(valTok(p, parts[i]));
            }
            sb.append(')');
            return sb.toString();
        }
        if ("=~".equals(atom.op)) {
            return atom.field + " =~ " + quote(atom.value);
        }
        return atom.field + " " + atom.op + " " + valTok(p, atom.value);
    }

    /**
     * 原子的中文说法。名称为空时用它自动生成。
     *
     * @param atom    原子
     * @param catalog 参数中文名与码表
     * @return 中文
     */
    public String atomText(AtomView atom, ExprCatalog catalog) {
        if (atom == null) {
            return "（已删除的条件）";
        }
        if (atom.isGroup()) {
            return atom.name == null ? "" : atom.name;
        }
        if (atom.isWindow()) {
            String joined = joinDun(atom.codes);
            boolean one = atom.codes.size() == 1;
            int sec = atom.seconds == null ? 0 : atom.seconds;
            String fn = atom.fn == null ? "" : atom.fn;
            if ("allNotExists".equals(fn)) {
                return one ? "前后 " + sec + " 秒内未出现故障 " + joined : "前后 " + sec + " 秒内未出现 " + joined + " 中任一故障";
            }
            if ("anyExists".equals(fn)) {
                return one ? "前后 " + sec + " 秒内出现过故障 " + joined : "前后 " + sec + " 秒内出现过 " + joined + " 中任一故障";
            }
            if ("allExists".equals(fn)) {
                return one ? "前后 " + sec + " 秒内出现过故障 " + joined : "前后 " + sec + " 秒内 " + joined + " 全部出现过";
            }
            return one ? "前后 " + sec + " 秒内未出现故障 " + joined : "前后 " + sec + " 秒内 " + joined + " 未全部出现（至少缺一个）";
        }
        ParamView p = paramOf(catalog, atom.field);
        String v = atom.value == null ? "" : atom.value.trim();
        String[][] enums = enumValues(p.enumDict);
        if ("-".equals(v) && "==".equals(atom.op)) {
            return p.name + " 未取到（缺失）";
        }
        if ("-".equals(v) && "!=".equals(atom.op)) {
            return p.name + " 已取到";
        }
        if ("IN".equals(atom.op) || "NOT IN".equals(atom.op)) {
            String[] parts = splitList(v);
            List<String> labels = new ArrayList<String>();
            for (String part : parts) {
                labels.add(enumLabel(enums, part));
            }
            String lab;
            if (labels.size() > 6) {
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < 6; i++) {
                    if (i > 0) {
                        sb.append('、');
                    }
                    sb.append(labels.get(i));
                }
                lab = sb + " 等 " + labels.size() + " 个";
            } else {
                lab = joinDun(labels);
            }
            return p.name + ("IN".equals(atom.op) ? " 属于 " : " 不属于 ") + lab;
        }
        if ("=~".equals(atom.op)) {
            return p.name + " 匹配正则 " + v;
        }
        if (("==".equals(atom.op) || "!=".equals(atom.op))) {
            String en = enumName(enums, v);
            if (en != null) {
                return p.name + ("==".equals(atom.op) ? " 为 " : " 不为 ") + en;
            }
        }
        String sym = "==".equals(atom.op) ? "=" : "!=".equals(atom.op) ? "≠" : ">=".equals(atom.op) ? "≥" : "<=".equals(atom.op) ? "≤" : atom.op;
        String unit = p.unit == null || p.unit.trim().isEmpty() ? "" : " " + p.unit.trim();
        return p.name + " " + sym + " " + v + unit;
    }

    /**
     * 反解析零 JSON，返回规范写法。未知参数、花括号、中括号会抛出 {@link ExprException}。
     *
     * @param text    表达式
     * @param catalog 参数目录
     * @return 规范零 JSON
     */
    public String canonicalZero(String text, ExprCatalog catalog) {
        ExprAst ast = zero.parse(text, catalog.paramCodes());
        return format(ast, new LeafFmt() {
            @Override
            public String apply(ExprAst n) {
                return atomExpr(condAsAtom(n.getCond()), catalog);
            }
        }, true);
    }

    /**
     * 统计零 JSON 中的条件个数、参数编码和时间窗个数，供反解析校验展示。
     *
     * @param text    表达式
     * @param catalog 参数目录
     * @return 摘要
     */
    public ZeroSummary summarizeZero(String text, ExprCatalog catalog) {
        ExprAst ast = zero.parse(text, catalog.paramCodes());
        ZeroSummary s = new ZeroSummary();
        s.canonical = format(ast, new LeafFmt() {
            @Override
            public String apply(ExprAst n) {
                return atomExpr(condAsAtom(n.getCond()), catalog);
            }
        }, true);
        walkConds(ast, s);
        return s;
    }

    /**
     * 对一条故障组合式求值。命名组会展开到原子再算。
     * 时间窗命中表的键为「原子编号:故障代码」。
     *
     * @param text     组合式
     * @param refCodes 引用
     * @param values   测点值，缺失值用 "-" 
     * @param windows  时间窗命中
     * @param catalog  目录
     * @return 组合是否成立
     */
    public boolean evalAlias(String text, List<String> refCodes, Map<String, String> values,
                             Map<String, Boolean> windows, ExprCatalog catalog) {
        return evalAst(logic.parseAlias(text, refCodes), values, windows, catalog, new HashSet<String>());
    }

    /**
     * 组合式展开后涉及到的原子编号（命名组已拆开，按首次出现去重）。
     *
     * @param text     组合式
     * @param refCodes 引用
     * @param catalog  目录
     * @return 原子编号
     */
    public List<String> inlinedAtomCodes(String text, List<String> refCodes, ExprCatalog catalog) {
        ExprAst inlined = inline(logic.parseAlias(text, refCodes), catalog, new HashSet<String>());
        List<String> ids = new ArrayList<String>();
        collectRefs(inlined, ids);
        return ids;
    }

    /**
     * 求值单个原子或命名组。
     *
     * @param atom     定义
     * @param values   测点
     * @param windows  时间窗命中
     * @param catalog  目录
     * @return 是否成立
     */
    public boolean evalAtom(AtomView atom, Map<String, String> values, Map<String, Boolean> windows, ExprCatalog catalog) {
        return evalAtom(atom, values, windows, catalog, new HashSet<String>());
    }

    /**
     * 按比较符比较一个测点。空值视为未命中（与原型一致）。
     *
     * @param actual 实测值
     * @param op     比较符
     * @param target 目标值
     * @return 是否成立
     */
    public boolean compare(String actual, String op, String target) {
        if (actual == null || actual.trim().isEmpty()) {
            return false;
        }
        String v = actual;
        String t = target == null ? "" : target;
        if ("IN".equals(op) || "NOT IN".equals(op)) {
            boolean hit = false;
            for (String part : splitList(t)) {
                if (part.equals(v)) {
                    hit = true;
                    break;
                }
            }
            return "IN".equals(op) ? hit : !hit;
        }
        if ("=~".equals(op)) {
            try {
                return Pattern.compile(t).matcher(v).find();
            } catch (PatternSyntaxException ex) {
                return false;
            }
        }
        if (">".equals(op) || ">=".equals(op) || "<".equals(op) || "<=".equals(op)) {
            Double x = finite(v);
            Double y = finite(t);
            if (x == null || y == null) {
                return false;
            }
            if (">".equals(op)) {
                return x > y;
            }
            if (">=".equals(op)) {
                return x >= y;
            }
            if ("<".equals(op)) {
                return x < y;
            }
            return x <= y;
        }
        if ("!=".equals(op)) {
            return !v.equals(t);
        }
        return v.equals(t);
    }

    private boolean evalAst(ExprAst ast, Map<String, String> values, Map<String, Boolean> windows,
                            ExprCatalog catalog, Set<String> stack) {
        if (ast.isLeaf()) {
            if (ast.getCond() != null) {
                return evalCond(ast.getCond(), values, windows);
            }
            return evalAtom(catalog.find(ast.getRefCode()), values, windows, catalog, stack);
        }
        if (ast.getType() == ExprAst.Type.AND) {
            for (ExprAst c : ast.getChildren()) {
                if (!evalAst(c, values, windows, catalog, stack)) {
                    return false;
                }
            }
            return true;
        }
        for (ExprAst c : ast.getChildren()) {
            if (evalAst(c, values, windows, catalog, stack)) {
                return true;
            }
        }
        return false;
    }

    private boolean evalAtom(AtomView atom, Map<String, String> values, Map<String, Boolean> windows,
                             ExprCatalog catalog, Set<String> stack) {
        if (atom == null) {
            return false;
        }
        if (atom.isGroup()) {
            if (!stack.add(atom.code)) {
                return false;
            }
            try {
                ExprAst ast = logic.parseGroup(atom.groupExpr, catalog.atomCodes());
                return evalAst(ast, values, windows, catalog, stack);
            } catch (ExprException ex) {
                return false;
            } finally {
                stack.remove(atom.code);
            }
        }
        if (atom.isWindow()) {
            List<Boolean> hits = new ArrayList<Boolean>();
            for (String code : atom.codes) {
                Boolean h = windows == null ? null : windows.get(atom.code + ":" + code);
                hits.add(Boolean.TRUE.equals(h));
            }
            return windowHits(atom.fn, hits);
        }
        String val = values == null ? null : values.get(atom.field);
        return compare(val, atom.op, atom.value);
    }

    private boolean evalCond(ExprAst.Cond c, Map<String, String> values, Map<String, Boolean> windows) {
        if (c.isWindow()) {
            List<Boolean> hits = new ArrayList<Boolean>();
            for (String code : c.codes) {
                Boolean h = windows == null ? null : windows.get(code);
                hits.add(Boolean.TRUE.equals(h));
            }
            return windowHits(c.fn, hits);
        }
        String val = values == null ? null : values.get(c.field);
        return compare(val, c.op, c.value);
    }

    private boolean windowHits(String fn, List<Boolean> hits) {
        boolean any = false;
        boolean all = !hits.isEmpty();
        for (Boolean h : hits) {
            if (Boolean.TRUE.equals(h)) {
                any = true;
            } else {
                all = false;
            }
        }
        if ("allNotExists".equals(fn)) {
            return !any;
        }
        if ("anyExists".equals(fn)) {
            return any;
        }
        if ("allExists".equals(fn)) {
            return all;
        }
        return !all;
    }

    private String expandAst(ExprAst ast, ExprCatalog catalog) {
        ExprAst inlined = inline(ast, catalog, new HashSet<String>());
        return format(inlined, new LeafFmt() {
            @Override
            public String apply(ExprAst n) {
                if (n.getCond() != null) {
                    return atomExpr(condAsAtom(n.getCond()), catalog);
                }
                return atomExpr(catalog.find(n.getRefCode()), catalog);
            }
        }, true);
    }

    private ExprAst inline(ExprAst node, ExprCatalog catalog, Set<String> stack) {
        if (node.isLeaf()) {
            if (node.getCond() != null) {
                return node;
            }
            AtomView a = catalog.find(node.getRefCode());
            if (a != null && a.isGroup()) {
                if (!stack.add(a.code)) {
                    throw new ExprException("命名组循环引用 " + a.code, 0);
                }
                ExprAst g = logic.parseGroup(a.groupExpr, catalog.atomCodes());
                ExprAst in = inline(g, catalog, stack);
                stack.remove(a.code);
                return in;
            }
            return node;
        }
        List<ExprAst> kids = new ArrayList<ExprAst>();
        for (ExprAst c : node.getChildren()) {
            kids.add(inline(c, catalog, stack));
        }
        return ExprAst.flatten(node.getType(), kids);
    }

    private String explain(ExprAst ast, String gzdm, ExprCatalog catalog) {
        DisplayNode root = disp(ast, catalog);
        List<DisplayNode> items = topItems(root);
        String head = "or".equals(root.type)
                ? "满足以下任一项，即报出故障 " + gzdm + "："
                : "报出故障 " + gzdm + "，需同时满足以下 " + items.size() + " 项：";
        StringBuilder sb = new StringBuilder(head);
        for (int i = 0; i < items.size(); i++) {
            sb.append('\n').append(circ(i)).append(' ').append(itemText(items.get(i), catalog));
        }
        return sb.toString();
    }

    private String itemText(DisplayNode n, ExprCatalog catalog) {
        if ("leaf".equals(n.type)) {
            return n.text;
        }
        if ("named".equals(n.type)) {
            if (n.child == null) {
                return n.name + "（表达式有误）";
            }
            DisplayNode c = n.child;
            String body = "or".equals(c.type)
                    ? join(mapInline(c.children, true, catalog), " ／ ")
                    : inlineText(c, true, catalog);
            return n.name + "（" + kindCn(c) + "）：" + body;
        }
        String prefix = "or".equals(n.type) ? "满足其一：" : "同时满足：";
        String sep = "or".equals(n.type) ? " ／ " : "；";
        return prefix + join(mapInline(n.children, true, catalog), sep);
    }

    private List<String> mapInline(List<DisplayNode> nodes, boolean top, ExprCatalog catalog) {
        List<String> out = new ArrayList<String>();
        if (nodes == null) {
            return out;
        }
        for (DisplayNode c : nodes) {
            out.add(inlineText(c, top, catalog));
        }
        return out;
    }

    private String inlineText(DisplayNode n, boolean top, ExprCatalog catalog) {
        if ("leaf".equals(n.type)) {
            return n.text;
        }
        if ("named".equals(n.type)) {
            if (n.child != null) {
                return n.name + "（" + inlineText(n.child, true, catalog) + "）";
            }
            return n.name;
        }
        String sep = "and".equals(n.type) ? " 且 " : " 或 ";
        String s = join(mapInline(n.children, false, catalog), sep);
        return top ? s : "（" + s + "）";
    }

    private String groupSummary(ExprAst ast, ExprCatalog catalog) {
        DisplayNode n = disp(ast, catalog);
        if ("or".equals(n.type)) {
            return join(mapInline(n.children, true, catalog), " ／ ");
        }
        return inlineText(n, true, catalog);
    }

    private DisplayNode disp(ExprAst node, ExprCatalog catalog) {
        if (node.isLeaf()) {
            AtomView a = node.getCond() != null ? condAsAtom(node.getCond()) : catalog.find(node.getRefCode());
            if (a != null && a.isGroup()) {
                DisplayNode named = new DisplayNode();
                named.type = "named";
                named.alias = node.getAlias();
                named.code = a.code;
                named.name = a.name;
                named.text = a.name;
                try {
                    ExprAst child = logic.parseGroup(a.groupExpr, catalog.atomCodes());
                    named.child = disp(child, catalog);
                    named.expr = expandAst(child, catalog);
                } catch (ExprException ex) {
                    named.child = null;
                    named.expr = "/*命名组表达式有误*/";
                }
                return named;
            }
            DisplayNode leaf = new DisplayNode();
            leaf.type = "leaf";
            leaf.alias = node.getAlias();
            leaf.code = a == null ? node.getRefCode() : a.code;
            leaf.text = atomText(a, catalog);
            leaf.expr = atomExpr(a, catalog);
            return leaf;
        }
        DisplayNode n = new DisplayNode();
        n.type = node.getType() == ExprAst.Type.AND ? "and" : "or";
        for (ExprAst c : node.getChildren()) {
            n.children.add(disp(c, catalog));
        }
        return n;
    }

    private List<DisplayNode> topItems(DisplayNode root) {
        if ("and".equals(root.type) || "or".equals(root.type)) {
            return root.children;
        }
        List<DisplayNode> one = new ArrayList<DisplayNode>();
        one.add(root);
        return one;
    }

    private String kindCn(DisplayNode n) {
        if (n == null) {
            return "表达式有误";
        }
        if ("or".equals(n.type)) {
            return "满足其一";
        }
        if ("and".equals(n.type)) {
            return "同时满足";
        }
        return "单项条件";
    }

    private String circ(int i) {
        if (i >= 0 && i < CIRC.length()) {
            return String.valueOf(CIRC.charAt(i));
        }
        return "(" + (i + 1) + ")";
    }

    private void collectRefs(ExprAst ast, List<String> ids) {
        if (ast.isLeaf()) {
            if (ast.getRefCode() != null && !ids.contains(ast.getRefCode())) {
                ids.add(ast.getRefCode());
            }
            return;
        }
        for (ExprAst c : ast.getChildren()) {
            collectRefs(c, ids);
        }
    }

    private void walkConds(ExprAst ast, ZeroSummary s) {
        if (ast.isLeaf()) {
            s.count++;
            ExprAst.Cond c = ast.getCond();
            if (c != null && c.isWindow()) {
                s.windows++;
            } else if (c != null && c.field != null && !s.fields.contains(c.field)) {
                s.fields.add(c.field);
            }
            return;
        }
        for (ExprAst c : ast.getChildren()) {
            walkConds(c, s);
        }
    }

    private AtomView condAsAtom(ExprAst.Cond c) {
        AtomView a = new AtomView();
        if (c == null) {
            return a;
        }
        a.type = c.isWindow() ? "WINDOW" : "PARAM";
        a.field = c.field;
        a.op = c.op;
        a.value = c.value;
        a.fn = c.fn;
        a.seconds = c.seconds;
        if (c.codes != null) {
            a.codes = c.codes;
        }
        return a;
    }

    private String format(ExprAst node, LeafFmt leaf, boolean root) {
        if (node.isLeaf()) {
            return leaf.apply(node);
        }
        String sep = node.getType() == ExprAst.Type.AND ? " & " : " | ";
        StringBuilder sb = new StringBuilder();
        List<ExprAst> children = node.getChildren();
        for (int i = 0; i < children.size(); i++) {
            if (i > 0) {
                sb.append(sep);
            }
            sb.append(format(children.get(i), leaf, false));
        }
        return root ? sb.toString() : "(" + sb + ")";
    }

    private ParamView paramOf(ExprCatalog catalog, String code) {
        ParamView p = catalog == null ? null : catalog.param(code);
        if (p != null) {
            return p;
        }
        ParamView d = new ParamView();
        d.code = code;
        d.name = code == null ? "" : code;
        d.dataType = "STRING";
        return d;
    }

    /**
     * 数值和枚举的纯数字不加引号，其余（含缺失值 "-"）加单引号。
     */
    public String valTok(ParamView p, String raw) {
        String v = raw == null ? "" : raw.trim();
        boolean numericType = p != null && ("NUMBER".equals(p.dataType) || "ENUM".equals(p.dataType));
        if (numericType && isNumLit(v)) {
            return v;
        }
        return quote(v);
    }

    /**
     * 故障代码只含字母数字下划线时不加引号。
     *
     * @param code 故障代码
     * @return 表达式中的写法
     */
    public String codeTok(String code) {
        String c = code == null ? "" : code;
        if (c.matches("[A-Za-z0-9_]+")) {
            return c;
        }
        return quote(c);
    }

    /**
     * @param v 文本
     * @return 单引号字面量
     */
    public String quote(String v) {
        String s = v == null ? "" : v;
        return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'";
    }

    private boolean isNumLit(String v) {
        return v.matches("-?\\d+(\\.\\d+)?");
    }

    private String[] splitList(String v) {
        if (v == null || v.trim().isEmpty()) {
            return new String[0];
        }
        String[] raw = v.split("[,，]");
        List<String> out = new ArrayList<String>();
        for (String p : raw) {
            if (!p.trim().isEmpty()) {
                out.add(p.trim());
            }
        }
        return out.toArray(new String[out.size()]);
    }

    private String[][] enumValues(String map) {
        if (map == null || map.trim().isEmpty()) {
            return new String[0][];
        }
        String[] parts = map.split(";");
        List<String[]> rows = new ArrayList<String[]>();
        for (String part : parts) {
            String[] kv = part.trim().split(":", 2);
            if (kv.length == 2) {
                rows.add(new String[]{kv[0].trim(), kv[1].trim()});
            }
        }
        return rows.toArray(new String[rows.size()][]);
    }

    private String enumName(String[][] enums, String code) {
        for (String[] e : enums) {
            if (e[0].equals(code)) {
                return e[1];
            }
        }
        return null;
    }

    private String enumLabel(String[][] enums, String code) {
        String n = enumName(enums, code);
        return n == null ? code : n;
    }

    private String joinDun(List<String> parts) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < parts.size(); i++) {
            if (i > 0) {
                sb.append('、');
            }
            sb.append(parts.get(i));
        }
        return sb.toString();
    }

    private String join(List<String> parts, String sep) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < parts.size(); i++) {
            if (i > 0) {
                sb.append(sep);
            }
            sb.append(parts.get(i));
        }
        return sb.toString();
    }

    private Double finite(String v) {
        if (v == null) {
            return null;
        }
        String s = v.trim();
        if (!s.matches("-?\\d+(\\.\\d+)?")) {
            return null;
        }
        try {
            double d = Double.parseDouble(s);
            if (Double.isInfinite(d) || Double.isNaN(d)) {
                return null;
            }
            return d;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private interface LeafFmt {
        /**
         * @param n 叶子
         * @return 文本
         */
        String apply(ExprAst n);
    }

    /**
     * 零 JSON 反解析摘要。
     */
    public static class ZeroSummary {
        /** 规范写法 */
        public String canonical;
        /** 条件个数 */
        public int count;
        /** 时间窗函数个数 */
        public int windows;
        /** 出现过的参数编码 */
        public List<String> fields = new ArrayList<String>();
    }
}
