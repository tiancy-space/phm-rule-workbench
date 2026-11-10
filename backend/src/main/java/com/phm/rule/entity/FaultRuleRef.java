package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 故障规则引入的原子或命名组。seq_no=n 即局部代号 An。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_fault_rule_ref")
public class FaultRuleRef extends BaseEntity {


    /** 故障规则主键 */
    private Long faultRuleId;
    /** 1 表示 A1 */
    private Integer seqNo;
    /** ATOM / GROUP */
    private String refType;
    /** 原子主键 */
    private Long atomId;
    /** 命名组主键 */
    private Long groupId;
}
