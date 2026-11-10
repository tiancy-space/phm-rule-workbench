package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * 在末尾或某一步之后添加步骤。
 */
@Data
public class StepCreateRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    /** VIEW / JUDGE / OP / CONTACT / END */
    @NotBlank(message = "不能为空")
    private String stepType;

    /** 插在该步骤之后；空表示加到末尾 */
    private Long afterStepId;
}
