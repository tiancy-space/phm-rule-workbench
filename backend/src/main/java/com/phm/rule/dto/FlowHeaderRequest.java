package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * 修改流程名称、默认取数窗口和处置单顶部运行信息。已发布流程会先复制出草稿。
 */
@Data
public class FlowHeaderRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    @NotBlank(message = "不能为空")
    private String flowName;

    @NotNull(message = "不能为空")
    private Integer winPreSec;

    @NotNull(message = "不能为空")
    private Integer winPostSec;

    /** 逗号分隔：CC,SD,WZ,JL,SJ,FSSJ */
    private String runInfoCols;
}
