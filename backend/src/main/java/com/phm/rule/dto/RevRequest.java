package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;

/**
 * 只携带修订号的请求，用于发布、删除等。
 */
@Data
public class RevRequest {

    @NotNull(message = "不能为空")
    private Integer rev;
}
