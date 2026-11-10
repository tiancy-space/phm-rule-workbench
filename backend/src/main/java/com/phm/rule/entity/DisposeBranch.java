package com.phm.rule.entity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 步骤出口。按序号从上到下判定，第一个成立的作为系统预判。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_dispose_branch")
public class DisposeBranch extends BaseEntity {


    /** 所属步骤 */
    private Long stepId;
    /** 判定顺序 */
    private Integer seqNo;
    /** 分支名称 */
    private String branchLabel;
    /** 去向步骤，空表示未配置 */
    private Long nextStepId;
    /** NONE / CARD / ATOM / GROUP / ELSE */
    private String condSrc;
    /** 引用的数据卡 */
    private Long condCardId;
    /** 统计项 */
    private String condStat;
    /** 比较符 */
    private String condOp;
    /** 阈值 */
    private String condVal;
    /** 原子主键 */
    private Long condAtomId;
    /** 命名组主键 */
    private Long condGroupId;
}
