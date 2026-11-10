package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * 把专属流程存成通用模板。migrateBindings 为真时原流程直接改为模板。
 */
@Data
public class SaveTemplateRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    @NotBlank(message = "不能为空")
    private String flowName;

    /** 为真：原流程转为模板；为假：另复制一份草稿模板 */
    private boolean migrateBindings;
}
