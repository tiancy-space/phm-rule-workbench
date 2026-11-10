package com.phm.rule.expression;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * 组合式解析器。故障规则只接受 A1、A2…；命名组只接受原子编号 R001…。
 * 语法与原型 parseLogic 相同：空白忽略，{@code &} 优先于 {@code |}，括号改变优先级。
 */
public class LogicParser {

    /**
     * 解析故障组合式。
     *
     * @param text     原文，如 {@code A1 & A2 & (A3 | A4)}
     * @param refCodes 下标 0 对应 A1 的原子或命名组编号
     * @return 语法树
     */
    public ExprAst parseAlias(String text, List<String> refCodes) {
        return parse(text == null ? "" : text, new AliasLeaf(refCodes));
    }

    /**
     * 解析命名组组合式。组内不能再嵌套命名组，因此只认原子编号。
     *
     * @param text      原文，如 {@code (R001 & R002) | (R003 & R002)}
     * @param atomCodes 当前原子库编号
     * @return 语法树
     */
    public ExprAst parseGroup(String text, Set<String> atomCodes) {
        if (text == null || text.trim().isEmpty()) {
            throw new ExprException("请写组合式，如 (R001 & R002) | (R003 & R002)", 0);
        }
        return parse(text, new GroupLeaf(atomCodes));
    }

    private ExprAst parse(String text, LeafReader leaf) {
        Parser p = new Parser(text, leaf);
        return p.parseRoot();
    }

    private interface LeafReader {
        /**
         * 从当前位置读一个叶子。
         *
         * @param text 全文
         * @param pos  当前位置
         * @return 读到的叶子以及消耗的字符数
         */
        Read read(String text, int pos);
    }

    private static final class Read {
        final int len;
        final ExprAst node;

        Read(int len, ExprAst node) {
            this.len = len;
            this.node = node;
        }
    }

    private static final class AliasLeaf implements LeafReader {
        private final List<String> refs;

        AliasLeaf(List<String> refs) {
            this.refs = refs == null ? new ArrayList<String>() : refs;
        }

        @Override
        public Read read(String text, int pos) {
            String s = text.substring(pos);
            int i = 0;
            if (s.isEmpty() || s.charAt(0) != 'A') {
                failNeed(s, pos);
            }
            i = 1;
            if (i >= s.length() || s.charAt(i) < '1' || s.charAt(i) > '9') {
                failNeed(s, pos);
            }
            i++;
            while (i < s.length() && s.charAt(i) >= '0' && s.charAt(i) <= '9') {
                i++;
            }
            String alias = s.substring(0, i);
            int index = Integer.parseInt(alias.substring(1)) - 1;
            if (index < 0 || index >= refs.size() || refs.get(index) == null) {
                throw new ExprException("未引入的原子代号 " + alias, pos);
            }
            return new Read(alias.length(), ExprAst.ref(alias, refs.get(index)));
        }

        private void failNeed(String s, int pos) {
            if (s.trim().isEmpty()) {
                throw new ExprException("表达式尚未完成，需要原子代号或左括号", pos);
            }
            throw new ExprException("此处需要原子代号（如 A1）或左括号", pos);
        }
    }

    private static final class GroupLeaf implements LeafReader {
        private final Set<String> atoms;

        GroupLeaf(Set<String> atoms) {
            this.atoms = atoms;
        }

        @Override
        public Read read(String text, int pos) {
            String s = text.substring(pos);
            if (s.isEmpty() || s.charAt(0) != 'R') {
                if (s.trim().isEmpty()) {
                    throw new ExprException("组合式尚未完成，需要原子编号或左括号", pos);
                }
                throw new ExprException("此处需要原子编号（如 R001）或左括号", pos);
            }
            int i = 1;
            int digits = 0;
            while (i < s.length() && s.charAt(i) >= '0' && s.charAt(i) <= '9') {
                digits++;
                i++;
            }
            if (digits < 3) {
                throw new ExprException("此处需要原子编号（如 R001）或左括号", pos);
            }
            String code = s.substring(0, i);
            if (atoms == null || !atoms.contains(code)) {
                throw new ExprException("原子库中不存在 " + code, pos);
            }
            return new Read(code.length(), ExprAst.ref(code, code));
        }
    }

    /**
     * 递归下降。公开方法都在外层，内部状态只服务一次解析。
     */
    private static final class Parser {
        private final String text;
        private final int n;
        private final LeafReader leaf;
        private int pos;

        Parser(String text, LeafReader leaf) {
            this.text = text;
            this.n = text.length();
            this.leaf = leaf;
        }

        ExprAst parseRoot() {
            if (n > 4000) {
                throw new ExprException("表达式超过 4000 字符限制", 4000);
            }
            int parens = 0;
            for (int i = 0; i < n; i++) {
                if (text.charAt(i) == '(') {
                    parens++;
                }
            }
            if (parens > 80) {
                throw new ExprException("括号层数过多，请拆分规则", 0);
            }
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

        private ExprAst term() {
            ws();
            if (pos < n && text.charAt(pos) == '(') {
                pos++;
                ExprAst node = or();
                ws();
                if (pos >= n || text.charAt(pos) != ')') {
                    throw new ExprException("缺少右括号 )", pos);
                }
                pos++;
                return node;
            }
            Read r = leaf.read(text, pos);
            pos += r.len;
            return r.node;
        }

        private ExprAst and() {
            List<ExprAst> it = new ArrayList<ExprAst>();
            it.add(term());
            ws();
            while (pos < n && text.charAt(pos) == '&') {
                pos++;
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
                it.add(and());
                ws();
            }
            return ExprAst.flatten(ExprAst.Type.OR, it);
        }
    }
}
