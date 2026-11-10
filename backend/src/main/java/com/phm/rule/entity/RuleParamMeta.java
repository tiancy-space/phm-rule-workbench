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
    /** 数据源：KAFKA、HBASE、HBASE_PHM、HBASE_LKJ、HBASE_6A、DIM */
    private String dataSource;
    /** 实表名，未知为 - */
    private String hbaseTable;
    /** 适用车型，ALL 或逗号分隔 */
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
