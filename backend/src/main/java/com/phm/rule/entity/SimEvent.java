package com.phm.rule.entity;
import java.time.LocalDateTime;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 历史故障试跑事件。一期为模拟数据，T0 等于发生时间。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_sim_event")
public class SimEvent extends BaseEntity {


    /** 事件编码 */
    private String eventCode;
    /** 故障规则主键 */
    private Long faultRuleId;
    /** 标题 */
    private String eventTitle;
    /** 预期走向 */
    private String expectOutcome;
    /** 车次 */
    private String cc;
    /** 速度文本 */
    private String sd;
    /** 位置 */
    private String wz;
    /** 交路 */
    private String jl;
    /** 司机（脱敏） */
    private String sjxm;
    /** 发生时间 T0 */
    private LocalDateTime fssj;
    /** 1 模拟数据 */
    private Integer isSample;
}
