package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * 新增或修改通用前置规则。ALL 与具体车型互斥。查 HBase 前只能用 KAFKA 或 DIM 参数。
 */
@Data
public class PreFilterSaveRequest {

    /** 修改时的修订号 */
    private Integer rev;

    /** 名称 */
    @NotBlank(message = "不能为空")
    private String filterName;

    /** 参数编码 */
    @NotBlank(message = "不能为空")
    private String paramCol;

    /** 比较符 */
    @NotBlank(message = "不能为空")
    private String cmpOp;

    /** 目标值 */
    @NotBlank(message = "不能为空")
    private String cmpVal;

    /** 适用车型 */
    @NotBlank(message = "不能为空")
    private String scopeCx;

    /** ALL / TCMS / 6A */
    @NotBlank(message = "不能为空")
    private String scopeLy;

    /** BEFORE_HBASE / AFTER_HBASE */
    @NotBlank(message = "不能为空")
    private String execTiming;

    /** 优先级，越小越先 */
    @NotNull(message = "不能为空")
    private Integer priority;

    /** 备注 */
    private String remark;
}
