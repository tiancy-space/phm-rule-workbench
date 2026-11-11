package com.phm.rule.config;

import com.baomidou.mybatisplus.annotation.DbType;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * 分页方言只看配置名，不连数据库。
 */
class MybatisPlusConfigTest {

    @Test
    void defaultNameIsPostgres() {
        assertEquals(DbType.POSTGRE_SQL, MybatisPlusConfig.resolve("postgre_sql"));
        assertEquals(DbType.POSTGRE_SQL, MybatisPlusConfig.resolve(null));
        assertEquals(DbType.POSTGRE_SQL, MybatisPlusConfig.resolve("no-such-db"));
    }

    @Test
    void kingbaseOracleModeUsesKingbaseDialect() {
        assertEquals(DbType.KINGBASE_ES, MybatisPlusConfig.resolve("kingbase_es"));
        assertEquals(DbType.KINGBASE_ES, MybatisPlusConfig.resolve("kingbasees"));
    }
}
