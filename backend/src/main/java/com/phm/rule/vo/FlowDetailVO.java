package com.phm.rule.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 处置流程编辑态。steps 属于当前正在编辑的版本（有草稿用草稿，否则用已发布版本）。
 */
@Data
public class FlowDetailVO {

    private Long id;
    private String flowCode;
    private String flowName;
    private Integer isTemplate;
    private String flowStatus;
    private Integer pubVerNo;
    private Integer isSample;
    private String sampleNote;
    private Integer rev;
    /** 正在编辑的版本号 */
    private Integer editingVerNo;
    /** 草稿所基于的已发布版本，0 表示全新草稿 */
    private Integer baseVerNo;
    private String verStatus;
    private Integer winPreSec;
    private Integer winPostSec;
    private String runInfoCols;
    private List<BindVO> bindings = new ArrayList<BindVO>();
    private List<StepVO> steps = new ArrayList<StepVO>();
    private List<String> errors = new ArrayList<String>();
    private List<String> warnings = new ArrayList<String>();
    /** 套用后参数不适用于车型时的提示 */
    private List<String> notices = new ArrayList<String>();

    /**
     * 绑定的故障。
     */
    @Data
    public static class BindVO {
        private Long faultRuleId;
        private String cx;
        private String ly;
        private String gzdm;
        private String gzmc;
        private String czdj;
    }

    /**
     * 步骤及其数据卡、出口、确认项。
     */
    @Data
    public static class StepVO {
        private Long id;
        private String stepCode;
        private Integer seqNo;
        private String stepType;
        private String stepTitle;
        private String stepDesc;
        private List<String> roleCodes = new ArrayList<String>();
        private String safetyTip;
        private String manualRef;
        private String driverAction;
        private String conclusion;
        private Integer pushRepair;
        private List<CardVO> cards = new ArrayList<CardVO>();
        private List<BranchVO> branches = new ArrayList<BranchVO>();
        private List<ConfirmVO> confirms = new ArrayList<ConfirmVO>();
    }

    /**
     * 数据卡。
     */
    @Data
    public static class CardVO {
        private Long id;
        private String cardCode;
        private Integer seqNo;
        private String cardKind;
        private Long paramId;
        private String paramCol;
        private String paramName;
        private String unit;
        private String dataType;
        private String enumDict;
        private String relGzdm;
        private Integer winPreSec;
        private Integer winPostSec;
        private String statItems;
        private Integer showCurve;
        private String limitOp;
        private String limitVal;
        private String targetVal;
        /** 不适用于哪些绑定车型 */
        private List<String> unfitCx = new ArrayList<String>();
    }

    /**
     * 出口。
     */
    @Data
    public static class BranchVO {
        private Long id;
        private Integer seqNo;
        private String branchLabel;
        private Long nextStepId;
        private String nextStepCode;
        private String condSrc;
        private Long condCardId;
        private String condStat;
        private String condOp;
        private String condVal;
        private Long condAtomId;
        private String condAtomCode;
        private Long condGroupId;
        private String condGroupCode;
    }

    /**
     * 确认项。
     */
    @Data
    public static class ConfirmVO {
        private Long id;
        private Integer seqNo;
        private String confirmText;
        private String roleCode;
        private Integer isRequired;
    }
}
