package com.phm.rule.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 试跑事件，以及某一步的数据卡统计和系统预判。
 */
@Data
public class TrialVO {

    private Long id;
    private String eventCode;
    private Long faultRuleId;
    private String cx;
    private String ly;
    private String gzdm;
    private String eventTitle;
    private String expectOutcome;
    private String cc;
    private String sd;
    private String wz;
    private String jl;
    private String sjxm;
    private String fssj;
    private Integer isSample;
    /** 参数编码到曲线点 [偏移秒, 数值] */
    private Map<String, List<double[]>> series = new LinkedHashMap<String, List<double[]>>();
    /** 参数编码到变位点 [偏移秒] 与状态编码 */
    private Map<String, List<StatePoint>> states = new LinkedHashMap<String, List<StatePoint>>();
    /** 关联故障出现时刻 */
    private List<FaultHit> faults = new ArrayList<FaultHit>();
    /** 步骤编码到预置答案 */
    private Map<String, String> answers = new LinkedHashMap<String, String>();

    /**
     * 状态变位点。
     */
    @Data
    public static class StatePoint {
        private int t;
        private String val;
    }

    /**
     * 故障出现点。
     */
    @Data
    public static class FaultHit {
        private String code;
        private int t;
    }

    /**
     * 单步试跑结果。
     */
    @Data
    public static class StepEval {
        private Long stepId;
        private String stepCode;
        private String stepType;
        private List<CardEval> cards = new ArrayList<CardEval>();
        /** 系统预判的分支名，无法预判时为空 */
        private String prejudgeLabel;
        private String prejudgeReason;
        /** 事件里记录的人工答案 */
        private String recordedAnswer;
    }

    /**
     * 一张卡的统计结果，供曲线和数值展示。
     */
    @Data
    public static class CardEval {
        private Long cardId;
        private String cardCode;
        private String cardKind;
        private String paramCol;
        private String paramName;
        private String unit;
        private String enumDict;
        private boolean none;
        private String limitOp;
        private String limitVal;
        private String targetVal;
        /** 统计项到展示文本 */
        private Map<String, String> stats = new LinkedHashMap<String, String>();
        /** 数值曲线点 */
        private List<double[]> points = new ArrayList<double[]>();
        /** 状态变位说明 */
        private List<String> changes = new ArrayList<String>();
        /** 关联故障命中说明 */
        private List<String> hits = new ArrayList<String>();
    }
}
