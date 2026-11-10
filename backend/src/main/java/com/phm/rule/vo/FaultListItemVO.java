package com.phm.rule.vo;

import lombok.Data;

/**
 * 左栏故障卡片需要的摘要。
 */
@Data
public class FaultListItemVO {

    private Long id;
    private String cx;
    private String ly;
    private String gzdm;
    private String gzmc;
    private String mxmc;
    private String jkdj;
    private String czdj;
    private String ruleMode;
    private Integer isEnabled;
    private Integer rev;
    private String configNote;
    /** 已引入条件数 */
    private int refCount;
    /** 豁免的前置条数 */
    private int skipCount;
    /** 绑定的流程，没有则为空 */
    private Long flowId;
    private String flowCode;
    private String flowName;
    private String flowStatus;
    private Integer pubVerNo;
    private Integer isTemplate;
    /** 当前编辑版本的步数 */
    private int stepCount;
}
