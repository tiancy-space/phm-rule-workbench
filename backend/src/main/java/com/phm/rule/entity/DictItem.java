package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 通用字典项：车型、来源、判定模式、处置等级等枚举的显示名与排序。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_dict_item")
public class DictItem extends BaseEntity {


    /** 字典类型，如 CX、LY、CZDJ */
    private String dictType;
    /** 入库编码 */
    private String itemCode;
    /** 中文名称 */
    private String itemName;
    /** 说明 */
    private String itemDesc;
    /** 扩展值，如步骤类型的默认角色 */
    private String extVal;
    /** 排序号 */
    private Integer sortNo;
    /** 1 启用 0 停用 */
    private Integer isEnabled;
}
