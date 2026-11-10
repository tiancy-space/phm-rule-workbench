package com.phm.rule.service;

import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 发布前校验的纯单元测试，不连数据库。
 */
public class FlowValidatorTest {

    /**
     * 查看步骤没有出口时必须拦截发布。
     */
    @Test
    public void branchWithoutTargetIsError() {
        FlowValidator.Step step = new FlowValidator.Step();
        step.id = 1L;
        step.type = "VIEW";
        step.title = "查看数据";
        step.roles = Collections.singletonList("EXPERT");
        FlowValidator.Branch branch = new FlowValidator.Branch();
        branch.label = "下一步";
        branch.condSrc = "NONE";
        step.branches.add(branch);
        FlowValidator.Result result = new FlowValidator().validate(
                Collections.singletonList(step), Collections.<String>emptyList(), false, 1,
                new HashMap<Long, com.phm.rule.expression.AtomView>(),
                new HashMap<Long, com.phm.rule.expression.AtomView>(),
                new HashMap<Long, com.phm.rule.expression.ParamView>());
        assertTrue(join(result.errors).contains("没有出口"));
        assertTrue(join(result.errors).contains("至少需要一个结束节点"));
    }

    /**
     * 判断步骤少于两个分支时拦截。
     */
    @Test
    public void judgeNeedsTwoBranches() {
        FlowValidator.Step step = new FlowValidator.Step();
        step.id = 2L;
        step.type = "JUDGE";
        step.title = "是否正常？";
        step.roles = Arrays.asList("SYSTEM", "EXPERT");
        FlowValidator.Branch only = new FlowValidator.Branch();
        only.label = "是";
        only.condSrc = "NONE";
        only.nextId = 2L;
        step.branches.add(only);
        FlowValidator.Result result = new FlowValidator().validate(
                Collections.singletonList(step), Collections.<String>emptyList(), true, 0,
                new HashMap<Long, com.phm.rule.expression.AtomView>(),
                new HashMap<Long, com.phm.rule.expression.AtomView>(),
                new HashMap<Long, com.phm.rule.expression.ParamView>());
        assertTrue(join(result.errors).contains("至少需要 2 个分支"));
    }

    private String join(java.util.List<String> lines) {
        StringBuilder sb = new StringBuilder();
        for (String line : lines) {
            sb.append(line).append('\n');
        }
        return sb.toString();
    }
}
