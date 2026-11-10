package com.phm.rule.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.phm.rule.common.ApiResult;
import com.phm.rule.common.PageResult;
import com.phm.rule.dto.ParamSaveRequest;
import com.phm.rule.entity.DictItem;
import com.phm.rule.entity.RuleParamMeta;
import com.phm.rule.mapper.DictItemMapper;
import com.phm.rule.service.FaultRuleService;
import com.phm.rule.service.ParamMetaService;
import com.phm.rule.vo.StatsVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.List;

/**
 * 字典、统计和参数元数据。
 */
@RestController
@RequestMapping("/api")
@Tag(name = "字典与参数")
public class MetaController {

    private final DictItemMapper dictMapper;
    private final ParamMetaService paramService;
    private final FaultRuleService faultRuleService;

    /**
     * @param dictMapper       字典
     * @param paramService     参数
     * @param faultRuleService 统计
     */
    public MetaController(DictItemMapper dictMapper, ParamMetaService paramService, FaultRuleService faultRuleService) {
        this.dictMapper = dictMapper;
        this.paramService = paramService;
        this.faultRuleService = faultRuleService;
    }

    /**
     * @param dictType 字典类型，空则返回全部启用项
     * @return 字典项
     */
    @GetMapping("/dicts")
    @Operation(summary = "字典项")
    public ApiResult<List<DictItem>> dicts(@RequestParam(required = false) String dictType) {
        LambdaQueryWrapper<DictItem> q = new LambdaQueryWrapper<DictItem>()
                .eq(DictItem::getIsEnabled, 1)
                .orderByAsc(DictItem::getDictType)
                .orderByAsc(DictItem::getSortNo);
        if (dictType != null && !dictType.trim().isEmpty()) {
            q.eq(DictItem::getDictType, dictType.trim());
        }
        return ApiResult.ok(dictMapper.selectList(q));
    }

    /**
     * @return 顶部统计
     */
    @GetMapping("/stats")
    @Operation(summary = "工作台统计")
    public ApiResult<StatsVO> stats() {
        return ApiResult.ok(faultRuleService.stats());
    }

    /**
     * @param keyword  关键字
     * @param cx       车型
     * @param dataType 类型
     * @param pageNum  页码
     * @param pageSize 页大小
     * @return 参数分页
     */
    @GetMapping("/params")
    @Operation(summary = "参数元数据分页")
    public ApiResult<PageResult<RuleParamMeta>> params(@RequestParam(required = false) String keyword,
                                                       @RequestParam(required = false) String cx,
                                                       @RequestParam(required = false) String dataType,
                                                       @RequestParam(defaultValue = "1") long pageNum,
                                                       @RequestParam(defaultValue = "200") long pageSize) {
        return ApiResult.ok(paramService.page(keyword, cx, dataType, pageNum, pageSize));
    }

    /**
     * @param id 主键
     * @return 参数
     */
    @GetMapping("/params/{id}")
    @Operation(summary = "参数详情")
    public ApiResult<RuleParamMeta> param(@PathVariable Long id) {
        return ApiResult.ok(paramService.get(id));
    }

    /**
     * @param req 参数
     * @return 新参数
     */
    @PostMapping("/params")
    @Operation(summary = "新建参数")
    public ApiResult<RuleParamMeta> createParam(@Valid @RequestBody ParamSaveRequest req) {
        return ApiResult.ok(paramService.create(req));
    }

    /**
     * @param id  主键
     * @param req 参数
     * @return 更新后的参数
     */
    @PutMapping("/params/{id}")
    @Operation(summary = "修改参数")
    public ApiResult<RuleParamMeta> updateParam(@PathVariable Long id, @Valid @RequestBody ParamSaveRequest req) {
        return ApiResult.ok(paramService.update(id, req));
    }

    /**
     * @param id 主键
     * @return 空
     */
    @DeleteMapping("/params/{id}")
    @Operation(summary = "删除参数")
    public ApiResult<Void> deleteParam(@PathVariable Long id) {
        paramService.delete(id);
        return ApiResult.ok();
    }
}
