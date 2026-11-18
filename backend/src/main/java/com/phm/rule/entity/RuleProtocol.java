package com.phm.rule.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 采集协议。一个 Kafka 主题一行，另有 DWD、DIM 两个虚拟协议。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_rule_protocol")
public class RuleProtocol extends BaseEntity {

    /** 协议编码，Kafka 主题或 DWD / DIM */
    private String protocolCode;
    /** 协议名称。DWD 在页面上叫故障实时字段 */
    private String protocolName;
    /** TCMS / 6A / LKJ / DWD / DIM */
    private String dataSource;
    /** 实表名，没有则是 - */
    private String hbaseTable;
    /** 1 启用 0 停用 */
    private Integer isEnabled;
    /** 备注 */
    private String remark;
    /** 修订号 */
    private Integer rev;
}
