package com.phm.rule.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 协议与车型的关系。一行只有一个协议和一个车型，同一车型可以挂多个协议。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_rule_protocol_cx")
public class RuleProtocolCx extends BaseEntity {

    /** 协议 ID */
    private Long protocolId;
    /** 车型编码 */
    private String cx;
}
