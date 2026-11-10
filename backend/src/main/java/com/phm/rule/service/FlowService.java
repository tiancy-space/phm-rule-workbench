package com.phm.rule.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.phm.rule.common.BizException;
import com.phm.rule.common.OperatorHolder;
import com.phm.rule.common.Texts;
import com.phm.rule.dto.BranchItem;
import com.phm.rule.dto.BranchReplaceRequest;
import com.phm.rule.dto.CardSaveRequest;
import com.phm.rule.dto.ConfirmItem;
import com.phm.rule.dto.ConfirmReplaceRequest;
import com.phm.rule.dto.FlowBindRequest;
import com.phm.rule.dto.FlowCopyRequest;
import com.phm.rule.dto.FlowCreateRequest;
import com.phm.rule.dto.FlowHeaderRequest;
import com.phm.rule.dto.ReorderRequest;
import com.phm.rule.dto.SaveTemplateRequest;
import com.phm.rule.dto.StepCreateRequest;
import com.phm.rule.dto.StepUpdateRequest;
import com.phm.rule.dto.UnbindRequest;
import com.phm.rule.entity.DisposeBranch;
import com.phm.rule.entity.DisposeCard;
import com.phm.rule.entity.DisposeConfirm;
import com.phm.rule.entity.DisposeFlow;
import com.phm.rule.entity.DisposeFlowBind;
import com.phm.rule.entity.DisposeFlowVer;
import com.phm.rule.entity.DisposeStep;
import com.phm.rule.entity.FaultRule;
import com.phm.rule.entity.RuleAtom;
import com.phm.rule.entity.RuleGroup;
import com.phm.rule.entity.RuleParamMeta;
import com.phm.rule.expression.AtomView;
import com.phm.rule.expression.ParamView;
import com.phm.rule.mapper.DisposeBranchMapper;
import com.phm.rule.mapper.DisposeCardMapper;
import com.phm.rule.mapper.DisposeConfirmMapper;
import com.phm.rule.mapper.DisposeFlowBindMapper;
import com.phm.rule.mapper.DisposeFlowMapper;
import com.phm.rule.mapper.DisposeFlowVerMapper;
import com.phm.rule.mapper.DisposeStepMapper;
import com.phm.rule.mapper.FaultRuleMapper;
import com.phm.rule.mapper.RuleAtomMapper;
import com.phm.rule.mapper.RuleGroupMapper;
import com.phm.rule.mapper.RuleParamMetaMapper;
import com.phm.rule.mapper.RuleQueryMapper;
import com.phm.rule.vo.FlowDetailVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 处置流程的编辑、绑定、校验和发布。
 * 已发布流程一旦被修改，会复制出「草稿 · 基于 vN」，已发布版本保持不动，直到再次发布。
 */
@Service
public class FlowService {

    private static final String SAMPLE = "示例内容，非正式规程，需按实际司机手册校核";

    private final DisposeFlowMapper flowMapper;
    private final DisposeFlowVerMapper verMapper;
    private final DisposeFlowBindMapper bindMapper;
    private final DisposeStepMapper stepMapper;
    private final DisposeCardMapper cardMapper;
    private final DisposeBranchMapper branchMapper;
    private final DisposeConfirmMapper confirmMapper;
    private final FaultRuleMapper faultMapper;
    private final RuleParamMetaMapper paramMapper;
    private final RuleAtomMapper atomMapper;
    private final RuleGroupMapper groupMapper;
    private final RuleQueryMapper queryMapper;
    private final CatalogService catalogService;
    private final FlowValidator validator = new FlowValidator();

    /**
     * @param flowMapper     流程头
     * @param verMapper      版本
     * @param bindMapper     绑定
     * @param stepMapper     步骤
     * @param cardMapper     数据卡
     * @param branchMapper   出口
     * @param confirmMapper  确认项
     * @param faultMapper    故障
     * @param paramMapper    参数
     * @param atomMapper     原子
     * @param groupMapper    命名组
     * @param queryMapper    物理删除
     * @param catalogService 目录
     */
    public FlowService(DisposeFlowMapper flowMapper, DisposeFlowVerMapper verMapper, DisposeFlowBindMapper bindMapper,
                       DisposeStepMapper stepMapper, DisposeCardMapper cardMapper, DisposeBranchMapper branchMapper,
                       DisposeConfirmMapper confirmMapper, FaultRuleMapper faultMapper, RuleParamMetaMapper paramMapper,
                       RuleAtomMapper atomMapper, RuleGroupMapper groupMapper, RuleQueryMapper queryMapper,
                       CatalogService catalogService) {
        this.flowMapper = flowMapper;
        this.verMapper = verMapper;
        this.bindMapper = bindMapper;
        this.stepMapper = stepMapper;
        this.cardMapper = cardMapper;
        this.branchMapper = branchMapper;
        this.confirmMapper = confirmMapper;
        this.faultMapper = faultMapper;
        this.paramMapper = paramMapper;
        this.atomMapper = atomMapper;
        this.groupMapper = groupMapper;
        this.queryMapper = queryMapper;
        this.catalogService = catalogService;
    }

    /**
     * @return 全部流程的编辑视图
     */
    public List<FlowDetailVO> list() {
        List<FlowDetailVO> out = new ArrayList<FlowDetailVO>();
        List<DisposeFlow> flows = flowMapper.selectList(new LambdaQueryWrapper<DisposeFlow>().orderByAsc(DisposeFlow::getFlowCode));
        for (DisposeFlow flow : flows) {
            out.add(build(flow.getId(), new ArrayList<String>()));
        }
        return out;
    }

    /**
     * @param id 流程主键
     * @return 详情
     */
    public FlowDetailVO detail(Long id) {
        must(id);
        return build(id, new ArrayList<String>());
    }

    /**
     * 按故障找它绑定的流程。
     *
     * @param faultId 故障主键
     * @return 流程，未配置时返回 null 的包装由控制器处理
     */
    public FlowDetailVO byFault(Long faultId) {
        DisposeFlowBind bind = bindMapper.selectOne(new LambdaQueryWrapper<DisposeFlowBind>()
                .eq(DisposeFlowBind::getFaultRuleId, faultId));
        if (bind == null) {
            return null;
        }
        return detail(bind.getFlowId());
    }

    /**
     * 新建空白专属流程或通用模板。专属流程含查看、结束两步并绑定该故障。
     *
     * @param req 请求
     * @return 新流程
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO create(FlowCreateRequest req) {
        if ("template".equalsIgnoreCase(req.getKind())) {
            DisposeFlow flow = newFlow(Texts.nextCode("FT", 2, queryMapper.allFlowCodes()),
                    blankName(req.getFlowName(), "新通用模板"), 1, 0, null);
            DisposeFlowVer ver = newVersion(flow, 1, 0, flow.getFlowName());
            seedBlank(ver.getId(), null);
            return detail(flow.getId());
        }
        FaultRule fault = requireActionable(req.getFaultRuleId());
        if (bindOf(fault.getId()) != null) {
            throw BizException.bad("该故障已经配置了处置流程");
        }
        String name = blankName(req.getFlowName(), fault.getGzmc() + " 处置流程");
        DisposeFlow flow = newFlow(uniqueFlowCode(fault.getGzdm()), name, 0, 0, null);
        DisposeFlowVer ver = newVersion(flow, 1, 0, name);
        seedBlank(ver.getId(), fault.getCx());
        bind(flow.getId(), fault.getId());
        return detail(flow.getId());
    }

    /**
     * 复制为某故障的专属草稿。
     *
     * @param sourceId 来源流程
     * @param req      目标故障
     * @return 新流程，附带参数不适用的提示
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO copyForFault(Long sourceId, FlowCopyRequest req) {
        DisposeFlow source = must(sourceId);
        if (req.getRev() != null && !req.getRev().equals(source.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        FaultRule fault = requireActionable(req.getFaultRuleId());
        DisposeFlowVer from = workingVersion(source.getId());
        DisposeFlow flow = newFlow(uniqueFlowCode(fault.getGzdm()), fault.getGzmc() + " 处置流程", 0,
                source.getIsSample() == null ? 0 : source.getIsSample(), source.getSampleNote());
        DisposeFlowVer ver = newVersion(flow, 1, 0, flow.getFlowName());
        copyGraph(from.getId(), ver.getId());
        detach(fault.getId(), flow.getId());
        bind(flow.getId(), fault.getId());
        return build(flow.getId(), unfitNotices(flow.getId()));
    }

    /**
     * 按勾选结果重设绑定。故障若原来在别的专属流程上，会被移过来；空了的专属流程自动删除。
     *
     * @param id  流程
     * @param req 最终绑定清单
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO bindAll(Long id, FlowBindRequest req) {
        DisposeFlow flow = touch(id, req.getRev());
        Set<Long> desired = new HashSet<Long>();
        if (req.getFaultRuleIds() != null) {
            desired.addAll(req.getFaultRuleIds());
        }
        if ((flow.getIsTemplate() == null || flow.getIsTemplate() == 0) && desired.isEmpty()) {
            throw BizException.bad("专属流程至少保留一个绑定故障。要彻底移除，请用删除");
        }
        for (Long faultId : desired) {
            requireActionable(faultId);
        }
        List<DisposeFlowBind> current = binds(id);
        for (DisposeFlowBind b : current) {
            if (!desired.contains(b.getFaultRuleId())) {
                queryMapper.deleteBindByFault(b.getFaultRuleId());
            }
        }
        for (Long faultId : desired) {
            detach(faultId, id);
            if (bindOf(faultId) == null) {
                bind(id, faultId);
            }
        }
        return build(id, unfitNotices(id));
    }

    /**
     * 解绑一条故障。专属流程不能解到一个都不剩。
     *
     * @param id  流程
     * @param req 故障和修订号
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO unbind(Long id, UnbindRequest req) {
        DisposeFlow flow = touch(id, req.getRev());
        List<DisposeFlowBind> current = binds(id);
        if ((flow.getIsTemplate() == null || flow.getIsTemplate() == 0) && current.size() <= 1) {
            throw BizException.bad("专属流程至少保留一个绑定故障。要彻底移除，请用删除");
        }
        queryMapper.deleteBindByFault(req.getFaultRuleId());
        return detail(id);
    }

    /**
     * 修改名称、默认窗口和运行信息。已发布流程会先分出草稿。
     *
     * @param id  流程
     * @param req 请求
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO updateHeader(Long id, FlowHeaderRequest req) {
        if (req.getWinPreSec() < 0 || req.getWinPreSec() > 3600 || req.getWinPostSec() < 0 || req.getWinPostSec() > 3600) {
            throw BizException.bad("取数窗口须在 0 到 3600 秒之间");
        }
        Draft draft = openDraft(id, req.getRev());
        String cols = Texts.runInfo(req.getRunInfoCols());
        flowMapper.update(null, new LambdaUpdateWrapper<DisposeFlow>()
                .eq(DisposeFlow::getId, id)
                .set(DisposeFlow::getFlowName, req.getFlowName().trim()));
        verMapper.update(null, new LambdaUpdateWrapper<DisposeFlowVer>()
                .eq(DisposeFlowVer::getId, draft.ver.getId())
                .set(DisposeFlowVer::getFlowName, req.getFlowName().trim())
                .set(DisposeFlowVer::getWinPreSec, req.getWinPreSec())
                .set(DisposeFlowVer::getWinPostSec, req.getWinPostSec())
                .set(DisposeFlowVer::getRunInfoCols, cols)
                .set(DisposeFlowVer::getUpdateBy, OperatorHolder.get())
                .set(DisposeFlowVer::getUpdateTime, LocalDateTime.now()));
        return detail(id);
    }

    /**
     * 存为通用模板。不勾选迁移时只复制一份草稿模板，原流程不动。
     *
     * @param id  来源
     * @param req 名称和是否迁移绑定
     * @return 模板详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO saveTemplate(Long id, SaveTemplateRequest req) {
        DisposeFlow source = must(id);
        if (!req.getRev().equals(source.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        if (req.isMigrateBindings()) {
            touch(id, req.getRev());
            flowMapper.update(null, new LambdaUpdateWrapper<DisposeFlow>()
                    .eq(DisposeFlow::getId, id)
                    .set(DisposeFlow::getIsTemplate, 1)
                    .set(DisposeFlow::getFlowName, req.getFlowName().trim()));
            DisposeFlowVer ver = workingVersion(id);
            verMapper.update(null, new LambdaUpdateWrapper<DisposeFlowVer>()
                    .eq(DisposeFlowVer::getId, ver.getId())
                    .set(DisposeFlowVer::getFlowName, req.getFlowName().trim()));
            return detail(id);
        }
        DisposeFlowVer from = workingVersion(id);
        DisposeFlow flow = newFlow(Texts.nextCode("FT", 2, queryMapper.allFlowCodes()), req.getFlowName().trim(), 1,
                source.getIsSample() == null ? 0 : source.getIsSample(), source.getSampleNote());
        DisposeFlowVer ver = newVersion(flow, 1, 0, flow.getFlowName());
        copyGraph(from.getId(), ver.getId());
        return detail(flow.getId());
    }

    /**
     * 校验，不发布。
     *
     * @param id 流程
     * @return 带错误列表的详情
     */
    public FlowDetailVO validate(Long id) {
        return detail(id);
    }

    /**
     * 草稿直接发布。有阻断问题时拒绝。
     *
     * @param id  流程
     * @param rev 修订号
     * @return 发布后的详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO publish(Long id, Integer rev) {
        DisposeFlow flow = touch(id, rev);
        DisposeFlowVer draft = findVer(id, "DRAFT");
        if (draft == null) {
            throw BizException.bad("当前没有未发布的修改");
        }
        FlowDetailVO view = build(id, new ArrayList<String>());
        if (!view.getErrors().isEmpty()) {
            throw BizException.bad("发布前需修正 " + view.getErrors().size() + " 个问题：" + view.getErrors().get(0));
        }
        DisposeFlowVer published = findVer(id, "PUBLISHED");
        if (published != null) {
            verMapper.update(null, new LambdaUpdateWrapper<DisposeFlowVer>()
                    .eq(DisposeFlowVer::getId, published.getId())
                    .set(DisposeFlowVer::getVerStatus, "ARCHIVED"));
        }
        verMapper.update(null, new LambdaUpdateWrapper<DisposeFlowVer>()
                .eq(DisposeFlowVer::getId, draft.getId())
                .set(DisposeFlowVer::getVerStatus, "PUBLISHED")
                .set(DisposeFlowVer::getPublishBy, OperatorHolder.get())
                .set(DisposeFlowVer::getPublishTime, LocalDateTime.now()));
        flowMapper.update(null, new LambdaUpdateWrapper<DisposeFlow>()
                .eq(DisposeFlow::getId, flow.getId())
                .set(DisposeFlow::getFlowStatus, "PUBLISHED")
                .set(DisposeFlow::getPubVerNo, draft.getVerNo())
                .set(DisposeFlow::getFlowName, draft.getFlowName()));
        return detail(id);
    }

    /**
     * 删除整套流程。绑定的故障变为未配置。
     *
     * @param id  流程
     * @param rev 修订号
     */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id, Integer rev) {
        touch(id, rev);
        queryMapper.deleteBindsByFlow(id);
        flowMapper.deleteById(id);
    }

    /**
     * 添加步骤。原步骤只有一个出口时，自动接成「原步骤 → 新步骤 → 原去向」。
     *
     * @param id  流程
     * @param req 类型和插入位置
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO addStep(Long id, StepCreateRequest req) {
        Draft draft = openDraft(id, req.getRev());
        Long afterId = mapStep(draft, req.getAfterStepId());
        List<DisposeStep> steps = stepsOf(draft.ver.getId());
        int index = steps.size();
        Long oldNext = null;
        if (afterId != null) {
            for (int i = 0; i < steps.size(); i++) {
                if (steps.get(i).getId().equals(afterId)) {
                    index = i + 1;
                    List<DisposeBranch> bs = branchesOf(afterId);
                    if (bs.size() == 1) {
                        oldNext = bs.get(0).getNextStepId();
                    }
                    break;
                }
            }
        }
        DisposeStep created = insertStep(draft.ver, req.getStepType(), index, steps);
        if (oldNext != null && afterId != null) {
            List<DisposeBranch> src = branchesOf(afterId);
            if (src.size() == 1) {
                branchMapper.update(null, new LambdaUpdateWrapper<DisposeBranch>()
                        .eq(DisposeBranch::getId, src.get(0).getId())
                        .set(DisposeBranch::getNextStepId, created.getId()));
            }
            List<DisposeBranch> newborn = branchesOf(created.getId());
            if (newborn.size() == 1) {
                branchMapper.update(null, new LambdaUpdateWrapper<DisposeBranch>()
                        .eq(DisposeBranch::getId, newborn.get(0).getId())
                        .set(DisposeBranch::getNextStepId, oldNext));
            }
        }
        return detail(id);
    }

    /**
     * 修改步骤基本信息。
     *
     * @param flowId 流程
     * @param stepId 步骤，可以是分叉草稿前的旧主键
     * @param req    内容
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO updateStep(Long flowId, Long stepId, StepUpdateRequest req) {
        Draft draft = openDraft(flowId, req.getRev());
        DisposeStep step = mustStep(mapStep(draft, stepId));
        boolean typeChanged = req.getStepType() != null && !req.getStepType().equals(step.getStepType());
        if (typeChanged) {
            assertType(req.getStepType());
            List<Long> oldTargets = new ArrayList<Long>();
            for (DisposeBranch b : branchesOf(step.getId())) {
                oldTargets.add(b.getNextStepId());
            }
            queryMapper.deleteBranches(step.getId());
            String[] defaults = defaultBranches(req.getStepType());
            for (int i = 0; i < defaults.length; i++) {
                Long target = i < oldTargets.size() ? oldTargets.get(i) : null;
                addBranch(step.getId(), i + 1, defaults[i], target, "NONE");
            }
            step.setStepType(req.getStepType());
            step.setRoleCodes(Texts.join(Arrays.asList(defaultRoles(req.getStepType()))));
            if ("END".equals(req.getStepType()) && (req.getConclusion() == null || req.getConclusion().trim().isEmpty())) {
                step.setConclusion("MAINTAIN");
            }
        }
        if (req.getStepTitle() != null) {
            step.setStepTitle(req.getStepTitle().trim());
        }
        if (req.getStepDesc() != null) {
            step.setStepDesc(blank(req.getStepDesc()));
        }
        if (!typeChanged && req.getRoleCodes() != null) {
            if (req.getRoleCodes().isEmpty()) {
                throw BizException.bad("请至少勾选一个角色");
            }
            step.setRoleCodes(Texts.join(req.getRoleCodes()));
        }
        if (req.getSafetyTip() != null) {
            step.setSafetyTip(blank(req.getSafetyTip()));
        }
        if (req.getManualRef() != null) {
            step.setManualRef(blank(req.getManualRef()));
        }
        if (req.getDriverAction() != null) {
            step.setDriverAction(blank(req.getDriverAction()));
        }
        if (req.getConclusion() != null) {
            step.setConclusion(blank(req.getConclusion()));
        }
        if (req.getPushRepair() != null) {
            step.setPushRepair(req.getPushRepair());
        }
        stepMapper.updateById(step);
        return detail(flowId);
    }

    /**
     * 删除步骤。原来指向它的出口变为未配置。至少保留一步。
     *
     * @param flowId 流程
     * @param stepId 步骤
     * @param rev    修订号
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO deleteStep(Long flowId, Long stepId, Integer rev) {
        Draft draft = openDraft(flowId, rev);
        Long id = mapStep(draft, stepId);
        List<DisposeStep> steps = stepsOf(draft.ver.getId());
        if (steps.size() <= 1) {
            throw BizException.bad("流程至少保留一个步骤");
        }
        queryMapper.clearBranchTarget(id);
        queryMapper.deleteBranches(id);
        queryMapper.deleteConfirms(id);
        queryMapper.deleteCards(id);
        queryMapper.deleteStep(id);
        renumber(draft.ver.getId());
        return detail(flowId);
    }

    /**
     * 按给定顺序重排。第一位是起点，出口指向的步骤主键不变。
     *
     * @param flowId 流程
     * @param req    顺序
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO reorder(Long flowId, ReorderRequest req) {
        Draft draft = openDraft(flowId, req.getRev());
        List<Long> ids = new ArrayList<Long>();
        for (Long raw : req.getStepIds()) {
            ids.add(mapStep(draft, raw));
        }
        queryMapper.shiftStepSeq(draft.ver.getId());
        for (int i = 0; i < ids.size(); i++) {
            queryMapper.setStepSeq(ids.get(i), i + 1);
        }
        return detail(flowId);
    }

    /**
     * 在该步之后复制一份。
     *
     * @param flowId 流程
     * @param stepId 步骤
     * @param rev    修订号
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO copyStep(Long flowId, Long stepId, Integer rev) {
        Draft draft = openDraft(flowId, rev);
        DisposeStep src = mustStep(mapStep(draft, stepId));
        List<DisposeStep> steps = stepsOf(draft.ver.getId());
        int index = 0;
        for (int i = 0; i < steps.size(); i++) {
            if (steps.get(i).getId().equals(src.getId())) {
                index = i + 1;
            }
        }
        DisposeStep copy = new DisposeStep();
        copy.setFlowVerId(draft.ver.getId());
        copy.setStepCode(nextStepCode(draft.ver.getId()));
        copy.setSeqNo(100000);
        copy.setStepType(src.getStepType());
        copy.setStepTitle(src.getStepTitle() + "（副本）");
        copy.setStepDesc(src.getStepDesc());
        copy.setRoleCodes(src.getRoleCodes());
        copy.setSafetyTip(src.getSafetyTip());
        copy.setManualRef(src.getManualRef());
        copy.setDriverAction(src.getDriverAction());
        copy.setConclusion(src.getConclusion());
        copy.setPushRepair(src.getPushRepair() == null ? 0 : src.getPushRepair());
        stepMapper.insert(copy);
        Map<Long, Long> cards = new HashMap<Long, Long>();
        for (DisposeCard c : cardsOf(src.getId())) {
            DisposeCard n = cloneCard(c, copy.getId());
            cardMapper.insert(n);
            cards.put(c.getId(), n.getId());
        }
        for (DisposeBranch b : branchesOf(src.getId())) {
            DisposeBranch n = new DisposeBranch();
            n.setStepId(copy.getId());
            n.setSeqNo(b.getSeqNo());
            n.setBranchLabel(b.getBranchLabel());
            n.setNextStepId(b.getNextStepId());
            n.setCondSrc(b.getCondSrc());
            n.setCondCardId(b.getCondCardId() == null ? null : cards.get(b.getCondCardId()));
            n.setCondStat(b.getCondStat());
            n.setCondOp(b.getCondOp());
            n.setCondVal(b.getCondVal());
            n.setCondAtomId(b.getCondAtomId());
            n.setCondGroupId(b.getCondGroupId());
            branchMapper.insert(n);
        }
        for (DisposeConfirm c : confirmsOf(src.getId())) {
            DisposeConfirm n = new DisposeConfirm();
            n.setStepId(copy.getId());
            n.setSeqNo(c.getSeqNo());
            n.setConfirmText(c.getConfirmText());
            n.setRoleCode(c.getRoleCode());
            n.setIsRequired(c.getIsRequired());
            confirmMapper.insert(n);
        }
        List<Long> order = new ArrayList<Long>();
        for (DisposeStep s : steps) {
            order.add(s.getId());
            if (s.getId().equals(src.getId())) {
                order.add(copy.getId());
            }
        }
        if (index == steps.size() && !order.contains(copy.getId())) {
            order.add(copy.getId());
        }
        queryMapper.shiftStepSeq(draft.ver.getId());
        for (int i = 0; i < order.size(); i++) {
            queryMapper.setStepSeq(order.get(i), i + 1);
        }
        return detail(flowId);
    }

    /**
     * 给步骤加一张数据卡。
     *
     * @param flowId 流程
     * @param stepId 步骤
     * @param req    卡片
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO addCard(Long flowId, Long stepId, CardSaveRequest req) {
        Draft draft = openDraft(flowId, req.getRev());
        DisposeStep step = mustStep(mapStep(draft, stepId));
        DisposeCard card = new DisposeCard();
        card.setStepId(step.getId());
        card.setCardCode(nextCardCode(step.getId()));
        card.setSeqNo(cardsOf(step.getId()).size() + 1);
        fillCard(card, req, draft.ver);
        cardMapper.insert(card);
        return detail(flowId);
    }

    /**
     * 修改数据卡。
     *
     * @param flowId 流程
     * @param cardId 卡片，分叉前的旧主键也可以
     * @param req    内容
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO updateCard(Long flowId, Long cardId, CardSaveRequest req) {
        Draft draft = openDraft(flowId, req.getRev());
        Long id = draft.cardMap.get(cardId);
        if (id == null) {
            id = cardId;
        }
        DisposeCard card = cardMapper.selectById(id);
        if (card == null) {
            throw BizException.notFound("数据卡不存在");
        }
        fillCard(card, req, draft.ver);
        cardMapper.updateById(card);
        return detail(flowId);
    }

    /**
     * 删除数据卡，引用它的条件改为人工判断。
     *
     * @param flowId 流程
     * @param cardId 卡片
     * @param rev    修订号
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO deleteCard(Long flowId, Long cardId, Integer rev) {
        Draft draft = openDraft(flowId, rev);
        Long id = draft.cardMap.containsKey(cardId) ? draft.cardMap.get(cardId) : cardId;
        branchMapper.update(null, new LambdaUpdateWrapper<DisposeBranch>()
                .eq(DisposeBranch::getCondCardId, id)
                .set(DisposeBranch::getCondSrc, "NONE")
                .set(DisposeBranch::getCondCardId, null)
                .set(DisposeBranch::getCondStat, null)
                .set(DisposeBranch::getCondOp, null)
                .set(DisposeBranch::getCondVal, null));
        cardMapper.deleteById(id);
        return detail(flowId);
    }

    /**
     * 整体替换一步的出口。
     *
     * @param flowId 流程
     * @param stepId 步骤
     * @param req    出口列表
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO replaceBranches(Long flowId, Long stepId, BranchReplaceRequest req) {
        Draft draft = openDraft(flowId, req.getRev());
        DisposeStep step = mustStep(mapStep(draft, stepId));
        if ("END".equals(step.getStepType()) && req.getBranches() != null && !req.getBranches().isEmpty()) {
            throw BizException.bad("结束步骤没有出口");
        }
        queryMapper.deleteBranches(step.getId());
        int seq = 1;
        if (req.getBranches() != null) {
            for (BranchItem item : req.getBranches()) {
                DisposeBranch b = new DisposeBranch();
                b.setStepId(step.getId());
                b.setSeqNo(seq++);
                b.setBranchLabel(item.getBranchLabel() == null ? "" : item.getBranchLabel().trim());
                Long next = mapStep(draft, item.getNextStepId());
                b.setNextStepId(next);
                String src = item.getCondSrc() == null ? "NONE" : item.getCondSrc();
                b.setCondSrc(src);
                if ("CARD".equals(src)) {
                    Long cardId = item.getCondCardId();
                    if (cardId != null && draft.cardMap.containsKey(cardId)) {
                        cardId = draft.cardMap.get(cardId);
                    }
                    b.setCondCardId(cardId);
                    b.setCondStat(item.getCondStat());
                    b.setCondOp(item.getCondOp());
                    b.setCondVal(item.getCondVal());
                } else if ("ATOM".equals(src)) {
                    b.setCondAtomId(item.getCondAtomId());
                } else if ("GROUP".equals(src)) {
                    b.setCondGroupId(item.getCondGroupId());
                }
                branchMapper.insert(b);
            }
        }
        return detail(flowId);
    }

    /**
     * 整体替换确认项。
     *
     * @param flowId 流程
     * @param stepId 步骤
     * @param req    确认项
     * @return 详情
     */
    @Transactional(rollbackFor = Exception.class)
    public FlowDetailVO replaceConfirms(Long flowId, Long stepId, ConfirmReplaceRequest req) {
        Draft draft = openDraft(flowId, req.getRev());
        DisposeStep step = mustStep(mapStep(draft, stepId));
        queryMapper.deleteConfirms(step.getId());
        int seq = 1;
        if (req.getConfirms() != null) {
            for (ConfirmItem item : req.getConfirms()) {
                if (item.getConfirmText() == null || item.getConfirmText().trim().isEmpty()) {
                    continue;
                }
                DisposeConfirm c = new DisposeConfirm();
                c.setStepId(step.getId());
                c.setSeqNo(seq++);
                c.setConfirmText(item.getConfirmText().trim());
                String role = item.getRoleCode() == null ? "EXPERT" : item.getRoleCode();
                c.setRoleCode(role);
                c.setIsRequired(item.getIsRequired() == null ? 1 : item.getIsRequired());
                confirmMapper.insert(c);
            }
        }
        return detail(flowId);
    }

    /**
     * 供试跑读取正在编辑的版本主键。
     *
     * @param flowId 流程
     * @return 草稿优先，否则已发布版本
     */
    public DisposeFlowVer workingVersion(Long flowId) {
        DisposeFlowVer draft = findVer(flowId, "DRAFT");
        if (draft != null) {
            return draft;
        }
        DisposeFlowVer published = findVer(flowId, "PUBLISHED");
        if (published == null) {
            throw BizException.bad("流程没有可执行的版本");
        }
        return published;
    }

    private Draft openDraft(Long flowId, Integer rev) {
        DisposeFlow flow = touch(flowId, rev);
        Draft ctx = new Draft();
        ctx.flow = flow;
        DisposeFlowVer draft = findVer(flowId, "DRAFT");
        if (draft == null) {
            DisposeFlowVer published = findVer(flowId, "PUBLISHED");
            if (published == null) {
                throw BizException.bad("流程没有可编辑的版本");
            }
            DisposeFlowVer created = newVersion(flow, flow.getPubVerNo() + 1, flow.getPubVerNo(), published.getFlowName());
            created.setWinPreSec(published.getWinPreSec());
            created.setWinPostSec(published.getWinPostSec());
            created.setRunInfoCols(published.getRunInfoCols());
            verMapper.updateById(created);
            copyGraph(published.getId(), created.getId(), ctx.stepMap, ctx.cardMap);
            flowMapper.update(null, new LambdaUpdateWrapper<DisposeFlow>()
                    .eq(DisposeFlow::getId, flowId)
                    .set(DisposeFlow::getFlowStatus, "DRAFT"));
            ctx.ver = created;
            return ctx;
        }
        ctx.ver = draft;
        for (DisposeStep s : stepsOf(draft.getId())) {
            ctx.stepMap.put(s.getId(), s.getId());
            for (DisposeCard c : cardsOf(s.getId())) {
                ctx.cardMap.put(c.getId(), c.getId());
            }
        }
        return ctx;
    }

    private DisposeFlow touch(Long id, Integer rev) {
        DisposeFlow flow = must(id);
        if (rev == null || !rev.equals(flow.getRev())) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        int n = flowMapper.update(null, new LambdaUpdateWrapper<DisposeFlow>()
                .eq(DisposeFlow::getId, id).eq(DisposeFlow::getRev, rev)
                .set(DisposeFlow::getRev, rev + 1)
                .set(DisposeFlow::getUpdateBy, OperatorHolder.get())
                .set(DisposeFlow::getUpdateTime, LocalDateTime.now()));
        if (n != 1) {
            throw BizException.conflict("数据已被他人修改，请刷新后重试");
        }
        flow.setRev(rev + 1);
        return flow;
    }

    private void copyGraph(Long fromVer, Long toVer) {
        copyGraph(fromVer, toVer, new HashMap<Long, Long>(), new HashMap<Long, Long>());
    }

    private void copyGraph(Long fromVer, Long toVer, Map<Long, Long> stepMap, Map<Long, Long> cardMap) {
        List<DisposeStep> steps = stepsOf(fromVer);
        for (DisposeStep s : steps) {
            DisposeStep n = new DisposeStep();
            n.setFlowVerId(toVer);
            n.setStepCode(s.getStepCode());
            n.setSeqNo(s.getSeqNo());
            n.setStepType(s.getStepType());
            n.setStepTitle(s.getStepTitle());
            n.setStepDesc(s.getStepDesc());
            n.setRoleCodes(s.getRoleCodes());
            n.setSafetyTip(s.getSafetyTip());
            n.setManualRef(s.getManualRef());
            n.setDriverAction(s.getDriverAction());
            n.setConclusion(s.getConclusion());
            n.setPushRepair(s.getPushRepair() == null ? 0 : s.getPushRepair());
            stepMapper.insert(n);
            stepMap.put(s.getId(), n.getId());
        }
        for (DisposeStep s : steps) {
            for (DisposeCard c : cardsOf(s.getId())) {
                DisposeCard n = cloneCard(c, stepMap.get(s.getId()));
                cardMapper.insert(n);
                cardMap.put(c.getId(), n.getId());
            }
        }
        for (DisposeStep s : steps) {
            for (DisposeBranch b : branchesOf(s.getId())) {
                DisposeBranch n = new DisposeBranch();
                n.setStepId(stepMap.get(s.getId()));
                n.setSeqNo(b.getSeqNo());
                n.setBranchLabel(b.getBranchLabel());
                n.setNextStepId(b.getNextStepId() == null ? null : stepMap.get(b.getNextStepId()));
                n.setCondSrc(b.getCondSrc());
                n.setCondCardId(b.getCondCardId() == null ? null : cardMap.get(b.getCondCardId()));
                n.setCondStat(b.getCondStat());
                n.setCondOp(b.getCondOp());
                n.setCondVal(b.getCondVal());
                n.setCondAtomId(b.getCondAtomId());
                n.setCondGroupId(b.getCondGroupId());
                branchMapper.insert(n);
            }
            for (DisposeConfirm c : confirmsOf(s.getId())) {
                DisposeConfirm n = new DisposeConfirm();
                n.setStepId(stepMap.get(s.getId()));
                n.setSeqNo(c.getSeqNo());
                n.setConfirmText(c.getConfirmText());
                n.setRoleCode(c.getRoleCode());
                n.setIsRequired(c.getIsRequired());
                confirmMapper.insert(n);
            }
        }
    }

    private DisposeCard cloneCard(DisposeCard c, Long stepId) {
        DisposeCard n = new DisposeCard();
        n.setStepId(stepId);
        n.setCardCode(c.getCardCode());
        n.setSeqNo(c.getSeqNo());
        n.setCardKind(c.getCardKind());
        n.setParamId(c.getParamId());
        n.setParamCol(c.getParamCol());
        n.setRelGzdm(c.getRelGzdm());
        n.setWinPreSec(c.getWinPreSec());
        n.setWinPostSec(c.getWinPostSec());
        n.setStatItems(c.getStatItems());
        n.setShowCurve(c.getShowCurve());
        n.setLimitOp(c.getLimitOp());
        n.setLimitVal(c.getLimitVal());
        n.setTargetVal(c.getTargetVal());
        return n;
    }

    private void seedBlank(Long verId, String cx) {
        DisposeFlowVer ver = verMapper.selectById(verId);
        DisposeStep view = new DisposeStep();
        view.setFlowVerId(verId);
        view.setStepCode("S1");
        view.setSeqNo(1);
        view.setStepType("VIEW");
        view.setStepTitle("查看运行状态与报警前后数据");
        view.setRoleCodes("EXPERT");
        view.setPushRepair(0);
        stepMapper.insert(view);
        RuleParamMeta speed = firstParam("SJSD");
        if (speed != null) {
            DisposeCard card = new DisposeCard();
            card.setStepId(view.getId());
            card.setCardCode("C1");
            card.setSeqNo(1);
            card.setCardKind("NUM");
            card.setParamId(speed.getId());
            card.setParamCol(speed.getParamCol());
            card.setWinPreSec(ver.getWinPreSec());
            card.setWinPostSec(ver.getWinPostSec());
            card.setStatItems("T0值,最大,最小");
            card.setShowCurve(1);
            card.setLimitOp("<");
            cardMapper.insert(card);
        }
        DisposeStep end = new DisposeStep();
        end.setFlowVerId(verId);
        end.setStepCode("S2");
        end.setSeqNo(2);
        end.setStepType("END");
        end.setStepTitle("维持运行");
        end.setRoleCodes("EXPERT");
        end.setConclusion("MAINTAIN");
        end.setPushRepair(0);
        stepMapper.insert(end);
        addBranch(view.getId(), 1, "下一步", end.getId(), "NONE");
    }

    private DisposeStep insertStep(DisposeFlowVer ver, String type, int index, List<DisposeStep> existing) {
        assertType(type);
        DisposeStep step = new DisposeStep();
        step.setFlowVerId(ver.getId());
        step.setStepCode(nextStepCode(ver.getId()));
        step.setSeqNo(100000 + index);
        step.setStepType(type);
        step.setStepTitle(defaultTitle(type));
        step.setRoleCodes(Texts.join(Arrays.asList(defaultRoles(type))));
        step.setPushRepair(0);
        if ("END".equals(type)) {
            step.setConclusion("MAINTAIN");
        }
        stepMapper.insert(step);
        String[] labels = defaultBranches(type);
        for (int i = 0; i < labels.length; i++) {
            addBranch(step.getId(), i + 1, labels[i], null, "NONE");
        }
        if ("OP".equals(type)) {
            addConfirm(step.getId(), 1, "司机已按指令执行并反馈结果", "DRIVER");
            addConfirm(step.getId(), 2, "专家已记录 / 复核司机反馈", "EXPERT");
        }
        List<Long> order = new ArrayList<Long>();
        for (DisposeStep s : existing) {
            order.add(s.getId());
        }
        if (index >= order.size()) {
            order.add(step.getId());
        } else {
            order.add(index, step.getId());
        }
        queryMapper.shiftStepSeq(ver.getId());
        for (int i = 0; i < order.size(); i++) {
            queryMapper.setStepSeq(order.get(i), i + 1);
        }
        return step;
    }

    private void addBranch(Long stepId, int seq, String label, Long next, String src) {
        DisposeBranch b = new DisposeBranch();
        b.setStepId(stepId);
        b.setSeqNo(seq);
        b.setBranchLabel(label);
        b.setNextStepId(next);
        b.setCondSrc(src);
        branchMapper.insert(b);
    }

    private void addConfirm(Long stepId, int seq, String text, String role) {
        DisposeConfirm c = new DisposeConfirm();
        c.setStepId(stepId);
        c.setSeqNo(seq);
        c.setConfirmText(text);
        c.setRoleCode(role);
        c.setIsRequired(1);
        confirmMapper.insert(c);
    }

    private void fillCard(DisposeCard card, CardSaveRequest req, DisposeFlowVer ver) {
        String kind = req.getCardKind();
        if (!"NUM".equals(kind) && !"STATE".equals(kind) && !"FAULT".equals(kind)) {
            throw BizException.bad("数据卡类型不正确");
        }
        int pre = req.getWinPreSec() == null ? ver.getWinPreSec() : req.getWinPreSec();
        int post = req.getWinPostSec() == null ? ver.getWinPostSec() : req.getWinPostSec();
        if (pre < 0 || pre > 3600 || post < 0 || post > 3600) {
            throw BizException.bad("取数窗口须在 0 到 3600 秒之间");
        }
        card.setCardKind(kind);
        card.setWinPreSec(pre);
        card.setWinPostSec(post);
        if ("FAULT".equals(kind)) {
            if (req.getRelGzdm() == null || req.getRelGzdm().trim().isEmpty()) {
                throw BizException.bad("请填写关联故障代码");
            }
            card.setParamId(null);
            card.setParamCol(null);
            card.setRelGzdm(Texts.join(Texts.splitComma(req.getRelGzdm().replace('，', ','))));
            card.setStatItems(blank(req.getStatItems()) == null ? "出现次数" : req.getStatItems());
            card.setShowCurve(0);
            card.setLimitOp(null);
            card.setLimitVal(null);
            card.setTargetVal(null);
            return;
        }
        if (req.getParamCol() == null || req.getParamCol().trim().isEmpty()) {
            throw BizException.bad("请选择参数");
        }
        RuleParamMeta param = firstParam(req.getParamCol().trim());
        if (param == null) {
            throw BizException.bad("参数不在元数据中：" + req.getParamCol());
        }
        card.setParamId(param.getId());
        card.setParamCol(param.getParamCol());
        card.setRelGzdm(null);
        if ("NUM".equals(kind)) {
            card.setStatItems(blank(req.getStatItems()) == null ? "T0值,最大,最小" : req.getStatItems());
            card.setShowCurve(req.getShowCurve() == null ? 1 : req.getShowCurve());
            card.setLimitOp(blank(req.getLimitOp()));
            card.setLimitVal(blank(req.getLimitVal()));
            card.setTargetVal(null);
        } else {
            card.setStatItems(blank(req.getStatItems()) == null ? "T0值,变位次数" : req.getStatItems());
            card.setShowCurve(0);
            card.setLimitOp(null);
            card.setLimitVal(null);
            card.setTargetVal(blank(req.getTargetVal()) == null ? "1" : req.getTargetVal().trim());
        }
    }

    private FlowDetailVO build(Long flowId, List<String> notices) {
        DisposeFlow flow = must(flowId);
        DisposeFlowVer ver = workingVersion(flowId);
        FlowDetailVO vo = new FlowDetailVO();
        vo.setId(flow.getId());
        vo.setFlowCode(flow.getFlowCode());
        vo.setFlowName(flow.getFlowName());
        vo.setIsTemplate(flow.getIsTemplate());
        vo.setFlowStatus(flow.getFlowStatus());
        vo.setPubVerNo(flow.getPubVerNo());
        vo.setIsSample(flow.getIsSample());
        vo.setSampleNote(flow.getSampleNote());
        vo.setRev(flow.getRev());
        vo.setEditingVerNo(ver.getVerNo());
        vo.setBaseVerNo(ver.getBaseVerNo());
        vo.setVerStatus(ver.getVerStatus());
        vo.setWinPreSec(ver.getWinPreSec());
        vo.setWinPostSec(ver.getWinPostSec());
        vo.setRunInfoCols(ver.getRunInfoCols());
        vo.setNotices(notices);
        List<String> cxs = new ArrayList<String>();
        for (DisposeFlowBind b : binds(flowId)) {
            FaultRule f = faultMapper.selectById(b.getFaultRuleId());
            if (f == null) {
                continue;
            }
            FlowDetailVO.BindVO bind = new FlowDetailVO.BindVO();
            bind.setFaultRuleId(f.getId());
            bind.setCx(f.getCx());
            bind.setLy(f.getLy());
            bind.setGzdm(f.getGzdm());
            bind.setGzmc(f.getGzmc());
            bind.setCzdj(f.getCzdj());
            vo.getBindings().add(bind);
            if (!cxs.contains(f.getCx())) {
                cxs.add(f.getCx());
            }
        }
        Map<Long, DisposeStep> stepById = new HashMap<Long, DisposeStep>();
        List<DisposeStep> steps = stepsOf(ver.getId());
        for (DisposeStep s : steps) {
            stepById.put(s.getId(), s);
        }
        Map<Long, ParamView> params = new HashMap<Long, ParamView>();
        for (RuleParamMeta p : paramMapper.selectList(null)) {
            params.put(p.getId(), catalogService.toParam(p));
        }
        Map<Long, AtomView> atoms = new HashMap<Long, AtomView>();
        Map<Long, String> atomCodes = new HashMap<Long, String>();
        for (RuleAtom a : atomMapper.selectList(null)) {
            atoms.put(a.getId(), catalogService.toAtom(a));
            atomCodes.put(a.getId(), a.getAtomCode());
        }
        Map<Long, AtomView> groups = new HashMap<Long, AtomView>();
        Map<Long, String> groupCodes = new HashMap<Long, String>();
        for (RuleGroup g : groupMapper.selectList(null)) {
            AtomView view = new AtomView();
            view.code = g.getGroupCode();
            view.name = g.getGroupName();
            view.type = "GROUP";
            view.scopeCx = g.getScopeCx();
            groups.put(g.getId(), view);
            groupCodes.put(g.getId(), g.getGroupCode());
        }
        List<FlowValidator.Step> snapshots = new ArrayList<FlowValidator.Step>();
        for (DisposeStep s : steps) {
            FlowDetailVO.StepVO sv = new FlowDetailVO.StepVO();
            sv.setId(s.getId());
            sv.setStepCode(s.getStepCode());
            sv.setSeqNo(s.getSeqNo());
            sv.setStepType(s.getStepType());
            sv.setStepTitle(s.getStepTitle());
            sv.setStepDesc(s.getStepDesc());
            sv.setRoleCodes(Texts.splitComma(s.getRoleCodes()));
            sv.setSafetyTip(s.getSafetyTip());
            sv.setManualRef(s.getManualRef());
            sv.setDriverAction(s.getDriverAction());
            sv.setConclusion(s.getConclusion());
            sv.setPushRepair(s.getPushRepair());
            FlowValidator.Step snap = new FlowValidator.Step();
            snap.id = s.getId();
            snap.type = s.getStepType();
            snap.title = s.getStepTitle();
            snap.roles = sv.getRoleCodes();
            snap.conclusion = s.getConclusion();
            for (DisposeCard c : cardsOf(s.getId())) {
                FlowDetailVO.CardVO cv = new FlowDetailVO.CardVO();
                cv.setId(c.getId());
                cv.setCardCode(c.getCardCode());
                cv.setSeqNo(c.getSeqNo());
                cv.setCardKind(c.getCardKind());
                cv.setParamId(c.getParamId());
                cv.setParamCol(c.getParamCol());
                cv.setRelGzdm(c.getRelGzdm());
                cv.setWinPreSec(c.getWinPreSec());
                cv.setWinPostSec(c.getWinPostSec());
                cv.setStatItems(c.getStatItems());
                cv.setShowCurve(c.getShowCurve());
                cv.setLimitOp(c.getLimitOp());
                cv.setLimitVal(c.getLimitVal());
                cv.setTargetVal(c.getTargetVal());
                ParamView p = c.getParamId() == null ? null : params.get(c.getParamId());
                if (p != null) {
                    cv.setParamName(p.name);
                    cv.setUnit(p.unit);
                    cv.setDataType(p.dataType);
                    cv.setEnumDict(p.enumDict);
                    for (String cx : cxs) {
                        if (!p.fits(cx)) {
                            cv.getUnfitCx().add(cx);
                        }
                    }
                }
                sv.getCards().add(cv);
                FlowValidator.Card card = new FlowValidator.Card();
                card.id = c.getId();
                card.code = c.getCardCode();
                card.kind = c.getCardKind();
                card.paramId = c.getParamId();
                card.codes = c.getRelGzdm();
                card.pre = c.getWinPreSec();
                card.post = c.getWinPostSec();
                snap.cards.add(card);
            }
            for (DisposeBranch b : branchesOf(s.getId())) {
                FlowDetailVO.BranchVO bv = new FlowDetailVO.BranchVO();
                bv.setId(b.getId());
                bv.setSeqNo(b.getSeqNo());
                bv.setBranchLabel(b.getBranchLabel());
                bv.setNextStepId(b.getNextStepId());
                DisposeStep next = b.getNextStepId() == null ? null : stepById.get(b.getNextStepId());
                bv.setNextStepCode(next == null ? null : next.getStepCode());
                bv.setCondSrc(b.getCondSrc());
                bv.setCondCardId(b.getCondCardId());
                bv.setCondStat(b.getCondStat());
                bv.setCondOp(b.getCondOp());
                bv.setCondVal(b.getCondVal());
                bv.setCondAtomId(b.getCondAtomId());
                bv.setCondAtomCode(atomCodes.get(b.getCondAtomId()));
                bv.setCondGroupId(b.getCondGroupId());
                bv.setCondGroupCode(groupCodes.get(b.getCondGroupId()));
                sv.getBranches().add(bv);
                FlowValidator.Branch br = new FlowValidator.Branch();
                br.label = b.getBranchLabel();
                br.nextId = b.getNextStepId();
                br.condSrc = b.getCondSrc();
                br.cardId = b.getCondCardId();
                br.stat = b.getCondStat();
                br.value = b.getCondVal();
                br.refId = "GROUP".equals(b.getCondSrc()) ? b.getCondGroupId() : b.getCondAtomId();
                snap.branches.add(br);
            }
            for (DisposeConfirm c : confirmsOf(s.getId())) {
                FlowDetailVO.ConfirmVO cv = new FlowDetailVO.ConfirmVO();
                cv.setId(c.getId());
                cv.setSeqNo(c.getSeqNo());
                cv.setConfirmText(c.getConfirmText());
                cv.setRoleCode(c.getRoleCode());
                cv.setIsRequired(c.getIsRequired());
                sv.getConfirms().add(cv);
            }
            vo.getSteps().add(sv);
            snapshots.add(snap);
        }
        FlowValidator.Result result = validator.validate(snapshots, cxs,
                flow.getIsTemplate() != null && flow.getIsTemplate() == 1, vo.getBindings().size(), atoms, groups, params);
        vo.setErrors(result.errors);
        vo.setWarnings(result.warnings);
        return vo;
    }

    private List<String> unfitNotices(Long flowId) {
        FlowDetailVO vo = build(flowId, new ArrayList<String>());
        List<String> notes = new ArrayList<String>();
        for (String err : vo.getErrors()) {
            if (err.contains("不适用于") || err.contains("不匹配")) {
                notes.add(err);
            }
        }
        return notes;
    }

    private void renumber(Long verId) {
        List<DisposeStep> steps = stepsOf(verId);
        queryMapper.shiftStepSeq(verId);
        for (int i = 0; i < steps.size(); i++) {
            queryMapper.setStepSeq(steps.get(i).getId(), i + 1);
        }
    }

    private String nextStepCode(Long verId) {
        int max = 0;
        for (DisposeStep s : stepsOf(verId)) {
            if (s.getStepCode() != null && s.getStepCode().matches("S\\d+")) {
                max = Math.max(max, Integer.parseInt(s.getStepCode().substring(1)));
            }
        }
        return "S" + (max + 1);
    }

    private String nextCardCode(Long stepId) {
        int max = 0;
        for (DisposeCard c : cardsOf(stepId)) {
            if (c.getCardCode() != null && c.getCardCode().matches("C\\d+")) {
                max = Math.max(max, Integer.parseInt(c.getCardCode().substring(1)));
            }
        }
        return "C" + (max + 1);
    }

    private Long mapStep(Draft draft, Long raw) {
        if (raw == null) {
            return null;
        }
        Long mapped = draft.stepMap.get(raw);
        return mapped == null ? raw : mapped;
    }

    private DisposeFlow newFlow(String code, String name, int template, int sample, String note) {
        DisposeFlow flow = new DisposeFlow();
        flow.setFlowCode(code);
        flow.setFlowName(name);
        flow.setIsTemplate(template);
        flow.setFlowStatus("DRAFT");
        flow.setPubVerNo(0);
        flow.setIsSample(sample);
        flow.setSampleNote(sample == 1 ? (note == null ? SAMPLE : note) : null);
        flow.setRev(1);
        flowMapper.insert(flow);
        return flow;
    }

    private DisposeFlowVer newVersion(DisposeFlow flow, int verNo, int base, String name) {
        DisposeFlowVer ver = new DisposeFlowVer();
        ver.setFlowId(flow.getId());
        ver.setVerNo(verNo);
        ver.setVerStatus("DRAFT");
        ver.setBaseVerNo(base);
        ver.setFlowName(name);
        ver.setWinPreSec(60);
        ver.setWinPostSec(30);
        ver.setRunInfoCols("CC,SD,WZ,SJ,FSSJ");
        verMapper.insert(ver);
        return ver;
    }

    private void bind(Long flowId, Long faultId) {
        DisposeFlowBind row = new DisposeFlowBind();
        row.setFlowId(flowId);
        row.setFaultRuleId(faultId);
        bindMapper.insert(row);
    }

    private void detach(Long faultId, Long keepFlowId) {
        DisposeFlowBind old = bindOf(faultId);
        if (old == null || old.getFlowId().equals(keepFlowId)) {
            return;
        }
        Long oldFlowId = old.getFlowId();
        queryMapper.deleteBindByFault(faultId);
        DisposeFlow oldFlow = flowMapper.selectById(oldFlowId);
        if (oldFlow != null && (oldFlow.getIsTemplate() == null || oldFlow.getIsTemplate() == 0)) {
            long left = bindMapper.selectCount(new LambdaQueryWrapper<DisposeFlowBind>().eq(DisposeFlowBind::getFlowId, oldFlowId));
            if (left == 0) {
                flowMapper.deleteById(oldFlowId);
            }
        }
    }

    private DisposeFlowBind bindOf(Long faultId) {
        return bindMapper.selectOne(new LambdaQueryWrapper<DisposeFlowBind>().eq(DisposeFlowBind::getFaultRuleId, faultId));
    }

    private List<DisposeFlowBind> binds(Long flowId) {
        return bindMapper.selectList(new LambdaQueryWrapper<DisposeFlowBind>().eq(DisposeFlowBind::getFlowId, flowId));
    }

    private FaultRule requireActionable(Long faultId) {
        if (faultId == null) {
            throw BizException.bad("请选择故障");
        }
        FaultRule fault = faultMapper.selectById(faultId);
        if (fault == null) {
            throw BizException.notFound("故障不存在");
        }
        if ("NONE".equals(fault.getCzdj())) {
            throw BizException.bad("无需干预类故障不配处置流程");
        }
        return fault;
    }

    private DisposeFlow must(Long id) {
        DisposeFlow flow = flowMapper.selectById(id);
        if (flow == null) {
            throw BizException.notFound("处置流程不存在");
        }
        return flow;
    }

    private DisposeStep mustStep(Long id) {
        DisposeStep step = stepMapper.selectById(id);
        if (step == null) {
            throw BizException.notFound("步骤不存在");
        }
        return step;
    }

    private DisposeFlowVer findVer(Long flowId, String status) {
        return verMapper.selectOne(new LambdaQueryWrapper<DisposeFlowVer>()
                .eq(DisposeFlowVer::getFlowId, flowId)
                .eq(DisposeFlowVer::getVerStatus, status));
    }

    private List<DisposeStep> stepsOf(Long verId) {
        return stepMapper.selectList(new LambdaQueryWrapper<DisposeStep>()
                .eq(DisposeStep::getFlowVerId, verId).orderByAsc(DisposeStep::getSeqNo));
    }

    private List<DisposeCard> cardsOf(Long stepId) {
        return cardMapper.selectList(new LambdaQueryWrapper<DisposeCard>()
                .eq(DisposeCard::getStepId, stepId).orderByAsc(DisposeCard::getSeqNo));
    }

    private List<DisposeBranch> branchesOf(Long stepId) {
        return branchMapper.selectList(new LambdaQueryWrapper<DisposeBranch>()
                .eq(DisposeBranch::getStepId, stepId).orderByAsc(DisposeBranch::getSeqNo));
    }

    private List<DisposeConfirm> confirmsOf(Long stepId) {
        return confirmMapper.selectList(new LambdaQueryWrapper<DisposeConfirm>()
                .eq(DisposeConfirm::getStepId, stepId).orderByAsc(DisposeConfirm::getSeqNo));
    }

    private RuleParamMeta firstParam(String code) {
        List<RuleParamMeta> rows = paramMapper.selectList(new LambdaQueryWrapper<RuleParamMeta>()
                .eq(RuleParamMeta::getParamCol, code));
        return rows.isEmpty() ? null : rows.get(0);
    }

    private String uniqueFlowCode(String gzdm) {
        String base = "FL" + (gzdm == null ? "" : gzdm.replaceAll("[^A-Za-z0-9]", ""));
        if ("FL".equals(base)) {
            base = "FLX";
        }
        Set<String> used = new HashSet<String>(queryMapper.allFlowCodes());
        String code = base;
        int n = 2;
        while (used.contains(code)) {
            code = base + n;
            n++;
        }
        return code;
    }

    private String blankName(String given, String fallback) {
        return given == null || given.trim().isEmpty() ? fallback : given.trim();
    }

    private String blank(String s) {
        return s == null || s.trim().isEmpty() ? null : s.trim();
    }

    private void assertType(String type) {
        if (!Arrays.asList("VIEW", "JUDGE", "OP", "CONTACT", "END").contains(type)) {
            throw BizException.bad("步骤类型不正确");
        }
    }

    private String defaultTitle(String type) {
        if ("JUDGE".equals(type)) {
            return "是否正常？";
        }
        if ("OP".equals(type)) {
            return "执行操作";
        }
        if ("CONTACT".equals(type)) {
            return "联络调度 / 检修";
        }
        if ("END".equals(type)) {
            return "维持运行";
        }
        return "查看数据";
    }

    private String[] defaultRoles(String type) {
        if ("JUDGE".equals(type)) {
            return new String[]{"SYSTEM", "EXPERT"};
        }
        if ("OP".equals(type)) {
            return new String[]{"DRIVER", "EXPERT"};
        }
        return new String[]{"EXPERT"};
    }

    private String[] defaultBranches(String type) {
        if ("JUDGE".equals(type)) {
            return new String[]{"是", "否"};
        }
        if ("OP".equals(type)) {
            return new String[]{"成功", "未成功"};
        }
        if ("CONTACT".equals(type)) {
            return new String[]{"已联络"};
        }
        if ("END".equals(type)) {
            return new String[0];
        }
        return new String[]{"下一步"};
    }

    private static final class Draft {
        private DisposeFlow flow;
        private DisposeFlowVer ver;
        private final Map<Long, Long> stepMap = new LinkedHashMap<Long, Long>();
        private final Map<Long, Long> cardMap = new LinkedHashMap<Long, Long>();
    }
}
