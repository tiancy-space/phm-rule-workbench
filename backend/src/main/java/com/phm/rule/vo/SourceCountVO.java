package com.phm.rule.vo;

import lombok.Data;

/**
 * 某个车型下，一个数据源还有多少条可见参数。页签上的数字用这个。
 */
@Data
public class SourceCountVO {

    /** TCMS / 6A / LKJ / DWD / DIM */
    private String dataSource;
    private long count;
}
