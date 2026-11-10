package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;

/**
 * 启停开关。前置规则的启停立即生效，不需要再保存故障。
 */
@Data
public class EnabledRequest {

    /** 修订号 */
    @NotNull(message = "不能为空")
    private Integer rev;

    /** true 启用 */
    @NotNull(message = "不能为空")
    private Boolean enabled;
}
