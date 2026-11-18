package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 规则测点参数元数据。原子、前置规则和数据卡都从这里选参数。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_rule_param_meta")
public class RuleParamMeta extends BaseEntity {


    /** 参数编码，大写，零 JSON 中直接书写 */
    private String paramCol;
    /** 中文名 */
    private String paramName;
    /** NUMBER / ENUM / STRING */
    private String dataType;
    /** 单位 */
    private String unit;
    /** 码表，编码:名称;编码:名称 */
    private String enumDict;
    /** 数据源：TCMS、6A、LKJ、DWD、DIM。旧值仍可能出现在未迁移的库里 */
    private String dataSource;
    /** 实表名，未知为 - */
    private String hbaseTable;
    /** 所属协议。车型过滤用它，不用 scopeCx */
    private Long protocolId;
    /** 所属子系统 */
    private String subsystem;
    /** 1 不出现在下拉，数据仍保留 */
    private Integer isHidden;
    /** RESERVED 预留 / HEADER 帧头 */
    private String hideReason;
    /** 已废弃。保留列，查询不再使用 */
    private String scopeCx;
    /** 页面是否可选 */
    private Integer isSelectable;
    /** 是否启用 */
    private Integer isEnabled;
    /** 备注 */
    private String remark;
    /** 修订号，乐观锁 */
    private Integer rev;
}
