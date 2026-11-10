package com.phm.rule.expression;

/**
 * 表达式语法错误。{@link #pos} 为 0 起始的字符下标，与原型提示「第 pos+1 字符」对齐。
 */
public class ExprException extends RuntimeException {

    private final int pos;

    /**
     * @param message 中文原因
     * @param pos     出错位置，从 0 计
     */
    public ExprException(String message, int pos) {
        super(message);
        this.pos = pos;
    }

    /**
     * @return 0 起始的出错下标
     */
    public int getPos() {
        return pos;
    }
}
