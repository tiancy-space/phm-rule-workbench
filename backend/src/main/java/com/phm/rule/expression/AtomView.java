package com.phm.rule.expression;

import java.util.ArrayList;
import java.util.List;

/**
 * 原子或命名组的表达式快照。type 取 PARAM、WINDOW、GROUP。
 */
public class AtomView {

    public String code;
    public String name;
    /** PARAM / WINDOW / GROUP */
    public String type;
    /** ALL 或车型（可逗号分隔） */
    public String scopeCx;
    public String field;
    public String op;
    public String value;
    public String fn;
    public Integer seconds;
    public List<String> codes = new ArrayList<String>();
    /** 仅 GROUP：以原子编号书写的组合式 */
    public String groupExpr;

    /**
     * @return 是否命名组
     */
    public boolean isGroup() {
        return "GROUP".equals(type);
    }

    /**
     * @return 是否时间窗原子
     */
    public boolean isWindow() {
        return "WINDOW".equals(type);
    }

    /**
     * 车型是否在适用范围内。ALL 或列表中包含该车型即适用。
     *
     * @param cx 车型
     * @return 是否适用
     */
    public boolean fits(String cx) {
        if (scopeCx == null || scopeCx.trim().isEmpty() || "ALL".equals(scopeCx.trim())) {
            return true;
        }
        for (String p : scopeCx.split(",")) {
            if (p.trim().equals(cx)) {
                return true;
            }
        }
        return false;
    }
}
