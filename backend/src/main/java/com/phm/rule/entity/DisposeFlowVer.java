package com.phm.rule.entity;
import java.time.LocalDateTime;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 处置流程版本。同一流程最多一个草稿和一个已发布版本。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_phm_dispose_flow_ver")
public class DisposeFlowVer extends BaseEntity {


    /** 流程主键 */
    private Long flowId;
    /** 版本号 */
    private Integer verNo;
    /** DRAFT / PUBLISHED / ARCHIVED */
    private String verStatus;
    /** 草稿基于的已发布版本，0 表示全新 */
    private Integer baseVerNo;
    /** 该版本的名称快照 */
    private String flowName;
    /** T0 前秒数 */
    private Integer winPreSec;
    /** T0 后秒数 */
    private Integer winPostSec;
    /** 运行信息字段，逗号分隔 */
    private String runInfoCols;
    /** 发布人 */
    private String publishBy;
    /** 发布时间 */
    private LocalDateTime publishTime;
}
