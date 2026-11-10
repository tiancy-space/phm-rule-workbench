package com.phm.rule.common;

/**
 * 可预期的业务异常。由全局异常处理器转换为统一返回体，不打印整段堆栈。
 */
public class BizException extends RuntimeException {

    private final int code;

    /**
     * @param code    HTTP 语义相近的业务码（400/404/409）
     * @param message 给前端展示的中文说明
     */
    public BizException(int code, String message) {
        super(message);
        this.code = code;
    }

    /**
     * @return 业务码
     */
    public int getCode() {
        return code;
    }

    /**
     * 参数或业务规则不通过。
     *
     * @param message 说明
     * @return 异常
     */
    public static BizException bad(String message) {
        return new BizException(400, message);
    }

    /**
     * 记录不存在。
     *
     * @param message 说明
     * @return 异常
     */
    public static BizException notFound(String message) {
        return new BizException(404, message);
    }

    /**
     * 乐观锁冲突或状态冲突。
     *
     * @param message 说明
     * @return 异常
     */
    public static BizException conflict(String message) {
        return new BizException(409, message);
    }
}
