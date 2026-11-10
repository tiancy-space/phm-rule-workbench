package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.phm.rule.common.BizException;
import com.phm.rule.common.OperatorHolder;
import com.phm.rule.common.Texts;
import com.phm.rule.dto.EnabledRequest;
import com.phm.rule.dto.PreFilterSaveRequest;
import com.phm.rule.entity.PreFilterRule;
import com.phm.rule.entity.RuleParamMeta;
import com.phm.rule.expression.AtomView;
import com.phm.rule.expression.ExprEngine;
import com.phm.rule.mapper.PreFilterRuleMapper;
import com.phm.rule.mapper.RuleParamMetaMapper;
import com.phm.rule.mapper.RuleQueryMapper;
import com.phm.rule.service.CatalogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 通用前置规则。启停立即生效；各故障按车型和来源继承，豁免在故障保存时单独记录。
 */
@Service
public class PreFilterService {

    private static final Set<String> LY = new HashSet<String>(java.util.Arrays.asList("ALL", "TCMS", "6A"));
    private static final Set<String> TIMING = new HashSet<String>(java.util.Arrays.asList("BEFORE_HBASE", "AFTER_HBASE"));

    private final PreFilterRuleMapper mapper;
    private final RuleParamMetaMapper paramMapper;
    private final RuleQueryMapper queryMapper;
    private final CatalogService catalogService;
    private final ExprEngine engine = new ExprEngine();

    /**
     * @param mapper         前置规则
     * @param paramMapper    参数
     * @param queryMapper    自定义 SQL
     * @param catalogService 目录，用来生成表达式
     */
    public PreFilterService(PreFilterRuleMapper mapper, RuleParamMetaMapper paramMapper,
                            RuleQueryMapper queryMapper, CatalogService catalogService) {
        this.mapper = mapper;
        this.paramMapper = paramMapper;
        this.queryMapper = queryMapper;
        this.catalogService = catalogService;
    }

    /**
     * 按优先级列出全部前置规则。
     *
     * @return 列表
     */
    public List<PreFilterRule> list() {
        return mapper.selectList(new LambdaQueryWrapper<PreFilterRule>().orderByAsc(PreFilterRule::getPriority)
                .orderByAsc(PreFilterRule::getFilterCode));
    }

    /**
     * @param id 主键
     * @return 规则
     */
    public PreFilterRule get(Long id) {
        PreFilterRule row = mapper.selectById(id);
        if (row == null) {
            throw BizException.notFound("前置规则不存在");
        }
        return row;
    }

    /**
     * @param req 请求
     * @return 新规则，默认启用
     */
    @Transactional(rollbackFor = Exception.class)
    public PreFilterRule create(PreFilterSaveRequest req) {
        PreFilterRule row = new PreFilterRule();
        row.setFilterCode(Texts.nextCode("PF", 3, queryMapper.allFilterCodes()));
        row.setIsEnabled(1);
        row.setRev(1);
        fill(row, req);
        mapper.insert(row);
        return get(row.getId());
    }

    /**
     * @param id  主键
     * @param req 请求
     * @return 更新后的规则
     */
    @Transactional(rollbackFor = Exception.class)
    public PreFilterRule update(Long id, PreFilterSaveRequest req) {
        PreFilterRule row = get(id);
        if (req.getRev() == null || !req.getRev().equals(row.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        fill(row, req);
        write(row, req.getRev());
        return get(id);
    }

    /**
     * 启停立即生效。
     *
     * @param id  主键
     * @param req 开关和修订号
     * @return 更新后的规则
     */
    @Transactional(rollbackFor = Exception.class)
    public PreFilterRule setEnabled(Long id, EnabledRequest req) {
        PreFilterRule row = get(id);
        if (!req.getRev().equals(row.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        int n = mapper.update(null, new LambdaUpdateWrapper<PreFilterRule>()
                .eq(PreFilterRule::getId, id).eq(PreFilterRule::getRev, req.getRev())
                .set(PreFilterRule::getIsEnabled, Boolean.TRUE.equals(req.getEnabled()) ? 1 : 0)
                .set(PreFilterRule::getRev, req.getRev() + 1)
                .set(PreFilterRule::getUpdateBy, OperatorHolder.get())
                .set(PreFilterRule::getUpdateTime, LocalDateTime.now()));
        if (n != 1) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        return get(id);
    }

    /**
     * 删除前置规则，并清掉各故障上的豁免记录。
     *
     * @param id 主键
     */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        get(id);
        queryMapper.deleteSkipsByFilter(id);
        mapper.deleteById(id);
    }

    private void fill(PreFilterRule row, PreFilterSaveRequest req) {
        Texts.requireOp(req.getCmpOp());
        if (!LY.contains(req.getScopeLy())) {
            throw BizException.bad("适用来源只能是 ALL、TCMS 或 6A");
        }
        if (!TIMING.contains(req.getExecTiming())) {
            throw BizException.bad("执行时机不正确");
        }
        List<RuleParamMeta> found = paramMapper.selectList(new LambdaQueryWrapper<RuleParamMeta>()
                .eq(RuleParamMeta::getParamCol, req.getParamCol().trim()));
        if (found.isEmpty()) {
            throw BizException.bad("参数编码不在元数据中：" + req.getParamCol());
        }
        RuleParamMeta param = found.get(0);
        if ("BEFORE_HBASE".equals(req.getExecTiming())
                && !"KAFKA".equals(param.getDataSource()) && !"DIM".equals(param.getDataSource())) {
            throw BizException.bad("查 HBase 前短路拦截只能使用 KAFKA 或 DIM 参数");
        }
        row.setFilterName(req.getFilterName().trim());
        row.setParamId(param.getId());
        row.setParamCol(param.getParamCol());
        row.setCmpOp(req.getCmpOp());
        row.setCmpVal(req.getCmpVal().trim());
        row.setScopeCx(Texts.scope(req.getScopeCx(), true));
        row.setScopeLy(req.getScopeLy());
        row.setExecTiming(req.getExecTiming());
        row.setPriority(req.getPriority());
        row.setRemark(req.getRemark() == null || req.getRemark().trim().isEmpty() ? null : req.getRemark().trim());
        AtomView view = new AtomView();
        view.type = "PARAM";
        view.field = param.getParamCol();
        view.op = row.getCmpOp();
        view.value = row.getCmpVal();
        row.setFilterExpr(engine.atomExpr(view, catalogService.load()));
    }

    private void write(PreFilterRule row, Integer rev) {
        int n = mapper.update(null, new LambdaUpdateWrapper<PreFilterRule>()
                .eq(PreFilterRule::getId, row.getId()).eq(PreFilterRule::getRev, rev)
                .set(PreFilterRule::getFilterName, row.getFilterName())
                .set(PreFilterRule::getParamId, row.getParamId())
                .set(PreFilterRule::getParamCol, row.getParamCol())
                .set(PreFilterRule::getCmpOp, row.getCmpOp())
                .set(PreFilterRule::getCmpVal, row.getCmpVal())
                .set(PreFilterRule::getScopeCx, row.getScopeCx())
                .set(PreFilterRule::getScopeLy, row.getScopeLy())
                .set(PreFilterRule::getExecTiming, row.getExecTiming())
                .set(PreFilterRule::getFilterExpr, row.getFilterExpr())
                .set(PreFilterRule::getPriority, row.getPriority())
                .set(PreFilterRule::getRemark, row.getRemark())
                .set(PreFilterRule::getRev, rev + 1)
                .set(PreFilterRule::getUpdateBy, OperatorHolder.get())
                .set(PreFilterRule::getUpdateTime, LocalDateTime.now()));
        if (n != 1) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
    }
}
