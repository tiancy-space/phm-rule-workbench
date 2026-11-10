package com.phm.rule.expression;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 表达式引擎单测。用例对齐原型 V5.1 和种子数据里的展开式。
 */
public class ExprEngineTest {

    private ExprEngine engine;
    private MemoryCatalog catalog;

    /**
     * 准备 1873 用到的参数、原子和命名组。
     */
    @BeforeEach
    public void setUp() {
        engine = new ExprEngine();
        catalog = new MemoryCatalog();
        param("YX_SD_SJ", "TCMS实际速度", "NUMBER", "km/h", null);
        param("SJSD", "LKJ实际速度", "NUMBER", "km/h", null);
        param("YX_YBDY", "原边电压", "NUMBER", "V", null);
        param("YX_ST6_3", "受电弓1(I端)升弓状态", "ENUM", "", "0:未升起;1:升起");
        param("YX_ST8_3", "受电弓2(II端)升弓状态", "ENUM", "", "0:未升起;1:升起");
        param("CC", "车次", "STRING", "", null);
        atomParam("R001", "YX_SD_SJ", ">", "0");
        atomParam("R002", "SJSD", ">", "0");
        atomParam("R003", "YX_SD_SJ", "==", "-");
        atomParam("R004", "YX_YBDY", ">=", "15000");
        atomParam("R005", "YX_ST6_3", "==", "1");
        atomParam("R006", "YX_ST8_3", "==", "1");
        atomWindow("R007", "allNotExists", 10, "1874", "1875");
        AtomView g = new AtomView();
        g.code = "G001";
        g.name = "机车在运行";
        g.type = "GROUP";
        g.scopeCx = "ALL";
        g.groupExpr = "(R001 & R002) | (R003 & R002)";
        catalog.put(g);
    }

    /**
     * 且优先于或，规范写法会给或的两侧补上必要括号。
     */
    @Test
    public void andBindsTighterThanOr() {
        String canon = engine.canonicalAlias("A1&A2|A3", Arrays.asList("R004", "R005", "R006"));
        assertEquals("(A1 & A2) | A3", canon);
    }

    /**
     * 1873 的组合式展开后应与种子 fault_rule 逐字一致。
     */
    @Test
    public void expand1873MatchesSeed() {
        List<String> refs = Arrays.asList("G001", "R004", "R005", "R006", "R007");
        String text = "A1 & A2 & (A3 | A4) & A5";
        assertEquals("A1 & A2 & (A3 | A4) & A5", engine.canonicalAlias(text, refs));
        assertEquals("((YX_SD_SJ > 0 & SJSD > 0) | (YX_SD_SJ == '-' & SJSD > 0)) & YX_YBDY >= 15000 & (YX_ST6_3 == 1 | YX_ST8_3 == 1) & allNotExists(10, 1874, 1875)",
                engine.expandAlias(text, refs, catalog));
        String desc = engine.explainAlias(text, refs, "1873", catalog);
        assertTrue(desc.startsWith("报出故障 1873，需同时满足以下 4 项："));
        assertTrue(desc.contains("机车在运行（满足其一）"));
        assertTrue(desc.contains("原边电压 ≥ 15000 V"));
        assertTrue(desc.contains("受电弓1(I端)升弓状态 为 升起"));
        assertTrue(desc.contains("前后 10 秒内未出现 1874、1875 中任一故障"));
    }

    /**
     * 命名组展开式与种子 G001 一致。
     */
    @Test
    public void groupExpand() {
        String[] compiled = engine.compileGroup("(R001 & R002) | (R003 & R002)", catalog);
        assertEquals("(R001 & R002) | (R003 & R002)", compiled[0]);
        assertEquals("(YX_SD_SJ > 0 & SJSD > 0) | (YX_SD_SJ == '-' & SJSD > 0)", compiled[1]);
        assertEquals("TCMS实际速度 > 0 km/h 且 LKJ实际速度 > 0 km/h ／ TCMS实际速度 未取到（缺失） 且 LKJ实际速度 > 0 km/h", compiled[2]);
        com.phm.rule.expression.DisplayNode tree = engine.displayGroup("(R001 & R002) | (R003 & R002)", catalog);
        assertEquals("or", tree.type);
        assertEquals(2, tree.children.size());
        assertEquals("and", tree.children.get(0).type);
        assertEquals("TCMS实际速度 > 0 km/h", tree.children.get(0).children.get(0).text);
    }

    /**
     * 花括号和中括号必须拒绝，缺失值用单引号减号。
     */
    @Test
    public void zeroJsonRejectsBracesAndParsesMissing() {
        assertThrows(ExprException.class, new org.junit.jupiter.api.function.Executable() {
            public void execute() {
                engine.canonicalZero("{YX_SD_SJ} > 3", catalog);
            }
        });
        assertThrows(ExprException.class, new org.junit.jupiter.api.function.Executable() {
            public void execute() {
                engine.canonicalZero("allNotExists(10, [1874])", catalog);
            }
        });
        ExprException unknown = assertThrows(ExprException.class, new org.junit.jupiter.api.function.Executable() {
            public void execute() {
                engine.canonicalZero("FOO == 1", catalog);
            }
        });
        assertTrue(unknown.getMessage().contains("未知参数编码 FOO"));
        assertEquals("YX_SD_SJ == '-'", engine.canonicalZero("YX_SD_SJ == '-'", catalog));
        assertEquals("CC =~ '^[A-Za-z]'", engine.canonicalZero("CC =~ '^[A-Za-z]'", catalog));
    }

    /**
     * 缺失值、数值比较和时间窗函数的求值。
     */
    @Test
    public void evaluateMissingNumberAndWindow() {
        Map<String, String> values = new HashMap<String, String>();
        values.put("YX_SD_SJ", "-");
        values.put("SJSD", "8");
        values.put("YX_YBDY", "16000");
        values.put("YX_ST6_3", "0");
        values.put("YX_ST8_3", "1");
        Map<String, Boolean> windows = new HashMap<String, Boolean>();
        windows.put("R007:1874", Boolean.FALSE);
        windows.put("R007:1875", Boolean.FALSE);
        List<String> refs = Arrays.asList("G001", "R004", "R005", "R006", "R007");
        assertTrue(engine.evalAlias("A1 & A2 & (A3 | A4) & A5", refs, values, windows, catalog));
        values.put("YX_YBDY", "100");
        assertFalse(engine.evalAlias("A1 & A2 & (A3 | A4) & A5", refs, values, windows, catalog));
        values.put("YX_SD_SJ", "");
        assertFalse(engine.compare("", "==", "-"));
        assertTrue(engine.compare("-", "==", "-"));
    }

    /**
     * 未引入的代号要报出位置。
     */
    @Test
    public void unknownAlias() {
        ExprException ex = assertThrows(ExprException.class, new org.junit.jupiter.api.function.Executable() {
            public void execute() {
                engine.canonicalAlias("A1 & A6", Collections.singletonList("R001"));
            }
        });
        assertTrue(ex.getMessage().contains("未引入的原子代号 A6"));
    }

    private void param(String code, String name, String type, String unit, String dict) {
        ParamView p = new ParamView();
        p.code = code;
        p.name = name;
        p.dataType = type;
        p.unit = unit;
        p.enumDict = dict;
        catalog.putParam(p);
    }

    private void atomParam(String code, String field, String op, String value) {
        AtomView a = new AtomView();
        a.code = code;
        a.type = "PARAM";
        a.scopeCx = "ALL";
        a.field = field;
        a.op = op;
        a.value = value;
        a.name = engine.atomText(a, catalog);
        catalog.put(a);
    }

    private void atomWindow(String code, String fn, int sec, String... codes) {
        AtomView a = new AtomView();
        a.code = code;
        a.type = "WINDOW";
        a.fn = fn;
        a.seconds = sec;
        a.codes = Arrays.asList(codes);
        a.name = engine.atomText(a, catalog);
        catalog.put(a);
    }
}
