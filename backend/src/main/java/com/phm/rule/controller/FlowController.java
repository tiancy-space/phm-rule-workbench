package com.phm.rule.controller;

import com.phm.rule.common.ApiResult;
import com.phm.rule.dto.BranchReplaceRequest;
import com.phm.rule.dto.CardSaveRequest;
import com.phm.rule.dto.ConfirmReplaceRequest;
import com.phm.rule.dto.FlowBindRequest;
import com.phm.rule.dto.FlowCopyRequest;
import com.phm.rule.dto.FlowCreateRequest;
import com.phm.rule.dto.FlowHeaderRequest;
import com.phm.rule.dto.ReorderRequest;
import com.phm.rule.dto.RevRequest;
import com.phm.rule.dto.SaveTemplateRequest;
import com.phm.rule.dto.StepCreateRequest;
import com.phm.rule.dto.StepUpdateRequest;
import com.phm.rule.dto.UnbindRequest;
import com.phm.rule.service.FlowService;
import com.phm.rule.service.TrialService;
import com.phm.rule.vo.FlowDetailVO;
import com.phm.rule.vo.TrialVO;
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
 * 处置流程编辑、发布，以及历史故障试跑。
 */
@RestController
@RequestMapping("/api")
@Tag(name = "处置流程与试跑")
public class FlowController {

    private final FlowService flowService;
    private final TrialService trialService;

    /**
     * @param flowService  流程
     * @param trialService 试跑
     */
    public FlowController(FlowService flowService, TrialService trialService) {
        this.flowService = flowService;
        this.trialService = trialService;
    }

    /**
     * @return 流程列表
     */
    @GetMapping("/flows")
    @Operation(summary = "流程列表")
    public ApiResult<List<FlowDetailVO>> flows() {
        return ApiResult.ok(flowService.list());
    }

    /**
     * @param id 主键
     * @return 详情
     */
    @GetMapping("/flows/{id}")
    @Operation(summary = "流程详情")
    public ApiResult<FlowDetailVO> flow(@PathVariable Long id) {
        return ApiResult.ok(flowService.detail(id));
    }

    /**
     * @param faultId 故障
     * @return 绑定的流程，没有则为空数据
     */
    @GetMapping("/flows/by-fault/{faultId}")
    @Operation(summary = "按故障取流程")
    public ApiResult<FlowDetailVO> byFault(@PathVariable Long faultId) {
        return ApiResult.ok(flowService.byFault(faultId));
    }

    /**
     * @param req 新建方式
     * @return 新流程
     */
    @PostMapping("/flows")
    @Operation(summary = "新建空白流程或模板")
    public ApiResult<FlowDetailVO> create(@RequestBody FlowCreateRequest req) {
        return ApiResult.ok(flowService.create(req));
    }

    /**
     * @param id  来源
     * @param req 目标故障
     * @return 复制出的专属流程
     */
    @PostMapping("/flows/{id}/copy")
    @Operation(summary = "复制为专属流程")
    public ApiResult<FlowDetailVO> copy(@PathVariable Long id, @Valid @RequestBody FlowCopyRequest req) {
        return ApiResult.ok(flowService.copyForFault(id, req));
    }

    /**
     * @param id  流程
     * @param req 绑定清单
     * @return 详情
     */
    @PostMapping("/flows/{id}/bindings")
    @Operation(summary = "保存绑定")
    public ApiResult<FlowDetailVO> bind(@PathVariable Long id, @Valid @RequestBody FlowBindRequest req) {
        return ApiResult.ok(flowService.bindAll(id, req));
    }

    /**
     * @param id  流程
     * @param req 解绑
     * @return 详情
     */
    @PostMapping("/flows/{id}/unbind")
    @Operation(summary = "解绑一条故障")
    public ApiResult<FlowDetailVO> unbind(@PathVariable Long id, @Valid @RequestBody UnbindRequest req) {
        return ApiResult.ok(flowService.unbind(id, req));
    }

    /**
     * @param id  流程
     * @param req 流程头
     * @return 详情
     */
    @PutMapping("/flows/{id}")
    @Operation(summary = "修改流程头")
    public ApiResult<FlowDetailVO> header(@PathVariable Long id, @Valid @RequestBody FlowHeaderRequest req) {
        return ApiResult.ok(flowService.updateHeader(id, req));
    }

    /**
     * @param id  流程
     * @param req 模板
     * @return 模板详情
     */
    @PostMapping("/flows/{id}/save-template")
    @Operation(summary = "存为通用模板")
    public ApiResult<FlowDetailVO> template(@PathVariable Long id, @Valid @RequestBody SaveTemplateRequest req) {
        return ApiResult.ok(flowService.saveTemplate(id, req));
    }

    /**
     * @param id 流程
     * @return 校验结果写在详情的 errors / warnings 里
     */
    @PostMapping("/flows/{id}/validate")
    @Operation(summary = "发布前校验")
    public ApiResult<FlowDetailVO> validate(@PathVariable Long id) {
        return ApiResult.ok(flowService.validate(id));
    }

    /**
     * @param id  流程
     * @param req 修订号
     * @return 发布后的详情
     */
    @PostMapping("/flows/{id}/publish")
    @Operation(summary = "发布流程")
    public ApiResult<FlowDetailVO> publish(@PathVariable Long id, @Valid @RequestBody RevRequest req) {
        return ApiResult.ok(flowService.publish(id, req.getRev()));
    }

    /**
     * @param id  流程
     * @param req 修订号
     * @return 空
     */
    @DeleteMapping("/flows/{id}")
    @Operation(summary = "删除流程")
    public ApiResult<Void> delete(@PathVariable Long id, @Valid @RequestBody RevRequest req) {
        flowService.delete(id, req.getRev());
        return ApiResult.ok();
    }

    /**
     * @param id  流程
     * @param req 步骤
     * @return 详情
     */
    @PostMapping("/flows/{id}/steps")
    @Operation(summary = "添加步骤")
    public ApiResult<FlowDetailVO> addStep(@PathVariable Long id, @Valid @RequestBody StepCreateRequest req) {
        return ApiResult.ok(flowService.addStep(id, req));
    }

    /**
     * @param id     流程
     * @param stepId 步骤
     * @param req    内容
     * @return 详情
     */
    @PutMapping("/flows/{id}/steps/{stepId}")
    @Operation(summary = "修改步骤")
    public ApiResult<FlowDetailVO> updateStep(@PathVariable Long id, @PathVariable Long stepId,
                                              @Valid @RequestBody StepUpdateRequest req) {
        return ApiResult.ok(flowService.updateStep(id, stepId, req));
    }

    /**
     * @param id     流程
     * @param stepId 步骤
     * @param req    修订号
     * @return 详情
     */
    @DeleteMapping("/flows/{id}/steps/{stepId}")
    @Operation(summary = "删除步骤")
    public ApiResult<FlowDetailVO> deleteStep(@PathVariable Long id, @PathVariable Long stepId,
                                              @Valid @RequestBody RevRequest req) {
        return ApiResult.ok(flowService.deleteStep(id, stepId, req.getRev()));
    }

    /**
     * @param id  流程
     * @param req 顺序
     * @return 详情
     */
    @PostMapping("/flows/{id}/steps/reorder")
    @Operation(summary = "调整步骤顺序")
    public ApiResult<FlowDetailVO> reorder(@PathVariable Long id, @Valid @RequestBody ReorderRequest req) {
        return ApiResult.ok(flowService.reorder(id, req));
    }

    /**
     * @param id     流程
     * @param stepId 步骤
     * @param req    修订号
     * @return 详情
     */
    @PostMapping("/flows/{id}/steps/{stepId}/copy")
    @Operation(summary = "复制步骤")
    public ApiResult<FlowDetailVO> copyStep(@PathVariable Long id, @PathVariable Long stepId,
                                            @Valid @RequestBody RevRequest req) {
        return ApiResult.ok(flowService.copyStep(id, stepId, req.getRev()));
    }

    /**
     * @param id     流程
     * @param stepId 步骤
     * @param req    数据卡
     * @return 详情
     */
    @PostMapping("/flows/{id}/steps/{stepId}/cards")
    @Operation(summary = "添加数据卡")
    public ApiResult<FlowDetailVO> addCard(@PathVariable Long id, @PathVariable Long stepId,
                                           @Valid @RequestBody CardSaveRequest req) {
        return ApiResult.ok(flowService.addCard(id, stepId, req));
    }

    /**
     * @param id     流程
     * @param cardId 数据卡
     * @param req    内容
     * @return 详情
     */
    @PutMapping("/flows/{id}/cards/{cardId}")
    @Operation(summary = "修改数据卡")
    public ApiResult<FlowDetailVO> updateCard(@PathVariable Long id, @PathVariable Long cardId,
                                              @Valid @RequestBody CardSaveRequest req) {
        return ApiResult.ok(flowService.updateCard(id, cardId, req));
    }

    /**
     * @param id     流程
     * @param cardId 数据卡
     * @param req    修订号
     * @return 详情
     */
    @DeleteMapping("/flows/{id}/cards/{cardId}")
    @Operation(summary = "删除数据卡")
    public ApiResult<FlowDetailVO> deleteCard(@PathVariable Long id, @PathVariable Long cardId,
                                              @Valid @RequestBody RevRequest req) {
        return ApiResult.ok(flowService.deleteCard(id, cardId, req.getRev()));
    }

    /**
     * @param id     流程
     * @param stepId 步骤
     * @param req    出口
     * @return 详情
     */
    @PutMapping("/flows/{id}/steps/{stepId}/branches")
    @Operation(summary = "保存出口")
    public ApiResult<FlowDetailVO> branches(@PathVariable Long id, @PathVariable Long stepId,
                                            @Valid @RequestBody BranchReplaceRequest req) {
        return ApiResult.ok(flowService.replaceBranches(id, stepId, req));
    }

    /**
     * @param id     流程
     * @param stepId 步骤
     * @param req    确认项
     * @return 详情
     */
    @PutMapping("/flows/{id}/steps/{stepId}/confirms")
    @Operation(summary = "保存确认项")
    public ApiResult<FlowDetailVO> confirms(@PathVariable Long id, @PathVariable Long stepId,
                                            @Valid @RequestBody ConfirmReplaceRequest req) {
        return ApiResult.ok(flowService.replaceConfirms(id, stepId, req));
    }

    /**
     * @param faultRuleId 故障，可空表示全部
     * @return 试跑事件
     */
    @GetMapping("/trials")
    @Operation(summary = "试跑事件列表")
    public ApiResult<List<TrialVO>> trials(@RequestParam(required = false) Long faultRuleId) {
        return ApiResult.ok(trialService.list(faultRuleId));
    }

    /**
     * @param id 事件
     * @return 曲线和答案
     */
    @GetMapping("/trials/{id}")
    @Operation(summary = "试跑事件详情")
    public ApiResult<TrialVO> trial(@PathVariable Long id) {
        return ApiResult.ok(trialService.detail(id));
    }

    /**
     * @param id     事件
     * @param stepId 步骤
     * @return 数据卡统计和系统预判
     */
    @PostMapping("/trials/{id}/steps/{stepId}/evaluate")
    @Operation(summary = "试跑单步预判")
    public ApiResult<TrialVO.StepEval> evaluate(@PathVariable Long id, @PathVariable Long stepId) {
        return ApiResult.ok(trialService.evaluate(id, stepId));
    }
}
