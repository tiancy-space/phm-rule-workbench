package com.phm.rule.common;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import javax.validation.ConstraintViolationException;
import java.util.stream.Collectors;

/**
 * 把校验异常、业务异常和数据库约束异常收成统一返回体。
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * 业务异常：按业务码映射 HTTP 状态。
     *
     * @param ex 业务异常
     * @return 返回体
     */
    @ExceptionHandler(BizException.class)
    public ResponseEntity<ApiResult<Void>> biz(BizException ex) {
        HttpStatus status = HttpStatus.resolve(ex.getCode());
        if (status == null) {
            status = HttpStatus.BAD_REQUEST;
        }
        return ResponseEntity.status(status).body(ApiResult.fail(ex.getCode(), ex.getMessage()));
    }

    /**
     * Bean 校验失败（请求体）。
     *
     * @param ex 校验异常
     * @return 400
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResult<Void>> valid(MethodArgumentNotValidException ex) {
        String msg = ex.getBindingResult().getFieldErrors().stream()
                .map(this::fieldMessage)
                .collect(Collectors.joining("；"));
        if (msg.isEmpty()) {
            msg = "参数校验未通过";
        }
        return ResponseEntity.badRequest().body(ApiResult.fail(400, msg));
    }

    /**
     * 方法参数校验失败。
     *
     * @param ex 约束异常
     * @return 400
     */
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiResult<Void>> constraint(ConstraintViolationException ex) {
        return ResponseEntity.badRequest().body(ApiResult.fail(400, ex.getMessage()));
    }

    /**
     * JSON 无法解析。
     *
     * @param ex 解析异常
     * @return 400
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResult<Void>> unreadable(HttpMessageNotReadableException ex) {
        return ResponseEntity.badRequest().body(ApiResult.fail(400, "请求体不是合法的 JSON"));
    }

    /**
     * 唯一约束、外键、检查约束冲突时给出可读说明，不把 SQL 原文抛给前端。
     *
     * @param ex 完整性异常
     * @return 409
     */
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiResult<Void>> integrity(DataIntegrityViolationException ex) {
        log.warn("数据约束冲突: {}", ex.getMostSpecificCause().getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiResult.fail(409, "数据约束未通过，请检查唯一性、引用关系或字段取值"));
    }

    /**
     * 兜底。记录堆栈，对外只给简短说明。
     *
     * @param ex 任意异常
     * @return 500
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResult<Void>> other(Exception ex) {
        log.error("未处理异常", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResult.fail(500, "服务器内部错误"));
    }

    private String fieldMessage(FieldError err) {
        return err.getField() + " " + (err.getDefaultMessage() == null ? "不合法" : err.getDefaultMessage());
    }
}
