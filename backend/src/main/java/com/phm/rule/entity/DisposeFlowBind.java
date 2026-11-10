package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 流程与故障的绑定。一个故障只能绑定一套流程。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_dispose_flow_bind")
public class DisposeFlowBind extends BaseEntity {


    /** 流程主键 */
    private Long flowId;
    /** 故障规则主键 */
    private Long faultRuleId;
}
