package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;

/**
 * 按勾选结果重设绑定。一个故障只会留在本流程上，原来的绑定会被移走。
 */
@Data
public class FlowBindRequest {

    /** 本流程修订号 */
    @NotNull(message = "不能为空")
    private Integer rev;

    /** 最终仍绑定本流程的故障主键 */
    private List<Long> faultRuleIds = new ArrayList<Long>();
}
