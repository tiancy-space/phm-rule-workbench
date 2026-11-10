package com.phm.rule.vo;

import lombok.Data;

/**
 * 顶部统计条。
 */
@Data
public class StatsVO {

    private int faults;
    private int conditional;
    private int direct;
    private int disabled;
    private int pending;
    private int atoms;
    private int groups;
    private int flows;
    private int enabledPres;
}
