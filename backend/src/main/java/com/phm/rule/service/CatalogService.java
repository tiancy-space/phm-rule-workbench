package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.phm.rule.common.Texts;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleGroup;
import com.phm.rule.entity.RuleParamMeta;
import com.phm.rule.expression.AtomView;
import com.phm.rule.expression.MemoryCatalog;
import com.phm.rule.expression.ParamView;
import com.phm.rule.mapper.RuleAtomMapper;
import com.phm.rule.mapper.RuleGroupMapper;
import com.phm.rule.mapper.RuleParamMetaMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 把参数、原子、命名组装进表达式引擎用的目录。每次调用都读当前库，避免改完原子还用旧展开式。
 */
@Service
public class CatalogService {

    private final RuleParamMetaMapper paramMapper;
    private final RuleAtomMapper atomMapper;
    private final RuleGroupMapper groupMapper;

    /**
     * @param paramMapper 参数
     * @param atomMapper  原子
     * @param groupMapper 命名组
     */
    public CatalogService(RuleParamMetaMapper paramMapper, RuleAtomMapper atomMapper, RuleGroupMapper groupMapper) {
        this.paramMapper = paramMapper;
        this.atomMapper = atomMapper;
        this.groupMapper = groupMapper;
    }

    /**
     * @return 当前库的目录
     */
    public MemoryCatalog load() {
        MemoryCatalog cat = new MemoryCatalog();
        List<RuleParamMeta> params = paramMapper.selectList(new LambdaQueryWrapper<RuleParamMeta>()
                .eq(RuleParamMeta::getIsEnabled, 1));
        for (RuleParamMeta row : params) {
            cat.putParam(toParam(row));
        }
        for (RuleAtom row : atomMapper.selectList(null)) {
            cat.put(toAtom(row));
        }
        for (RuleGroup row : groupMapper.selectList(null)) {
            AtomView g = new AtomView();
            g.code = row.getGroupCode();
            g.name = row.getGroupName();
            g.type = "GROUP";
            g.scopeCx = row.getScopeCx();
            g.groupExpr = row.getGroupExpr();
            cat.put(g);
        }
        return cat;
    }

    /**
     * @param row 参数行
     * @return 引擎视图
     */
    public ParamView toParam(RuleParamMeta row) {
        ParamView p = new ParamView();
        p.code = row.getParamCol();
        p.name = row.getParamName();
        p.dataType = row.getDataType();
        p.unit = row.getUnit();
        p.enumDict = row.getEnumDict();
        p.dataSource = row.getDataSource();
        p.scopeCx = row.getScopeCx();
        return p;
    }

    /**
     * @param row 原子行
     * @return 引擎视图
     */
    public AtomView toAtom(RuleAtom row) {
        AtomView a = new AtomView();
        a.code = row.getAtomCode();
        a.name = row.getAtomName();
        a.type = row.getAtomType();
        a.scopeCx = row.getScopeCx();
        a.field = row.getParamCol();
        a.op = row.getCmpOp();
        a.value = row.getCmpVal();
        a.fn = row.getWinFn();
        a.seconds = row.getWinSec();
        a.codes = Texts.splitComma(row.getRelGzdm());
        return a;
    }
}
