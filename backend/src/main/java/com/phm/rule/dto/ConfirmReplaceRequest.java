package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;

/**
 * 整体替换某一步的确认项。
 */
@Data
public class ConfirmReplaceRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    private List<ConfirmItem> confirms = new ArrayList<ConfirmItem>();
}
