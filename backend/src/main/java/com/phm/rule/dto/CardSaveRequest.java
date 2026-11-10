package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * 新增或修改数据卡。
 */
@Data
public class CardSaveRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    /** NUM / STATE / FAULT */
    @NotBlank(message = "不能为空")
    private String cardKind;

    /** NUM、STATE 的参数编码 */
    private String paramCol;

    /** FAULT 的故障代码，逗号分隔 */
    private String relGzdm;

    private Integer winPreSec;
    private Integer winPostSec;

    /** 统计项，逗号分隔 */
    private String statItems;

    private Integer showCurve;
    private String limitOp;
    private String limitVal;
    private String targetVal;
}
