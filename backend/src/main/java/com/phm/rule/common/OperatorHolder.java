package com.phm.rule.common;

/**
 * 当前请求的操作者。来自请求头 {@code X-Operator}，缺省为 system。
 * 写入各表的 create_by / update_by。
 */
public final class OperatorHolder {

    private static final ThreadLocal<String> CURRENT = new ThreadLocal<String>();

    private OperatorHolder() {
    }

    /**
     * 绑定当前线程的操作者。
     *
     * @param operator 操作者账号，空则视为 system
     */
    public static void set(String operator) {
        if (operator == null || operator.trim().isEmpty()) {
            CURRENT.remove();
            return;
        }
        String v = operator.trim();
        if (v.length() > 64) {
            v = v.substring(0, 64);
        }
        CURRENT.set(v);
    }

    /**
     * @return 当前操作者，默认 system
     */
    public static String get() {
        String v = CURRENT.get();
        return v == null ? "system" : v;
    }

    /**
     * 请求结束时清理，避免线程池复用串数据。
     */
    public static void clear() {
        CURRENT.remove();
    }
}
