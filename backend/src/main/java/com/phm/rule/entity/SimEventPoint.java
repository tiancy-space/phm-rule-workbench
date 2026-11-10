package com.phm.rule.entity;
import java.math.BigDecimal;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 试跑数据点。时间是相对 T0 的秒偏移。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_sim_event_point")
public class SimEventPoint extends BaseEntity {


    /** 事件主键 */
    private Long eventId;
    /** SERIES / STATE / FAULT */
    private String pointType;
    /** 参数编码或故障代码 */
    private String objCode;
    /** 相对 T0 的秒 */
    private Integer offsetSec;
    /** 数值 */
    private BigDecimal numVal;
    /** 状态编码 */
    private String txtVal;
}
