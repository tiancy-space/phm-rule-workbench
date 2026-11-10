package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 步骤数据卡。以故障时刻 T0 为锚点取窗口数据。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_dispose_card")
public class DisposeCard extends BaseEntity {


    /** 步骤主键 */
    private Long stepId;
    /** 卡片编码，如 C1 */
    private String cardCode;
    /** 显示顺序 */
    private Integer seqNo;
    /** NUM / STATE / FAULT */
    private String cardKind;
    /** 参数主键 */
    private Long paramId;
    /** 参数编码 */
    private String paramCol;
    /** 关联故障代码 */
    private String relGzdm;
    /** T0 前秒数 */
    private Integer winPreSec;
    /** T0 后秒数 */
    private Integer winPostSec;
    /** 统计项，逗号分隔 */
    private String statItems;
    /** 1 显示曲线 */
    private Integer showCurve;
    /** 越限比较符 */
    private String limitOp;
    /** 越限阈值 */
    private String limitVal;
    /** 状态目标值 */
    private String targetVal;
}
