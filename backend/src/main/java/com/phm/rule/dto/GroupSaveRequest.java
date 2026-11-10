package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 新建或修改命名条件组。组合式只能引用原子编号。
 */
@Data
public class GroupSaveRequest {

    /** 修改时的修订号 */
    private Integer rev;

    /** 业务名称，不能包含 & | ( ) */
    @NotBlank(message = "不能为空")
    private String groupName;

    /** ALL 或车型 */
    @NotBlank(message = "不能为空")
    private String scopeCx;

    /** 如 (R001 & R002) | (R003 & R002) */
    @NotBlank(message = "不能为空")
    private String groupExpr;

    /** 备注 */
    private String remark;
}
