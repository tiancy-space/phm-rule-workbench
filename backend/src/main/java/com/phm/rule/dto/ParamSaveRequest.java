package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 新建或修改参数元数据。
 */
@Data
public class ParamSaveRequest {

    /** 修改时的修订号 */
    private Integer rev;

    /** 参数编码，会转成大写 */
    @NotBlank(message = "不能为空")
    private String paramCol;

    /** 中文名 */
    @NotBlank(message = "不能为空")
    private String paramName;

    /** NUMBER / ENUM / STRING */
    @NotBlank(message = "不能为空")
    private String dataType;

    /** 单位 */
    private String unit;

    /** 码表 */
    private String enumDict;

    /** 数据源 */
    @NotBlank(message = "不能为空")
    private String dataSource;

    /** 实表名，不知道就空着，系统记为 - */
    private String hbaseTable;

    /** 适用车型 */
    private String scopeCx;

    /** 备注 */
    private String remark;
}
