package com.phm.rule.expression;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 零 JSON 表达式解析器。参数编码直接书写，缺失值写作 {@code == '-'}，
 * 时间窗写作 {@code allNotExists(10, 1809, 1887)}。花括号、中括号一律拒绝。
 */
public class ZeroJsonParser {

    /** 时间窗函数，与字典 WIN_FN 一致 */
    public static final Set<String> WINDOW_FNS = new HashSet<String>(Arrays.asList(
            "allNotExists", "anyExists", "allExists", "anyNotExists"));

    /**
     * 解析零 JSON。
     *
     * @param text         表达式
     * @param knownParams  参数元数据中的编码；为空则不校验参数是否存在（仅语法）
     * @return 语法树，叶子上带 {@link ExprAst.Cond}
     */
    public ExprAst parse(String text, Set<String> knownParams) {
        return new Parser(text == null ? "" : text, knownParams).parseRoot();
    }

    private static final class Scalar {
        final String kind;
        final String v;

        Scalar(String kind, String v) {
            this.kind = kind;
            this.v = v;
        }
    }

    private static final class Parser {
        private final String text;
        private final int n;
        private final Set<String> params;
        private int pos;

        Parser(String text, Set<String> params) {
            this.text = text;
            this.n = text.length();
            this.params = params;
        }

        ExprAst parseRoot() {
            ExprAst ast = or();
            ws();
            if (pos < n) {
                if (text.charAt(pos) == ')') {
                    throw new ExprException("多余的右括号 )", pos);
                }
                throw new ExprException("缺少逻辑算子 & 或 |", pos);
            }
            return ast;
        }

        private void ws() {
            while (pos < n && Character.isWhitespace(text.charAt(pos))) {
                pos++;
            }
        }

        private void fail(String message) {
            throw new ExprException(message, pos);
        }

        private Scalar scalar() {
            ws();
            if (pos >= n) {
                fail("表达式尚未完成");
            }
            if (text.charAt(pos) == '\'') {
                int i = pos + 1;
                StringBuilder out = new StringBuilder();
                while (i < n && text.charAt(i) != '\'') {
                    if (text.charAt(i) == '\\') {
                        if (i + 1 < n) {
                            out.append(text.charAt(i + 1));
                        }
                        i += 2;
                    } else {
                        out.append(text.charAt(i));
                        i++;
                    }
                }
                if (i >= n) {
                    throw new ExprException("文本缺少结束单引号", pos);
                }
                pos = i + 1;
                return new Scalar("str", out.toString());
            }
            if (text.charAt(pos) == '[') {
                fail("V2 已取消中括号：时间窗写作 allNotExists(10, 1809, 1887)，IN 列表用小括号");
            }
            int start = pos;
            if (text.charAt(pos) == '-' || Character.isDigit(text.charAt(pos))) {
                int i = pos;
                if (text.charAt(i) == '-') {
                    i++;
                }
                int digits = 0;
                while (i < n && Character.isDigit(text.charAt(i))) {
                    digits++;
                    i++;
                }
                if (digits > 0) {
                    if (i < n && text.charAt(i) == '.') {
                        int j = i + 1;
                        int frac = 0;
                        while (j < n && Character.isDigit(text.charAt(j))) {
                            frac++;
                            j++;
                        }
                        if (frac > 0) {
                            i = j;
                        }
                    }
                    if (i >= n || !isIdentChar(text.charAt(i))) {
                        String num = text.substring(start, i);
                        pos = i;
                        return new Scalar("num", num);
                    }
                }
            }
            if (pos < n && isIdentStart(text.charAt(pos))) {
                int i = pos + 1;
                while (i < n && isIdentChar(text.charAt(i))) {
                    i++;
                }
                String id = text.substring(pos, i);
                pos = i;
                return new Scalar("id", id);
            }
            fail(pos >= n ? "表达式尚未完成" : "此处需要数值、编码或单引号文本");
            return null;
        }

        private List<Scalar> list() {
            List<Scalar> vs = new ArrayList<Scalar>();
            vs.add(scalar());
            ws();
            while (pos < n && text.charAt(pos) == ',') {
                pos++;
                vs.add(scalar());
                ws();
            }
            return vs;
        }

        private ExprAst term() {
            ws();
            int start = pos;
            if (pos < n && text.charAt(pos) == '(') {
                pos++;
                ExprAst node = or();
                ws();
                if (pos >= n || text.charAt(pos) != ')') {
                    fail("缺少右括号 )");
                }
                pos++;
                return node;
            }
            if (pos < n && text.charAt(pos) == '{') {
                fail("V2 不再使用花括号，直接写参数编码，如 YX_SD_SJ > 3");
            }
            if (pos >= n || !isIdentStart(text.charAt(pos))) {
                fail(pos >= n ? "表达式尚未完成，需要条件或左括号" : "此处需要参数编码、时间窗函数或左括号");
            }
            int i = pos + 1;
            while (i < n && isIdentChar(text.charAt(i))) {
                i++;
            }
            String name = text.substring(pos, i);
            pos = i;
            ws();
            if (WINDOW_FNS.contains(name)) {
                return window(name, start);
            }
            if (params != null && !params.contains(name)) {
                throw new ExprException("未知参数编码 " + name + "（不在参数元数据中）", start);
            }
            String rest = text.substring(pos);
            String op = matchOp(rest);
            if (op != null) {
                pos += op.length();
                int at = pos;
                Scalar v = scalar();
                if ("id".equals(v.kind)) {
                    throw new ExprException("文本值需加单引号，如 'K123'", at);
                }
                if ((">".equals(op) || ">=".equals(op) || "<".equals(op) || "<=".equals(op)) && !"num".equals(v.kind)) {
                    throw new ExprException("大小比较的目标值须为数值", at);
                }
                ExprAst.Cond c = new ExprAst.Cond();
                c.kind = "PARAM";
                c.field = name;
                c.op = op;
                c.value = v.v;
                return ExprAst.cond(c);
            }
            String inOp = matchIn(rest);
            if (inOp != null) {
                pos += inOp.length();
                ws();
                if (pos >= n || text.charAt(pos) != '(') {
                    fail("IN 列表需用小括号，如 CC NOT IN ('8100', '8200')");
                }
                pos++;
                List<Scalar> vs = list();
                if (pos >= n || text.charAt(pos) != ')') {
                    fail("IN 列表缺少右括号 )");
                }
                pos++;
                StringBuilder joined = new StringBuilder();
                for (int k = 0; k < vs.size(); k++) {
                    if (k > 0) {
                        joined.append(',');
                    }
                    joined.append(vs.get(k).v);
                }
                ExprAst.Cond c = new ExprAst.Cond();
                c.kind = "PARAM";
                c.field = name;
                c.op = inOp.startsWith("NOT") ? "NOT IN" : "IN";
                c.value = joined.toString();
                return ExprAst.cond(c);
            }
            fail("参数后需要比较符 == != > >= < <= =~ 或 IN / NOT IN");
            return null;
        }

        private ExprAst window(String name, int start) {
            if (pos >= n || text.charAt(pos) != '(') {
                fail(name + " 后需要左括号 (");
            }
            pos++;
            List<Scalar> vs = list();
            if (pos >= n || text.charAt(pos) != ')') {
                fail("时间窗函数缺少右括号 ) 或逗号");
            }
            pos++;
            if (!"num".equals(vs.get(0).kind) || !vs.get(0).v.matches("\\d+")) {
                throw new ExprException("时间窗函数第一个参数须为窗口秒数（整数）", start);
            }
            if (vs.size() < 2) {
                throw new ExprException("时间窗函数至少需要一个关联故障代码", start);
            }
            ExprAst.Cond c = new ExprAst.Cond();
            c.kind = "WINDOW";
            c.fn = name;
            c.seconds = Integer.valueOf(vs.get(0).v);
            for (int k = 1; k < vs.size(); k++) {
                c.codes.add(vs.get(k).v);
            }
            return ExprAst.cond(c);
        }

        private ExprAst and() {
            List<ExprAst> it = new ArrayList<ExprAst>();
            it.add(term());
            ws();
            while (pos < n && text.charAt(pos) == '&') {
                pos++;
                if (pos < n && text.charAt(pos) == '&') {
                    fail("请使用单个 & 表示且");
                }
                it.add(term());
                ws();
            }
            return ExprAst.flatten(ExprAst.Type.AND, it);
        }

        private ExprAst or() {
            List<ExprAst> it = new ArrayList<ExprAst>();
            it.add(and());
            ws();
            while (pos < n && text.charAt(pos) == '|') {
                pos++;
                if (pos < n && text.charAt(pos) == '|') {
                    fail("请使用单个 | 表示或");
                }
                it.add(and());
                ws();
            }
            return ExprAst.flatten(ExprAst.Type.OR, it);
        }

        private String matchOp(String rest) {
            String[] ops = {"==", "!=", ">=", "<=", "=~", ">", "<"};
            for (String op : ops) {
                if (rest.startsWith(op)) {
                    return op;
                }
            }
            return null;
        }

        private String matchIn(String rest) {
            if (rest.startsWith("NOT") && rest.length() > 3 && Character.isWhitespace(rest.charAt(3))) {
                int i = 3;
                while (i < rest.length() && Character.isWhitespace(rest.charAt(i))) {
                    i++;
                }
                if (rest.startsWith("IN", i)) {
                    int end = i + 2;
                    if (end < rest.length() && isIdentChar(rest.charAt(end))) {
                        return null;
                    }
                    return rest.substring(0, end);
                }
            }
            if (rest.startsWith("IN") && (rest.length() == 2 || !isIdentChar(rest.charAt(2)))) {
                return "IN";
            }
            return null;
        }

        private boolean isIdentStart(char c) {
            return c == '_' || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z');
        }

        private boolean isIdentChar(char c) {
            return isIdentStart(c) || (c >= '0' && c <= '9');
        }
    }
}
