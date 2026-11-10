package com.phm.rule.dto;

import lombok.Data;

/**
 * 零 JSON 反解析校验。不会修改当前故障。
 */
@Data
public class ExprCheckRequest {

    /** 待检查的表达式 */
    private String text;

    /** 若与当前组合展开结果比较，把展开式传在这里 */
    private String expect;
}
