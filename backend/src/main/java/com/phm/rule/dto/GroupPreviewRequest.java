package com.phm.rule.dto;

import lombok.Data;

/**
 * 命名组编辑时的实时预览，不落库。
 */
@Data
public class GroupPreviewRequest {

    /** 组合式 */
    private String groupExpr;
}
