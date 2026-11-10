package com.phm.rule.dto;

import lombok.Data;

/**
 * 组合式中的一项引用。顺序即 A1、A2…
 */
@Data
public class RefItem {

    /** ATOM 或 GROUP */
    private String refType;
    /** 原子编号或命名组编号 */
    private String code;
}
