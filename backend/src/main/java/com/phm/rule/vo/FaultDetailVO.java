package com.phm.rule.vo;

import com.phm.rule.expression.DisplayNode;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 故障规则编辑页：基本信息、引入清单、豁免、继承的前置，以及展开结果。
 */
@Data
public class FaultDetailVO {

    private Long id;
    private String cx;
    private String ly;
    private String gzdm;
    private String gzmc;
    private String mxmc;
    private String jkdj;
    private String czdj;
    private String ruleMode;
    private String ruleExpr;
    private String faultRule;
    private String ruleDesc;
    private String refExpr;
    private Integer isEnabled;
    private Integer rev;
    private String configNote;
    private String ssxt;
    private String ssbj;
    private String description;
    private String version;
    private String remark;
    private List<RefVO> refs = new ArrayList<RefVO>();
    private List<SkipVO> skips = new ArrayList<SkipVO>();
    private List<PreBriefVO> inheritedFilters = new ArrayList<PreBriefVO>();
    /** 组合式合法时给出展示树，供梯形图使用 */
    private DisplayNode display;
    private Long flowId;
    private String flowStatus;
    private Integer pubVerNo;
    private String flowName;
    private Integer isTemplate;
    private int stepCount;

    /**
     * 引入的一项。
     */
    @Data
    public static class RefVO {
        private Integer seqNo;
        private String alias;
        private String refType;
        private String code;
        private String name;
        private String expr;
        private String scopeCx;
    }

    /**
     * 被豁免的前置。
     */
    @Data
    public static class SkipVO {
        private Long filterId;
        private String filterCode;
        private String filterName;
        private String skipReason;
    }

    /**
     * 继承到的前置规则摘要。
     */
    @Data
    public static class PreBriefVO {
        private Long id;
        private String filterCode;
        private String filterName;
        private String execTiming;
        private Integer priority;
        private String filterExpr;
        private String scopeCx;
        private String scopeLy;
    }
}
