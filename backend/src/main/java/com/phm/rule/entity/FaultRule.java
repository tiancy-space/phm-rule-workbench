package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 故障规则主表。粒度是车型 + 来源 + 故障代码。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_fault_rule")
public class FaultRule extends BaseEntity {


    /** 车型 */
    private String cx;
    /** TCMS / 6A */
    private String ly;
    /** 故障代码，保留原始写法 */
    private String gzdm;
    /** 故障名称 */
    private String gzmc;
    /** 模型名称 */
    private String mxmc;
    /** 健康等级 A/B/C/D */
    private String jkdj;
    /** CHECK / WATCH / NONE */
    private String czdj;
    /** CONDITIONAL / DIRECT / DISABLED / PENDING */
    private String ruleMode;
    /** A1…An 组合式 */
    private String ruleExpr;
    /** 展开后的零 JSON */
    private String faultRule;
    /** 中文释义 */
    private String ruleDesc;
    /** 是否参与诊断，由判定模式决定 */
    private Integer isEnabled;
    private String ljdm;
    private String ssxt;
    private String xtbm;
    private String xtpjm;
    private String ssbj;
    private String bjbm;
    private String bjpjm;
    private String sjlx;
    private String gzms;
    private String mxgzzs;
    private String description;
    private String version;
    private String configNote;
    private String srcRuleIds;
    private String legacyLogicExpr;
    private String remark;
    /** 修订号，保存时 +1 */
    private Integer rev;
}
