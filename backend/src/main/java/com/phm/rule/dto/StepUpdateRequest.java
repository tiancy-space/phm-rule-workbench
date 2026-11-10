package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 修改步骤基本信息。切换类型时服务端会按新类型重置角色和出口，并尽量保留原来的去向。
 */
@Data
public class StepUpdateRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    private String stepType;
    private String stepTitle;
    private String stepDesc;
    /** 角色编码列表 */
    private List<String> roleCodes;
    private String safetyTip;
    private String manualRef;
    private String driverAction;
    /** 仅结束步骤 */
    private String conclusion;
    /** 1 回库并推送检修 */
    private Integer pushRepair;
}
