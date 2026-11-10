package com.phm.rule.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Plus 分页插件。分页语句使用 LIMIT/OFFSET，PostgreSQL 与人大金仓 PG 兼容模式都能执行。
 * 若迁到金仓非 PG 模式，把 DbType 改成 KINGBASE_ES 即可，业务 SQL 本身不写死方言。
 */
@Configuration
public class MybatisPlusConfig {

    /**
     * @return 带分页拦截器的插件
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.POSTGRE_SQL));
        return interceptor;
    }
}
