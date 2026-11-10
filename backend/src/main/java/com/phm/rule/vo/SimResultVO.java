package com.phm.rule.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 模拟测点试算结果。前置全部通过且组合成立才算命中。
 */
@Data
public class SimResultVO {

    /** 最终是否报出 */
    private boolean hit;
    /** 前置是否全部通过 */
    private boolean prePassed;
    /** 组合是否成立 */
    private boolean comboPassed;
    private int preTotal;
    private int preOk;
    private String summary;
    private List<Row> rows = new ArrayList<Row>();
    /** 填充样例时回传建议值 */
    private Map<String, String> values = new LinkedHashMap<String, String>();
    private Map<String, Boolean> windows = new LinkedHashMap<String, Boolean>();

    /**
     * 一行判定依据。
     */
    @Data
    public static class Row {
        /** PRE 或 ATOM */
        private String kind;
        private String code;
        private String text;
        private boolean ok;
    }
}
