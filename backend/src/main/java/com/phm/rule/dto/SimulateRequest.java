package com.phm.rule.dto;

import lombok.Data;

import java.util.HashMap;
import java.util.Map;

/**
 * 模拟测点。windows 的键是「原子编号:故障代码」。
 */
@Data
public class SimulateRequest {

    /** 测点编码到值，缺失值传 - */
    private Map<String, String> values = new HashMap<String, String>();

    /** 时间窗内是否出现过关联故障 */
    private Map<String, Boolean> windows = new HashMap<String, Boolean>();
}
