package com.phm.rule.common;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

/**
 * 分页结果。页码从 1 开始。
 *
 * @param <T> 行类型
 */
@Data
@Schema(description = "分页结果")
public class PageResult<T> {

    @Schema(description = "总行数")
    private long total;

    @Schema(description = "当前页，从 1 开始")
    private long pageNum;

    @Schema(description = "每页条数")
    private long pageSize;

    @Schema(description = "当前页数据")
    private List<T> records;

    /**
     * 组装一页数据。
     *
     * @param total    总数
     * @param pageNum  页码
     * @param pageSize 页大小
     * @param records  当前页
     * @param <T>      行类型
     * @return 分页对象
     */
    public static <T> PageResult<T> of(long total, long pageNum, long pageSize, List<T> records) {
        PageResult<T> p = new PageResult<T>();
        p.total = total;
        p.pageNum = pageNum;
        p.pageSize = pageSize;
        p.records = records;
        return p;
    }
}
