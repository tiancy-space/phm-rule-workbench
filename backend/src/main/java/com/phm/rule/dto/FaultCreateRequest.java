package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 新增一条故障底账。处置等级默认关注，判定模式默认待配置。
 */
@Data
public class FaultCreateRequest {

    /** 车型 */
    @NotBlank(message = "不能为空")
    private String cx;

    /** 来源，TCMS 或 6A */
    @NotBlank(message = "不能为空")
    private String ly;

    /** 故障代码，保留空格等原始写法 */
    @NotBlank(message = "不能为空")
    private String gzdm;

    /** 故障名称 */
    @NotBlank(message = "不能为空")
    private String gzmc;

    /** 模型名称 */
    private String mxmc;

    /** 健康等级，缺省为 D */
    private String jkdj;
}
