package com.phm.rule.common;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 统一接口返回体。成功时 code 为 0；业务失败使用 400 / 404 / 409，未捕获异常为 500。
 *
 * @param <T> 业务数据类型
 */
@Data
@Schema(description = "统一返回体")
public class ApiResult<T> {

    @Schema(description = "0 成功，其余为失败")
    private int code;

    @Schema(description = "提示信息")
    private String message;

    @Schema(description = "业务数据")
    private T data;

    /**
     * 构造成功结果。
     *
     * @param data 数据
     * @param <T>  数据类型
     * @return 返回体
     */
    public static <T> ApiResult<T> ok(T data) {
        ApiResult<T> r = new ApiResult<T>();
        r.code = 0;
        r.message = "ok";
        r.data = data;
        return r;
    }

    /**
     * 构造成功结果（无数据）。
     *
     * @param <T> 数据类型
     * @return 返回体
     */
    public static <T> ApiResult<T> ok() {
        return ok(null);
    }

    /**
     * 构造失败结果。
     *
     * @param code    业务码
     * @param message 说明
     * @param <T>     数据类型
     * @return 返回体
     */
    public static <T> ApiResult<T> fail(int code, String message) {
        ApiResult<T> r = new ApiResult<T>();
        r.code = code;
        r.message = message;
        return r;
    }
}
