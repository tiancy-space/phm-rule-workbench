package com.phm.rule.expression;

import java.util.Set;

/**
 * 表达式引擎需要的只读目录：参数元数据、原子、命名组。由业务层从数据库装入，单元测试用内存实现。
 */
public interface ExprCatalog {

    /**
     * @param code 参数编码
     * @return 元数据，不存在返回 null
     */
    ParamView param(String code);

    /**
     * @param code 原子编号 Rxxx 或命名组编号 Gxxx
     * @return 定义，不存在返回 null
     */
    AtomView find(String code);

    /**
     * @return 全部参数编码
     */
    Set<String> paramCodes();

    /**
     * @return 全部原子编号（不含命名组）
     */
    Set<String> atomCodes();
}
