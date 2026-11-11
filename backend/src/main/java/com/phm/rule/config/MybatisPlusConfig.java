package com.phm.rule.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Plus 分页插件。方言由 {@code app.db-type}（环境变量 {@code DB_TYPE}）决定。
 * 默认 {@code postgre_sql}，给 PostgreSQL、Supabase 和金仓 PG 模式，生成 LIMIT/OFFSET。
 * 本地金仓 Oracle 模式设 {@code kingbase_es}。业务 SQL 本身不写死方言。
 */
@Configuration
public class MybatisPlusConfig {

    @Value("${app.db-type:postgre_sql}")
    private String dbType;

    /**
     * @return 带分页拦截器的插件
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(resolve(dbType)));
        return interceptor;
    }

    /**
     * 把配置里的方言名收成 MyBatis-Plus 的枚举。
     * {@code postgre_sql} 是本项目的默认写法，插件内部登记的名字是 {@code postgresql}，这里做一层对应。
     * 认不出的值退回 PostgreSQL，避免配错一个字母就起不来。
     *
     * @param raw 配置值，例如 postgre_sql、kingbase_es
     * @return 分页方言
     */
    static DbType resolve(String raw) {
        String key = raw == null ? "" : raw.trim().toLowerCase();
        if ("postgre_sql".equals(key) || "postgresql".equals(key) || "postgres".equals(key)) {
            return DbType.POSTGRE_SQL;
        }
        if ("kingbase_es".equals(key) || "kingbasees".equals(key) || "kingbase".equals(key)) {
            return DbType.KINGBASE_ES;
        }
        DbType found = DbType.getDbType(key);
        if (found == null || found == DbType.OTHER) {
            return DbType.POSTGRE_SQL;
        }
        return found;
    }
}
