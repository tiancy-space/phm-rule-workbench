package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 通用前置规则。先于组合规则执行，可按故障单条豁免。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_pre_filter_rule")
public class PreFilterRule extends BaseEntity {


    /** 编码，如 PF_LKJ_ZZZT */
    private String filterCode;
    /** 名称 */
    private String filterName;
    /** 参数主键 */
    private Long paramId;
    /** 参数编码 */
    private String paramCol;
    /** 比较符 */
    private String cmpOp;
    /** 目标值 */
    private String cmpVal;
    /** 适用车型，ALL 与具体车型互斥 */
    private String scopeCx;
    /** ALL / TCMS / 6A */
    private String scopeLy;
    /** BEFORE_HBASE / AFTER_HBASE */
    private String execTiming;
    /** 通过条件的零 JSON */
    private String filterExpr;
    /** 优先级，越小越先 */
    private Integer priority;
    /** 1 生效 */
    private Integer isEnabled;
    /** 备注 */
    private String remark;
    /** 修订号 */
    private Integer rev;
}
