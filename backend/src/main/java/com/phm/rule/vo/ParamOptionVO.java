package com.phm.rule.vo;

import lombok.Data;

/**
 * 参数下拉用的轻量行。不带码表和审计字段，一次可以返回某个数据源的全部可见参数。
 */
@Data
public class ParamOptionVO {

    private Long id;
    /** 参数编码 */
    private String paramCol;
    /** 中文名 */
    private String paramName;
    /** 单位，没有则为空 */
    private String unit;
    /** NUMBER / ENUM / STRING */
    private String dataType;
    /** 所属子系统，空的在页面上归到「未分类」 */
    private String subsystem;
    /** TCMS / 6A / LKJ / DWD / DIM */
    private String dataSource;
}
