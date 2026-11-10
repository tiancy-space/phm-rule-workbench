package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 处置流程头。专属流程或通用模板，内容挂在版本上。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_dispose_flow")
public class DisposeFlow extends BaseEntity {


    /** 流程编码 */
    private String flowCode;
    /** 当前工作名称 */
    private String flowName;
    /** 1 通用模板 */
    private Integer isTemplate;
    /** DRAFT / PUBLISHED / DISABLED */
    private String flowStatus;
    /** 当前生效版本号，0 表示从未发布 */
    private Integer pubVerNo;
    /** 1 示例内容 */
    private Integer isSample;
    /** 示例提示 */
    private String sampleNote;
    /** 备注 */
    private String remark;
    /** 修订号 */
    private Integer rev;
}
