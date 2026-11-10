package com.phm.rule.dto;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 组合式预览。只校验和展开，不写库。
 */
@Data
public class ExprPreviewRequest {

    /** 故障代码，用于中文标题 */
    private String gzdm;

    /** 组合式 */
    private String ruleExpr;

    /** 已引入项，顺序对应 A1… */
    private List<RefItem> refs = new ArrayList<RefItem>();
}
