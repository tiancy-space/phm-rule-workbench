package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 试跑事件里人工判断或操作步骤的预置答案，按步骤编码对应。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_sim_event_answer")
public class SimEventAnswer extends BaseEntity {


    /** 事件主键 */
    private Long eventId;
    /** 步骤编码 */
    private String stepCode;
    /** 分支名称 */
    private String answerLabel;
}
