package com.phm.rule.it;

import com.phm.rule.entity.FaultRule;
import com.phm.rule.entity.PreFilterRule;
import com.phm.rule.mapper.FaultRuleMapper;
import com.phm.rule.mapper.RuleQueryMapper;
import com.phm.rule.service.FaultRuleService;
import com.phm.rule.service.FlowService;
import com.phm.rule.vo.FaultDetailVO;
import com.phm.rule.vo.FlowDetailVO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.FileSystemResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import javax.sql.DataSource;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.Statement;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 用 01_schema.sql 和 02_seed.sql 装载 PostgreSQL，核对样例查询和发布校验。
 */
@SpringBootTest
@ActiveProfiles("test")
public class RuleLoadIT {

    private static boolean loaded;

    @DynamicPropertySource
    static void props(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", () -> "jdbc:postgresql://127.0.0.1:5432/phm_rule_test");
        registry.add("spring.datasource.username", () -> "phm");
        registry.add("spring.datasource.password", () -> System.getenv().getOrDefault("DB_PASSWORD", ""));
    }

    /**
     * 每个测试类只装一次库。脚本可重复执行，这里仍先清空 public，避免残留。
     *
     * @param dataSource 测试数据源
     * @throws Exception 装库失败
     */
    @Autowired
    void loadOnce(DataSource dataSource) throws Exception {
        if (loaded) {
            return;
        }
        try (Connection conn = dataSource.getConnection(); Statement st = conn.createStatement()) {
            st.execute("DROP SCHEMA IF EXISTS public CASCADE");
            st.execute("CREATE SCHEMA public");
            st.execute("GRANT ALL ON SCHEMA public TO phm");
        }
        Path root = Paths.get("").toAbsolutePath();
        Path db = Files.exists(root.resolve("db")) ? root.resolve("db") : root.resolve("../db");
        ResourceDatabasePopulator pop = new ResourceDatabasePopulator();
        pop.setContinueOnError(false);
        pop.addScript(new FileSystemResource(db.resolve("01_schema.sql")));
        pop.addScript(new FileSystemResource(db.resolve("02_seed.sql")));
        pop.execute(dataSource);
        loaded = true;
    }

    @Autowired
    private RuleQueryMapper queryMapper;
    @Autowired
    private FaultRuleMapper faultRuleMapper;
    @Autowired
    private FaultRuleService faultRuleService;
    @Autowired
    private FlowService flowService;

    /**
     * FXN5C / TCMS / 3816 豁免整备状态后只继承 PF_OVERHAUL。
     */
    @Test
    public void fxn5cInheritsOnlyOverhaul() {
        FaultRule fault = faultRuleMapper.selectOne(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<FaultRule>()
                .eq(FaultRule::getCx, "FXN5C").eq(FaultRule::getLy, "TCMS").eq(FaultRule::getGzdm, "3816"));
        List<PreFilterRule> inherited = queryMapper.selectInheritedFilters(fault.getId());
        assertEquals(1, inherited.size());
        assertEquals("PF_OVERHAUL", inherited.get(0).getFilterCode());
        FaultDetailVO detail = faultRuleService.detail(fault.getId());
        assertEquals(1, detail.getInheritedFilters().size());
        assertEquals("PF_OVERHAUL", detail.getInheritedFilters().get(0).getFilterCode());
        assertEquals(1, detail.getSkips().size());
    }

    /**
     * HXD1C / TCMS / 1873 的 A1…A5 与样例查询一致，A1 是命名组。
     */
    @Test
    public void hxd1c1873Refs() {
        FaultDetailVO detail = faultRuleService.detail(faultRuleMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<FaultRule>()
                        .eq(FaultRule::getCx, "HXD1C").eq(FaultRule::getLy, "TCMS").eq(FaultRule::getGzdm, "1873")).getId());
        assertEquals("A1 & A2 & (A3 | A4) & A5", detail.getRuleExpr());
        assertEquals(5, detail.getRefs().size());
        assertEquals("A1", detail.getRefs().get(0).getAlias());
        assertEquals("GROUP", detail.getRefs().get(0).getRefType());
        assertEquals("G001", detail.getRefs().get(0).getCode());
        assertEquals("A5", detail.getRefs().get(4).getAlias());
        assertEquals("R007", detail.getRefs().get(4).getCode());
        assertTrue(detail.getFaultRule().contains("allNotExists(10, 1874, 1875)"));
    }

    /**
     * 已发布的 1914 流程校验应通过，并且起点是查看步骤。
     */
    @Test
    public void published1914Validates() {
        FlowDetailVO flow = null;
        for (FlowDetailVO item : flowService.list()) {
            if ("FL1914".equals(item.getFlowCode())) {
                flow = item;
            }
        }
        assertTrue(flow != null);
        assertTrue(flow.getErrors().isEmpty(), String.valueOf(flow.getErrors()));
        assertEquals("PUBLISHED", flow.getFlowStatus());
        assertEquals("VIEW", flow.getSteps().get(0).getStepType());
        assertEquals(9, flow.getSteps().size());
    }
}
