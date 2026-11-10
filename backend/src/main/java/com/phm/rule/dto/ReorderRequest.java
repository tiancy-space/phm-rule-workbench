package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 按给出的步骤主键顺序重排。第一位就是流程起点。
 */
@Data
public class ReorderRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    private List<Long> stepIds;
}
