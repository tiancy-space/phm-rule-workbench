package com.phm.rule.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;

/**
 * 整体替换某一步的出口，按列表顺序判定。
 */
@Data
public class BranchReplaceRequest {

    @NotNull(message = "不能为空")
    private Integer rev;

    private List<BranchItem> branches = new ArrayList<BranchItem>();
}
