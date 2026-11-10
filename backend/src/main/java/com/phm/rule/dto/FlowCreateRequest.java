package com.phm.rule.dto;

import lombok.Data;

/**
 * 新建空白流程。fault 表示给某条故障建专属流程，template 表示新建通用模板。
 */
@Data
public class FlowCreateRequest {

    /** fault 或 template */
    private String kind;

    /** kind=fault 时的故障主键 */
    private Long faultRuleId;

    /** 可选名称 */
    private String flowName;
}
