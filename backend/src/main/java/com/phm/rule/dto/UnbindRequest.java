package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;

/**
 * 从流程上解绑一条故障。专属流程至少保留一个绑定。
 */
@Data
public class UnbindRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    @NotNull(message = "不能为空")
    private Long faultRuleId;
}
