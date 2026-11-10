package com.phm.rule.dto;

import lombok.Data;

/**
 * 一条出口。去向和数据卡用主键，服务端在复制草稿时会把旧主键映射到新主键。
 */
@Data
public class BranchItem {

    private String branchLabel;
    private Long nextStepId;
    /** NONE / CARD / ATOM / GROUP / ELSE */
    private String condSrc;
    private Long condCardId;
    private String condStat;
    private String condOp;
    private String condVal;
    private Long condAtomId;
    private Long condGroupId;
}
