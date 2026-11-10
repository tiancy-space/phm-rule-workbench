package com.phm.rule.expression;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * 逻辑表达式抽象语法树。与原型一致：且优先于或，同级节点会被拍平。
 * 叶子有两种：组合式里的引用（A1 / R001），或零 JSON 里已经解析出的条件。
 */
public class ExprAst {

    /**
     * 节点类型。
     */
    public enum Type {
        /** 且，子节点全部成立 */
        AND,
        /** 或，任一子节点成立 */
        OR,
        /** 叶子 */
        LEAF
    }

    private final Type type;
    private final List<ExprAst> children;
    /** 组合式代号，如 A1、R001 */
    private final String alias;
    /** 叶子指向的原子或命名组编号 */
    private final String refCode;
    /** 零 JSON 叶子上的具体条件；组合式叶子为空 */
    private final Cond cond;

    private ExprAst(Type type, List<ExprAst> children, String alias, String refCode, Cond cond) {
        this.type = type;
        this.children = children == null ? Collections.<ExprAst>emptyList() : Collections.unmodifiableList(children);
        this.alias = alias;
        this.refCode = refCode;
        this.cond = cond;
    }

    /**
     * 把同类型的子节点拍平；只剩一个子节点时直接返回该子节点（与原型 mkNode 一致）。
     *
     * @param type  且 / 或
     * @param items 子节点
     * @return 拍平后的节点
     */
    public static ExprAst flatten(Type type, List<ExprAst> items) {
        List<ExprAst> ch = new ArrayList<ExprAst>();
        for (ExprAst c : items) {
            if (c.type == type) {
                ch.addAll(c.children);
            } else {
                ch.add(c);
            }
        }
        if (ch.size() == 1) {
            return ch.get(0);
        }
        return new ExprAst(type, ch, null, null, null);
    }

    /**
     * 组合式叶子。
     *
     * @param alias   显示代号
     * @param refCode 原子或命名组编号
     * @return 叶子
     */
    public static ExprAst ref(String alias, String refCode) {
        return new ExprAst(Type.LEAF, null, alias, refCode, null);
    }

    /**
     * 零 JSON 叶子。
     *
     * @param cond 条件
     * @return 叶子
     */
    public static ExprAst cond(Cond cond) {
        return new ExprAst(Type.LEAF, null, null, null, cond);
    }

    /**
     * @return 节点类型
     */
    public Type getType() {
        return type;
    }

    /**
     * @return 是否叶子
     */
    public boolean isLeaf() {
        return type == Type.LEAF;
    }

    /**
     * @return 子节点，叶子为空列表
     */
    public List<ExprAst> getChildren() {
        return children;
    }

    /**
     * @return 代号
     */
    public String getAlias() {
        return alias;
    }

    /**
     * @return 引用编号
     */
    public String getRefCode() {
        return refCode;
    }

    /**
     * @return 零 JSON 条件，组合式叶子为 null
     */
    public Cond getCond() {
        return cond;
    }

    /**
     * 参数比较或时间窗条件。字段含义与原子规则列一致。
     */
    public static final class Cond {
        /** PARAM 或 WINDOW */
        public String kind;
        public String field;
        public String op;
        public String value;
        public String fn;
        public Integer seconds;
        public List<String> codes = new ArrayList<String>();

        /**
         * @return 是否时间窗
         */
        public boolean isWindow() {
            return "WINDOW".equals(kind);
        }
    }
}
