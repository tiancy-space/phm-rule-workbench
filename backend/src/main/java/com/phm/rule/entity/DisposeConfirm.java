package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 步骤确认项。操作步骤选择成功前需要全部勾完。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_dispose_confirm")
public class DisposeConfirm extends BaseEntity {


    /** 步骤主键 */
    private Long stepId;
    /** 顺序 */
    private Integer seqNo;
    /** 确认内容 */
    private String confirmText;
    /** DRIVER / EXPERT / SYSTEM */
    private String roleCode;
    /** 1 必勾 */
    private Integer isRequired;
}
