package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 处置步骤。序号 1 的步骤是起点。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_dispose_step")
public class DisposeStep extends BaseEntity {


    /** 流程版本主键 */
    private Long flowVerId;
    /** 版本内步骤编码，如 S1 */
    private String stepCode;
    /** 显示顺序 */
    private Integer seqNo;
    /** VIEW / JUDGE / OP / CONTACT / END */
    private String stepType;
    /** 标题 */
    private String stepTitle;
    /** 给专家看的说明 */
    private String stepDesc;
    /** 角色，逗号分隔 */
    private String roleCodes;
    /** 安全提示 */
    private String safetyTip;
    /** 司机手册条目 */
    private String manualRef;
    /** 司机动作 */
    private String driverAction;
    /** 结束结论 */
    private String conclusion;
    /** 1 回库并推送检修 */
    private Integer pushRepair;
}
