package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.phm.rule.common.BizException;
import com.phm.rule.common.OperatorHolder;
import com.phm.rule.common.PageResult;
import com.phm.rule.common.Texts;
import com.phm.rule.dto.ParamSaveRequest;
import com.phm.rule.entity.DisposeCard;
import com.phm.rule.entity.PreFilterRule;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleParamMeta;
import com.phm.rule.mapper.DisposeCardMapper;
import com.phm.rule.mapper.PreFilterRuleMapper;
import com.phm.rule.mapper.RuleAtomMapper;
import com.phm.rule.mapper.RuleParamMetaMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 参数元数据维护。原子、前置规则和数据卡都引用这里，被引用时不允许删除。
 */
@Service
public class ParamMetaService {

    private static final Set<String> TYPES = new HashSet<String>(Arrays.asList("NUMBER", "ENUM", "STRING"));
    private static final Set<String> SOURCES = new HashSet<String>(Arrays.asList(
            "KAFKA", "HBASE", "HBASE_PHM", "HBASE_LKJ", "HBASE_6A", "DIM"));

    private final RuleParamMetaMapper mapper;
    private final RuleAtomMapper atomMapper;
    private final PreFilterRuleMapper preMapper;
    private final DisposeCardMapper cardMapper;

    /**
     * @param mapper     参数表
     * @param atomMapper 原子
     * @param preMapper  前置规则
     * @param cardMapper 数据卡
     */
    public ParamMetaService(RuleParamMetaMapper mapper, RuleAtomMapper atomMapper,
                            PreFilterRuleMapper preMapper, DisposeCardMapper cardMapper) {
        this.mapper = mapper;
        this.atomMapper = atomMapper;
        this.preMapper = preMapper;
        this.cardMapper = cardMapper;
    }

    /**
     * 按关键字、车型和数据类型分页。工作台一次取较多条，默认 200。
     *
     * @param keyword  编码或中文名
     * @param cx       只看适用于该车型的参数，空表示不限
     * @param dataType 数据类型
     * @param pageNum  页码
     * @param pageSize 页大小
     * @return 分页
     */
    public PageResult<RuleParamMeta> page(String keyword, String cx, String dataType, long pageNum, long pageSize) {
        LambdaQueryWrapper<RuleParamMeta> q = new LambdaQueryWrapper<RuleParamMeta>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            String k = keyword.trim();
            q.and(w -> w.like(RuleParamMeta::getParamCol, k).or().like(RuleParamMeta::getParamName, k));
        }
        if (dataType != null && !dataType.trim().isEmpty()) {
            q.eq(RuleParamMeta::getDataType, dataType.trim());
        }
        q.eq(RuleParamMeta::getIsEnabled, 1);
        q.orderByAsc(RuleParamMeta::getParamCol);
        List<RuleParamMeta> all = mapper.selectList(q);
        if (cx != null && !cx.trim().isEmpty()) {
            String model = cx.trim();
            List<RuleParamMeta> fit = new java.util.ArrayList<RuleParamMeta>();
            for (RuleParamMeta row : all) {
                if (fits(row.getScopeCx(), model)) {
                    fit.add(row);
                }
            }
            all = fit;
        }
        int from = (int) Math.max(0, (pageNum - 1) * pageSize);
        int to = (int) Math.min(all.size(), from + pageSize);
        List<RuleParamMeta> slice = from >= all.size() ? java.util.Collections.<RuleParamMeta>emptyList() : all.subList(from, to);
        return PageResult.of(all.size(), pageNum, pageSize, slice);
    }

    /**
     * @param id 主键
     * @return 参数
     */
    public RuleParamMeta get(Long id) {
        RuleParamMeta row = mapper.selectById(id);
        if (row == null) {
            throw BizException.notFound("参数不存在");
        }
        return row;
    }

    /**
     * 新建参数。编码必须大写，和实表名一起唯一。
     *
     * @param req 请求
     * @return 新行
     */
    @Transactional(rollbackFor = Exception.class)
    public RuleParamMeta create(ParamSaveRequest req) {
        RuleParamMeta row = new RuleParamMeta();
        fill(row, req);
        row.setRev(1);
        row.setIsSelectable(1);
        row.setIsEnabled(1);
        mapper.insert(row);
        return mapper.selectById(row.getId());
    }

    /**
     * 修改参数。修订号不一致时拒绝。
     *
     * @param id  主键
     * @param req 请求
     * @return 更新后的行
     */
    @Transactional(rollbackFor = Exception.class)
    public RuleParamMeta update(Long id, ParamSaveRequest req) {
        RuleParamMeta row = get(id);
        if (req.getRev() == null || !req.getRev().equals(row.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        fill(row, req);
        row.setUpdateBy(OperatorHolder.get());
        row.setUpdateTime(LocalDateTime.now());
        row.setRev(row.getRev() + 1);
        int n = mapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<RuleParamMeta>()
                .eq(RuleParamMeta::getId, id).eq(RuleParamMeta::getRev, req.getRev())
                .set(RuleParamMeta::getParamCol, row.getParamCol())
                .set(RuleParamMeta::getParamName, row.getParamName())
                .set(RuleParamMeta::getDataType, row.getDataType())
                .set(RuleParamMeta::getUnit, row.getUnit())
                .set(RuleParamMeta::getEnumDict, row.getEnumDict())
                .set(RuleParamMeta::getDataSource, row.getDataSource())
                .set(RuleParamMeta::getHbaseTable, row.getHbaseTable())
                .set(RuleParamMeta::getScopeCx, row.getScopeCx())
                .set(RuleParamMeta::getRemark, row.getRemark())
                .set(RuleParamMeta::getRev, row.getRev())
                .set(RuleParamMeta::getUpdateBy, row.getUpdateBy())
                .set(RuleParamMeta::getUpdateTime, row.getUpdateTime()));
        if (n != 1) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        return get(id);
    }

    /**
     * 逻辑删除。仍被原子、前置或数据卡引用时禁止。
     *
     * @param id 主键
     */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        get(id);
        long atoms = atomMapper.selectCount(new LambdaQueryWrapper<RuleAtom>().eq(RuleAtom::getParamId, id));
        long pres = preMapper.selectCount(new LambdaQueryWrapper<PreFilterRule>().eq(PreFilterRule::getParamId, id));
        long cards = cardMapper.selectCount(new LambdaQueryWrapper<DisposeCard>().eq(DisposeCard::getParamId, id));
        if (atoms + pres + cards > 0) {
            throw BizException.bad("禁止删除：仍被原子规则、前置规则或数据卡引用");
        }
        mapper.deleteById(id);
    }

    private void fill(RuleParamMeta row, ParamSaveRequest req) {
        String code = req.getParamCol() == null ? "" : req.getParamCol().trim().toUpperCase();
        if (!code.matches("[A-Z][A-Z0-9_]*")) {
            throw BizException.bad("参数编码需为大写字母开头，只含大写字母、数字和下划线");
        }
        if (req.getParamName() == null || req.getParamName().trim().isEmpty()) {
            throw BizException.bad("参数名称不能为空");
        }
        if (!TYPES.contains(req.getDataType())) {
            throw BizException.bad("数据类型只能是 NUMBER、ENUM 或 STRING");
        }
        if (!SOURCES.contains(req.getDataSource())) {
            throw BizException.bad("数据源不在允许范围内");
        }
        row.setParamCol(code);
        row.setParamName(req.getParamName().trim());
        row.setDataType(req.getDataType());
        row.setUnit(emptyToNull(req.getUnit()));
        row.setEnumDict(emptyToNull(req.getEnumDict()));
        row.setDataSource(req.getDataSource());
        String table = req.getHbaseTable() == null || req.getHbaseTable().trim().isEmpty() ? "-" : req.getHbaseTable().trim();
        row.setHbaseTable(table);
        row.setScopeCx(Texts.scope(req.getScopeCx() == null ? "ALL" : req.getScopeCx(), false));
        row.setRemark(emptyToNull(req.getRemark()));
    }

    private String emptyToNull(String s) {
        return s == null || s.trim().isEmpty() ? null : s.trim();
    }

    private boolean fits(String scope, String cx) {
        if (scope == null || "ALL".equals(scope)) {
            return true;
        }
        return Texts.splitComma(scope).contains(cx);
    }
}
