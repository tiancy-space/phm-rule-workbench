package com.phm.rule.common;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 车型范围、编号和逗号字段的小工具。不依赖数据库。
 */
public final class Texts {

    /** 比较符，与表上的检查约束一致 */
    public static final List<String> CMP_OPS = Arrays.asList("==", "!=", ">", ">=", "<", "<=", "IN", "NOT IN", "=~");

    /** 时间窗函数 */
    public static final List<String> WIN_FNS = Arrays.asList("allNotExists", "anyExists", "allExists", "anyNotExists");

    private static final List<String> RUN_INFO = Arrays.asList("CC", "SD", "WZ", "JL", "SJ", "FSSJ");

    private Texts() {
    }

    /**
     * 整理适用车型。ALL 可以按调用方要求与具体车型互斥。
     *
     * @param raw          原文
     * @param allExclusive 是否禁止 ALL 和具体车型同时出现
     * @return ALL 或逗号分隔车型
     */
    public static String scope(String raw, boolean allExclusive) {
        if (raw == null || raw.trim().isEmpty()) {
            throw BizException.bad("适用车型不能为空");
        }
        LinkedHashSet<String> set = new LinkedHashSet<String>();
        for (String part : raw.split(",")) {
            String t = part.trim();
            if (t.isEmpty()) {
                continue;
            }
            set.add("ALL".equalsIgnoreCase(t) ? "ALL" : t);
        }
        if (set.isEmpty()) {
            throw BizException.bad("适用车型不能为空");
        }
        if (set.contains("ALL")) {
            if (allExclusive && set.size() > 1) {
                throw BizException.bad("适用车型 ALL 与具体车型互斥");
            }
            return "ALL";
        }
        return join(set);
    }

    /**
     * 生成下一个业务编号，例如 R001、G002、FT03。已占用的编号（含逻辑删除）都要传进来。
     *
     * @param prefix   前缀
     * @param width    数字位数
     * @param existing 已有编号
     * @return 新编号
     */
    public static String nextCode(String prefix, int width, List<String> existing) {
        int max = 0;
        if (existing != null) {
            for (String code : existing) {
                if (code == null || !code.startsWith(prefix)) {
                    continue;
                }
                String tail = code.substring(prefix.length());
                if (tail.matches("\\d+")) {
                    max = Math.max(max, Integer.parseInt(tail));
                }
            }
        }
        return prefix + String.format("%0" + width + "d", max + 1);
    }

    /**
     * 只保留允许的运行信息字段，并保持固定顺序。
     *
     * @param raw 逗号分隔
     * @return 规范化结果，空输入用默认的车次、速度、位置、司机、发生时间
     */
    public static String runInfo(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return "CC,SD,WZ,SJ,FSSJ";
        }
        List<String> keep = new ArrayList<String>();
        Set<String> wanted = new LinkedHashSet<String>();
        for (String p : raw.split(",")) {
            wanted.add(p.trim().toUpperCase());
        }
        for (String code : RUN_INFO) {
            if (wanted.contains(code)) {
                keep.add(code);
            }
        }
        if (keep.isEmpty()) {
            throw BizException.bad("请至少选择一项运行信息");
        }
        return join(keep);
    }

    /**
     * @param parts 片段
     * @return 逗号拼接
     */
    public static String join(Iterable<String> parts) {
        StringBuilder sb = new StringBuilder();
        for (String p : parts) {
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(p);
        }
        return sb.toString();
    }

    /**
     * 按逗号拆开并去掉空白。
     *
     * @param raw 原文
     * @return 列表
     */
    public static List<String> splitComma(String raw) {
        List<String> out = new ArrayList<String>();
        if (raw == null || raw.trim().isEmpty()) {
            return out;
        }
        for (String p : raw.split(",")) {
            if (!p.trim().isEmpty()) {
                out.add(p.trim());
            }
        }
        return out;
    }

    /**
     * 要求比较符在允许列表里。
     *
     * @param op 比较符
     */
    public static void requireOp(String op) {
        if (op == null || !CMP_OPS.contains(op)) {
            throw BizException.bad("比较符不支持：" + op);
        }
    }
}
