package com.phm.rule.vo;

import com.phm.rule.expression.DisplayNode;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 组合式或零 JSON 的校验结果。ok 为 false 时看 message 和 pos。
 */
@Data
public class ExprPreviewVO {

    private boolean ok;
    private String message;
    /** 0 起始的出错位置，合法时为 null */
    private Integer pos;
    /** 规范组合式 */
    private String canonicalExpr;
    /** 入库用的展开式 */
    private String faultRule;
    /** 保留组名的引用式 */
    private String refExpr;
    /** 中文释义 */
    private String ruleDesc;
    private DisplayNode display;
    /** 零 JSON 反解析：条件个数 */
    private Integer condCount;
    /** 零 JSON 反解析：参数编码 */
    private List<String> fields = new ArrayList<String>();
    /** 零 JSON 反解析：时间窗个数 */
    private Integer windowCount;
    /** 与 expect 逐字一致 */
    private Boolean sameAsExpect;
    /** 规范写法，输入与规范不同时给出 */
    private String canonicalZero;
}
