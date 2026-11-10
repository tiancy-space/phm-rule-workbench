package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 共享原子规则。PARAM 为测点比较，WINDOW 为关联故障时间窗。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_rule_atom")
public class RuleAtom extends BaseEntity {


    /** 原子编号，如 R001 */
    private String atomCode;
    /** 中文名称 */
    private String atomName;
    /** PARAM / WINDOW */
    private String atomType;
    /** 适用车型 */
    private String scopeCx;
    /** 参数主键，WINDOW 为空 */
    private Long paramId;
    /** 参数编码冗余 */
    private String paramCol;
    /** 比较符 */
    private String cmpOp;
    /** 目标值，缺失写 - */
    private String cmpVal;
    /** 时间窗函数 */
    private String winFn;
    /** 窗口秒数 */
    private Integer winSec;
    /** 关联故障代码，逗号分隔 */
    private String relGzdm;
    /** 零 JSON 片段 */
    private String atomExpr;
    /** 1 启用 */
    private Integer isEnabled;
    /** 备注 */
    private String remark;
    /** 修订号 */
    private Integer rev;
}
