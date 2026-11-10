package com.phm.rule.controller;

import com.phm.rule.common.ApiResult;
import com.phm.rule.dto.AtomSaveRequest;
import com.phm.rule.dto.EnabledRequest;
import com.phm.rule.dto.ExprCheckRequest;
import com.phm.rule.dto.ExprPreviewRequest;
import com.phm.rule.dto.FaultCreateRequest;
import com.phm.rule.dto.FaultSaveRequest;
import com.phm.rule.dto.GroupPreviewRequest;
import com.phm.rule.dto.GroupSaveRequest;
import com.phm.rule.dto.PreFilterSaveRequest;
import com.phm.rule.dto.RevRequest;
import com.phm.rule.dto.SimulateRequest;
import com.phm.rule.entity.PreFilterRule;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleGroup;
import com.phm.rule.service.AtomRuleService;
import com.phm.rule.service.FaultRuleService;
import com.phm.rule.service.GroupRuleService;
import com.phm.rule.service.PreFilterService;
import com.phm.rule.vo.ExprPreviewVO;
import com.phm.rule.vo.FaultDetailVO;
import com.phm.rule.vo.FaultListItemVO;
import com.phm.rule.vo.ReferenceVO;
import com.phm.rule.vo.SimResultVO;
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
 * 原子、命名组、前置规则、故障规则，以及表达式预览、反解析和试算。
 */
@RestController
@RequestMapping("/api")
@Tag(name = "规则维护")
public class RuleController {

    private final AtomRuleService atomService;
    private final GroupRuleService groupService;
    private final PreFilterService preService;
    private final FaultRuleService faultService;

    /**
     * @param atomService  原子
     * @param groupService 命名组
     * @param preService   前置规则
     * @param faultService 故障规则
     */
    public RuleController(AtomRuleService atomService, GroupRuleService groupService,
                          PreFilterService preService, FaultRuleService faultService) {
        this.atomService = atomService;
        this.groupService = groupService;
        this.preService = preService;
        this.faultService = faultService;
    }

    /**
     * @param keyword   关键字
     * @param cx        车型
     * @param atomType  类型
     * @param scopeMode FIT 或 ALL
     * @return 原子列表
     */
    @GetMapping("/atoms")
    @Operation(summary = "原子列表")
    public ApiResult<List<RuleAtom>> atoms(@RequestParam(required = false) String keyword,
                                           @RequestParam(required = false) String cx,
                                           @RequestParam(required = false) String atomType,
                                           @RequestParam(defaultValue = "ALL") String scopeMode) {
        return ApiResult.ok(atomService.list(keyword, cx, atomType, scopeMode));
    }

    /**
     * @param id 主键
     * @return 原子
     */
    @GetMapping("/atoms/{id}")
    @Operation(summary = "原子详情")
    public ApiResult<RuleAtom> atom(@PathVariable Long id) {
        return ApiResult.ok(atomService.get(id));
    }

    /**
     * @param id 主键
     * @return 引用关系
     */
    @GetMapping("/atoms/{id}/references")
    @Operation(summary = "原子被谁引用")
    public ApiResult<ReferenceVO> atomRefs(@PathVariable Long id) {
        return ApiResult.ok(atomService.references(id));
    }

    /**
     * @param req 原子
     * @return 新建结果
     */
    @PostMapping("/atoms")
    @Operation(summary = "新建原子")
    public ApiResult<RuleAtom> createAtom(@Valid @RequestBody AtomSaveRequest req) {
        return ApiResult.ok(atomService.create(req));
    }

    /**
     * @param id  主键
     * @param req 原子
     * @return 更新结果
     */
    @PutMapping("/atoms/{id}")
    @Operation(summary = "修改原子")
    public ApiResult<RuleAtom> updateAtom(@PathVariable Long id, @Valid @RequestBody AtomSaveRequest req) {
        return ApiResult.ok(atomService.update(id, req));
    }

    /**
     * @param id 主键
     * @return 空
     */
    @DeleteMapping("/atoms/{id}")
    @Operation(summary = "删除原子")
    public ApiResult<Void> deleteAtom(@PathVariable Long id) {
        atomService.delete(id);
        return ApiResult.ok();
    }

    /**
     * @param keyword 关键字
     * @param cx      车型
     * @return 命名组
     */
    @GetMapping("/groups")
    @Operation(summary = "命名条件组列表")
    public ApiResult<List<RuleGroup>> groups(@RequestParam(required = false) String keyword,
                                             @RequestParam(required = false) String cx) {
        return ApiResult.ok(groupService.list(keyword, cx));
    }

    /**
     * @param id 主键
     * @return 组
     */
    @GetMapping("/groups/{id}")
    @Operation(summary = "命名组详情")
    public ApiResult<RuleGroup> group(@PathVariable Long id) {
        return ApiResult.ok(groupService.get(id));
    }

    /**
     * @param id 主键
     * @return 引用
     */
    @GetMapping("/groups/{id}/references")
    @Operation(summary = "命名组被谁引用")
    public ApiResult<ReferenceVO> groupRefs(@PathVariable Long id) {
        return ApiResult.ok(groupService.references(id));
    }

    /**
     * @param req 组合式
     * @return 预览
     */
    @PostMapping("/groups/preview")
    @Operation(summary = "命名组表达式预览")
    public ApiResult<ExprPreviewVO> previewGroup(@RequestBody GroupPreviewRequest req) {
        return ApiResult.ok(groupService.preview(req));
    }

    /**
     * @param req 组
     * @return 新建结果
     */
    @PostMapping("/groups")
    @Operation(summary = "新建命名组")
    public ApiResult<RuleGroup> createGroup(@Valid @RequestBody GroupSaveRequest req) {
        return ApiResult.ok(groupService.create(req));
    }

    /**
     * @param id  主键
     * @param req 组
     * @return 更新结果
     */
    @PutMapping("/groups/{id}")
    @Operation(summary = "修改命名组")
    public ApiResult<RuleGroup> updateGroup(@PathVariable Long id, @Valid @RequestBody GroupSaveRequest req) {
        return ApiResult.ok(groupService.update(id, req));
    }

    /**
     * @param id 主键
     * @return 空
     */
    @DeleteMapping("/groups/{id}")
    @Operation(summary = "删除命名组")
    public ApiResult<Void> deleteGroup(@PathVariable Long id) {
        groupService.delete(id);
        return ApiResult.ok();
    }

    /**
     * @return 前置规则
     */
    @GetMapping("/pre-filters")
    @Operation(summary = "通用前置规则列表")
    public ApiResult<List<PreFilterRule>> pres() {
        return ApiResult.ok(preService.list());
    }

    /**
     * @param req 前置规则
     * @return 新建结果
     */
    @PostMapping("/pre-filters")
    @Operation(summary = "新建前置规则")
    public ApiResult<PreFilterRule> createPre(@Valid @RequestBody PreFilterSaveRequest req) {
        return ApiResult.ok(preService.create(req));
    }

    /**
     * @param id  主键
     * @param req 前置规则
     * @return 更新结果
     */
    @PutMapping("/pre-filters/{id}")
    @Operation(summary = "修改前置规则")
    public ApiResult<PreFilterRule> updatePre(@PathVariable Long id, @Valid @RequestBody PreFilterSaveRequest req) {
        return ApiResult.ok(preService.update(id, req));
    }

    /**
     * @param id  主键
     * @param req 开关
     * @return 更新结果
     */
    @PutMapping("/pre-filters/{id}/enabled")
    @Operation(summary = "启停前置规则")
    public ApiResult<PreFilterRule> enablePre(@PathVariable Long id, @Valid @RequestBody EnabledRequest req) {
        return ApiResult.ok(preService.setEnabled(id, req));
    }

    /**
     * @param id 主键
     * @return 空
     */
    @DeleteMapping("/pre-filters/{id}")
    @Operation(summary = "删除前置规则")
    public ApiResult<Void> deletePre(@PathVariable Long id) {
        preService.delete(id);
        return ApiResult.ok();
    }

    /**
     * @param cx       车型
     * @param ly       来源
     * @param ruleMode 判定模式
     * @param czdj     处置等级
     * @param keyword  关键字
     * @return 故障列表
     */
    @GetMapping("/faults")
    @Operation(summary = "故障底账")
    public ApiResult<List<FaultListItemVO>> faults(@RequestParam(required = false) String cx,
                                                   @RequestParam(required = false) String ly,
                                                   @RequestParam(required = false) String ruleMode,
                                                   @RequestParam(required = false) String czdj,
                                                   @RequestParam(required = false) String keyword) {
        return ApiResult.ok(faultService.list(cx, ly, ruleMode, czdj, keyword));
    }

    /**
     * @param id 主键
     * @return 详情
     */
    @GetMapping("/faults/{id}")
    @Operation(summary = "故障规则详情")
    public ApiResult<FaultDetailVO> fault(@PathVariable Long id) {
        return ApiResult.ok(faultService.detail(id));
    }

    /**
     * @param req 新故障
     * @return 详情
     */
    @PostMapping("/faults")
    @Operation(summary = "新增故障条目")
    public ApiResult<FaultDetailVO> createFault(@Valid @RequestBody FaultCreateRequest req) {
        return ApiResult.ok(faultService.create(req));
    }

    /**
     * @param id  主键
     * @param req 保存内容
     * @return 详情
     */
    @PutMapping("/faults/{id}")
    @Operation(summary = "保存故障规则")
    public ApiResult<FaultDetailVO> saveFault(@PathVariable Long id, @Valid @RequestBody FaultSaveRequest req) {
        return ApiResult.ok(faultService.save(id, req));
    }

    /**
     * @param id  主键
     * @param req 修订号
     * @return 空
     */
    @DeleteMapping("/faults/{id}")
    @Operation(summary = "删除故障条目")
    public ApiResult<Void> deleteFault(@PathVariable Long id, @Valid @RequestBody RevRequest req) {
        faultService.delete(id, req.getRev());
        return ApiResult.ok();
    }

    /**
     * @param req 组合式
     * @return 预览
     */
    @PostMapping("/expr/preview")
    @Operation(summary = "组合式预览与展开")
    public ApiResult<ExprPreviewVO> preview(@RequestBody ExprPreviewRequest req) {
        return ApiResult.ok(faultService.preview(req));
    }

    /**
     * @param req 零 JSON
     * @return 反解析结果
     */
    @PostMapping("/expr/check")
    @Operation(summary = "零 JSON 反解析校验")
    public ApiResult<ExprPreviewVO> check(@RequestBody ExprCheckRequest req) {
        return ApiResult.ok(faultService.check(req));
    }

    /**
     * @param id  故障
     * @param req 测点
     * @return 试算
     */
    @PostMapping("/faults/{id}/simulate")
    @Operation(summary = "模拟测点试算")
    public ApiResult<SimResultVO> simulate(@PathVariable Long id, @RequestBody SimulateRequest req) {
        return ApiResult.ok(faultService.simulate(id, req));
    }

    /**
     * @param id      故障
     * @param wantHit 是否要命中样例
     * @return 样例
     */
    @PostMapping("/faults/{id}/sim-sample")
    @Operation(summary = "填充命中或未命中样例")
    public ApiResult<SimResultVO> sample(@PathVariable Long id, @RequestParam(defaultValue = "true") boolean wantHit) {
        return ApiResult.ok(faultService.sample(id, wantHit));
    }
}
