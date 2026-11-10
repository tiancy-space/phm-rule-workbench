package com.phm.rule.dto;

import lombok.Data;

/**
 * 一条确认项。
 */
@Data
public class ConfirmItem {

    private String confirmText;
    /** DRIVER / EXPERT / SYSTEM */
    private String roleCode;
    /** 1 必勾，默认 1 */
    private Integer isRequired;
}
