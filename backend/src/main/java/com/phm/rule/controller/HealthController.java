package com.phm.rule.controller;

import com.phm.rule.common.ApiResult;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 健康检查。Render 可用 /api/health 做探活；数据库暂时不可达时进程仍返回说明，便于区分应用和数据库。
 */
@RestController
@RequestMapping("/api/health")
@Tag(name = "健康检查")
public class HealthController {

    private final JdbcTemplate jdbc;

    /**
     * @param jdbc 用来探活数据库
     */
    public HealthController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * @return 应用与数据库状态
     */
    @GetMapping
    @Operation(summary = "健康检查")
    public ApiResult<Map<String, Object>> health() {
        Map<String, Object> body = new LinkedHashMap<String, Object>();
        body.put("app", "UP");
        try {
            Integer n = jdbc.queryForObject("SELECT 1", Integer.class);
            body.put("db", n != null && n == 1 ? "UP" : "DOWN");
        } catch (RuntimeException ex) {
            body.put("db", "DOWN");
        }
        return ApiResult.ok(body);
    }
}
