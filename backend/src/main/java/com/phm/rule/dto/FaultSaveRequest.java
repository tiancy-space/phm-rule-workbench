package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;

/**
 * 保存当前故障的判定模式、处置等级、组合式、引入清单和单条豁免。
 * rev 为乐观锁，必须与读到的修订号一致。
 */
@Data
public class FaultSaveRequest {

    /** 读到的修订号 */
    @NotNull(message = "不能为空")
    private Integer rev;

    /** CONDITIONAL / DIRECT / DISABLED / PENDING */
    @NotBlank(message = "不能为空")
    private String ruleMode;

    /** CHECK / WATCH / NONE */
    @NotBlank(message = "不能为空")
    private String czdj;

    /** A/B/C/D */
    @NotBlank(message = "不能为空")
    private String jkdj;

    /** 模型名称 */
    private String mxmc;

    /** 组合式，条件组合判定时必填 */
    private String ruleExpr;

    /** 配置备注 */
    private String configNote;

    /** 按顺序引入的原子或命名组 */
    private List<RefItem> refs = new ArrayList<RefItem>();

    /** 要豁免的前置规则主键 */
    private List<Long> skipFilterIds = new ArrayList<Long>();
}
