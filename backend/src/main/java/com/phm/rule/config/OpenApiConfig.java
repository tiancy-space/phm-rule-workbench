package com.phm.rule.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI 文档。界面在 /swagger-ui.html，JSON 在 /v3/api-docs。
 * 选用 springdoc 而不是已停止维护的 springfox，以便在 Spring Boot 2.7 上直接生成 OpenAPI 3。
 */
@Configuration
public class OpenApiConfig {

    /**
     * @return 文档基本信息
     */
    @Bean
    public OpenAPI phmOpenApi() {
        return new OpenAPI().info(new Info()
                .title("机车 PHM 故障规则管理工作台 API")
                .version("1.0.0")
                .description("规则维护、零 JSON 表达式、处置流程与历史试跑接口。表达式的解析和求值都在服务端完成。"));
    }
}
