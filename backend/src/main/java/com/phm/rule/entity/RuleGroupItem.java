package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 命名组成员。保存组时按组合式重建，用于引用检查。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_rule_group_item")
public class RuleGroupItem extends BaseEntity {


    /** 命名组主键 */
    private Long groupId;
    /** 原子主键 */
    private Long atomId;
    /** 在组合式中首次出现的顺序 */
    private Integer seqNo;
}
