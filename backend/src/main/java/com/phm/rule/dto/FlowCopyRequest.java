package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;

/**
 * 把一套流程复制成某故障的专属草稿。
 */
@Data
public class FlowCopyRequest {

    /** 目标故障 */
    @NotNull(message = "不能为空")
    private Long faultRuleId;

    /** 来源流程的修订号；复制不修改来源，这里只用于发现来源已被删除 */
    private Integer rev;
}
