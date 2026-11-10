package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 新建或修改共享原子。名称为空时按参数中文名自动生成。表达式由服务端生成。
 */
@Data
public class AtomSaveRequest {

    /** 修改时必填的修订号 */
    private Integer rev;

    /** 名称，可空 */
    private String atomName;

    /** PARAM 或 WINDOW */
    @NotBlank(message = "不能为空")
    private String atomType;

    /** ALL 或车型，多个用逗号 */
    @NotBlank(message = "不能为空")
    private String scopeCx;

    /** PARAM：参数编码 */
    private String paramCol;

    /** PARAM：比较符 */
    private String cmpOp;

    /** PARAM：目标值，缺失写 - */
    private String cmpVal;

    /** WINDOW：时间窗函数 */
    private String winFn;

    /** WINDOW：秒数 */
    private Integer winSec;

    /** WINDOW：关联故障代码，逗号分隔 */
    private String relGzdm;

    /** 备注 */
    private String remark;
}
