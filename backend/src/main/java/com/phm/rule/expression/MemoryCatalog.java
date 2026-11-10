package com.phm.rule.expression;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

/**
 * 内存中的参数、原子、命名组目录。业务层每次编译前装入当前库，单元测试直接构造。
 */
public class MemoryCatalog implements ExprCatalog {

    private final Map<String, ParamView> params = new LinkedHashMap<String, ParamView>();
    private final Map<String, AtomView> items = new LinkedHashMap<String, AtomView>();

    /**
     * 放入参数。同编码以后写的为准。
     *
     * @param param 参数
     */
    public void putParam(ParamView param) {
        if (param != null && param.code != null) {
            params.put(param.code, param);
        }
    }

    /**
     * 放入原子或命名组。
     *
     * @param atom 定义
     */
    public void put(AtomView atom) {
        if (atom != null && atom.code != null) {
            items.put(atom.code, atom);
        }
    }

    @Override
    public ParamView param(String code) {
        return params.get(code);
    }

    @Override
    public AtomView find(String code) {
        return items.get(code);
    }

    @Override
    public Set<String> paramCodes() {
        return params.keySet();
    }

    @Override
    public Set<String> atomCodes() {
        Set<String> codes = new java.util.LinkedHashSet<String>();
        for (AtomView a : items.values()) {
            if (!a.isGroup()) {
                codes.add(a.code);
            }
        }
        return codes;
    }

    /**
     * @return 全部原子与命名组
     */
    public Collection<AtomView> all() {
        return items.values();
    }
}
