package com.phm.rule.expression;

/**
 * 表达式引擎使用的参数元数据快照。
 */
public class ParamView {

    /** 参数编码 */
    public String code;
    /** 中文名 */
    public String name;
    /** NUMBER / ENUM / STRING */
    public String dataType;
    /** 单位，可空 */
    public String unit;
    /** 码表，编码:名称;编码:名称 */
    public String enumDict;
    /** 数据源 */
    public String dataSource;
    /** 适用车型，ALL 或逗号分隔 */
    public String scopeCx;

    /**
     * @param cx 车型
     * @return 该参数是否适用于此车型
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
