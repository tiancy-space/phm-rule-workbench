package com.phm.rule;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 机车 PHM 故障规则管理工作台后端启动类。
 * 持久层扫描 {@code com.phm.rule.mapper} 下的 MyBatis / MyBatis-Plus 接口。
 */
@SpringBootApplication
@MapperScan("com.phm.rule.mapper")
public class PhmRuleApplication {

    /**
     * 启动 Spring Boot。
     *
     * @param args 命令行参数
     */
    public static void main(String[] args) {
        SpringApplication.run(PhmRuleApplication.class, args);
    }
}
