package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 单条故障豁免的通用前置规则。有记录即该前置对该故障不生效。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_fault_pre_skip")
public class FaultPreSkip extends BaseEntity {


    /** 故障规则主键 */
    private Long faultRuleId;
    /** 前置规则主键 */
    private Long filterId;
    /** 豁免原因 */
    private String skipReason;
}
