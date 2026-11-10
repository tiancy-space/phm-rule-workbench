package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 命名条件组。组内只引用原子，展开式才是引擎执行内容。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_rule_group")
public class RuleGroup extends BaseEntity {


    /** 组编号，如 G001 */
    private String groupCode;
    /** 组名称，全局唯一 */
    private String groupName;
    /** 适用车型 */
    private String scopeCx;
    /** 以原子编号书写的组合式 */
    private String groupExpr;
    /** 展开后的零 JSON */
    private String expandExpr;
    /** 现场说法 */
    private String groupDesc;
    /** 1 启用 */
    private Integer isEnabled;
    /** 备注 */
    private String remark;
    /** 修订号 */
    private Integer rev;
}
