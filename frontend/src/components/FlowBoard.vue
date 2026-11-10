<template>
  <div class="mask" @keydown.esc="esc">
    <div class="board">
      <header class="bhead">
        <b>处置流程管理</b>
        <el-button type="text" @click="$emit('close')">× 关闭</el-button>
      </header>
      <div class="bcols" :class="{ wide: right === 'view' }">
        <aside class="scroll pane">
          <el-radio-group v-model="tab" size="mini">
            <el-radio-button label="fault">故障</el-radio-button>
            <el-radio-button label="tpl">通用模板</el-radio-button>
          </el-radio-group>
          <el-input v-model="q" size="mini" placeholder="搜索" clearable style="margin:6px 0" />
          <template v-if="tab==='fault'">
            <div v-for="f in faultRows" :key="f.id" class="fcard" :class="{active: sel && sel.type==='fault' && sel.faultId===f.id}" @click="selectFault(f)">
              <div><b>{{ f.gzdm }}</b> <span class="tag" :class="'cz-'+f.czdj">{{ f.czdj==='CHECK'?'排查':'关注' }}</span> {{ f.cx }}</div>
              <div>{{ f.gzmc }}</div>
              <div class="muted" v-if="f.flowId">{{ f.flowStatus==='PUBLISHED' ? ('已发布 v'+f.pubVerNo) : '草稿' }} · {{ f.stepCount }} 步
                <span v-if="f.isTemplate"> · 模板</span>
              </div>
              <div class="muted" v-else>○ 未配置处置流程</div>
            </div>
          </template>
          <template v-else>
            <el-button size="mini" type="primary" @click="createTpl">＋ 新建通用模板</el-button>
            <div v-for="t in templates" :key="t.id" class="fcard" :class="{active: sel && sel.flowId===t.id}" @click="selectFlow(t)">
              <div>◆ {{ t.flowName }}</div>
              <div class="muted">{{ t.flowStatus }} · 绑定 {{ t.bindings.length }} 个故障</div>
            </div>
          </template>
        </aside>
        <section class="scroll pane" v-if="flow">
          <div v-if="flow.isSample===1" class="banner">⚠ {{ flow.sampleNote || '示例内容，非正式规程，需按实际司机手册校核' }}</div>
          <div v-if="flow.bindings.length>1 || flow.isTemplate===1" class="banner purple">◆ 该流程由 {{ flow.bindings.length }} 个故障共用，修改将同步影响所有绑定故障</div>
          <div class="fm">
            <el-input v-model="flow.flowName" style="max-width:360px" @change="saveHeader" />
            <span class="tag" :class="flow.flowStatus==='PUBLISHED'?'ok':'muted'">{{ statusText }}</span>
            <el-button size="mini" @click="reload">校验</el-button>
            <el-button size="mini" type="primary" :disabled="flow.verStatus==='PUBLISHED'" @click="publish">{{ flow.verStatus==='PUBLISHED' ? ('已发布 v' + flow.pubVerNo) : ('发布为 v' + ((flow.pubVerNo || 0) + 1)) }}</el-button>
            <el-button size="mini" @click="addStep(null)">＋ 添加步骤</el-button>
            <el-button size="mini" @click="brick=!brick">▦ 积木池</el-button>
            <el-button size="mini" @click="asTemplate">存为通用模板</el-button>
            <el-button size="mini" @click="bindDlg=true">绑定 / 解绑故障</el-button>
            <el-button size="mini" type="text" @click="removeFlow">删除</el-button>
          </div>
          <div class="muted">默认窗口 T0 −
            <el-input-number v-model="flow.winPreSec" :min="0" :max="3600" size="mini" @change="saveHeader" />
            ～ T0 +
            <el-input-number v-model="flow.winPostSec" :min="0" :max="3600" size="mini" @change="saveHeader" />
            秒 · 运行信息 {{ flow.runInfoCols }}
          </div>
          <div class="muted">绑定故障：
            <span v-for="b in flow.bindings" :key="b.faultRuleId" class="tag">{{ b.cx }}/{{ b.gzdm }}
              <el-button type="text" @click="unbind(b)">×</el-button>
            </span>
          </div>
          <div v-if="!flow.errors.length && !flow.warnings.length" class="okbox">✓ 校验通过：每个分支都有出口、无死循环、参数适用车型匹配、包含结束节点</div>
          <details v-else class="valbox" :class="flow.errors.length ? 'err' : 'warn'" :open="flow.errors.length > 0">
            <summary>{{ flow.errors.length ? ('✕ ' + flow.errors.length + ' 个问题（发布前必须清零）') : '✓ 无阻断问题' }}<span v-if="flow.warnings.length"> ⚠ {{ flow.warnings.length }} 条提示</span></summary>
            <ul>
              <li v-for="(e,i) in flow.errors" :key="'e'+i" class="e">{{ e }}</li>
              <li v-for="(w,i) in flow.warnings" :key="'w'+i" class="w">{{ w }}</li>
            </ul>
          </details>
          <div v-for="(s,i) in flow.steps" :key="s.id" class="scard" :class="{on: step && step.id===s.id, over: dragOver===i}" @click="step=s"
               @dragover.prevent="dragOver=i" @drop.stop.prevent="onDrop(i)">
            <div class="row">
              <span class="handle" draggable="true" title="拖拽排序" @dragstart.stop="onDragStart(i, $event)" @dragend="dragFrom=null; dragOver=null">⋮⋮</span>
              <b>{{ circ(i) }}</b> <span class="tag">{{ typeLabel(s.stepType) }}</span> {{ s.stepTitle }}
            </div>
            <div class="muted">{{ (s.roleCodes||[]).join(' / ') }} · 卡 {{ (s.cards||[]).length }}
              · <span v-for="b in s.branches" :key="b.id">{{ b.branchLabel }} → {{ b.nextStepCode || '未配置' }} </span>
              <span v-if="s.stepType==='END'">■ {{ conclLabel(s.conclusion) }}</span>
            </div>
            <div>
              <el-button type="text" @click.stop="moveStep(i, -1)">上移</el-button>
              <el-button type="text" @click.stop="moveStep(i, 1)">下移</el-button>
              <el-button type="text" @click.stop="addStep(s.id)">＋插入</el-button>
              <el-button type="text" @click.stop="copyStep(s)">复制</el-button>
              <el-button type="text" @click.stop="delStep(s)">删除</el-button>
            </div>
          </div>
          <div v-if="!flow.steps.length && sel && sel.faultId && !sel.flowId" class="empty">
            <p>这条故障还没有处置流程。</p>
            <el-button type="primary" @click="createBlank">＋ 新建空白流程</el-button>
            <el-button @click="applyOpen=true">从模板 / 已有流程套用</el-button>
          </div>
        </section>
        <section v-else class="pane">
          <div v-if="sel && sel.fault && !sel.fault.flowId" class="empty">
            <p>{{ sel.fault.gzdm }} 未配置处置流程</p>
            <el-button type="primary" @click="createBlank">＋ 新建空白流程</el-button>
            <el-button @click="applyOpen=true">从模板 / 已有流程套用</el-button>
          </div>
          <div v-else class="muted" style="padding:20px">从左侧选择故障或模板</div>
        </section>
        <aside class="scroll pane">
          <el-tabs v-model="right">
            <el-tab-pane label="流程图" name="svg">
              <div class="row"><span class="muted">{{ legend }}</span><el-button size="mini" @click="flowBig=true">展开大图</el-button></div>
              <div class="flowbox" v-html="svg" @click="onSvg"></div>
            </el-tab-pane>
            <el-tab-pane label="司机 / 专家视角" name="view">
              <div v-if="!flow || !flow.steps.length" class="muted">流程无步骤</div>
              <template v-else-if="perspStep">
                <div class="simbanner view">视角预览：按流程配置渲染专家工作台与司机车载屏（无实时数据）
                  <el-button type="text" size="mini" @click="resetRun">重置</el-button>
                </div>
                <div class="runinfo">
                  <span v-for="k in runInfoItems" :key="k.code"><i>{{ k.name }}</i><b>—</b></span>
                </div>
                <div class="persp">
                  <div class="expert">
                    <div class="phead">专家工作台 · 处置单</div>
                    <div v-if="!run.done" class="curstep" :style="{ borderLeftColor: stepColor(perspStep.stepType) }">
                      <div class="row">
                        <span class="sno">{{ circ(stepIndex(perspStep)) }}</span>
                        <span class="tbadge" :class="'t-' + perspStep.stepType.toLowerCase()">{{ typeLabel(perspStep.stepType) }}</span>
                        <b>{{ perspStep.stepTitle }}</b>
                      </div>
                      <div class="row roles">
                        <span v-for="r in perspStep.roleCodes" :key="r" class="rchip" :class="'r-' + r">{{ roleLabel(r) }}</span>
                      </div>
                      <div v-if="perspStep.stepDesc" class="muted">{{ perspStep.stepDesc }}</div>
                      <div v-if="perspStep.safetyTip" class="safety">⚠ {{ perspStep.safetyTip }}</div>
                      <div v-if="perspStep.manualRef" class="muted">📖 {{ perspStep.manualRef }}</div>
                    </div>
                    <template v-if="!run.done">
                      <div v-for="c in perspStep.cards" :key="c.id" class="dcard">
                        <div v-if="c.cardKind==='FAULT'">关联故障 {{ c.relGzdm }}</div>
                        <div v-else>{{ c.paramName || c.paramCol }} <span class="mono">{{ c.paramCol }}</span></div>
                        <div class="muted">窗口 T0−{{ c.winPreSec }}s ～ T0+{{ c.winPostSec }}s · {{ c.statItems }}（上线后按故障时刻自动取数）</div>
                      </div>
                    </template>
                    <div class="actbox">
                      <div v-if="run.done && perspEnd && perspEnd.stepType==='END'" class="concbox" :style="conclStyle(perspEnd.conclusion)">
                        <div class="cb1">处置结论：{{ conclLabel(perspEnd.conclusion) }}</div>
                        <div>{{ perspEnd.stepTitle }}<template v-if="perspEnd.pushRepair"><br>⚑ 已标记回库，并向检修推送提示（模拟）</template></div>
                        <div class="muted">共 {{ runSteps }} 步 · 模拟用时约 {{ run.min }} 分钟</div>
                      </div>
                      <div v-else-if="run.done" class="concbox">流程中断：出口无效</div>
                      <template v-else-if="perspStep.stepType==='JUDGE'">
                        <div class="pjbox none">
                          <b>{{ hasDataCond(perspStep) ? '系统预判（运行时按数据卡自动判定）' : '人工判断' }}</b>
                          <div class="muted">{{ branchHint(perspStep) }}</div>
                        </div>
                        <el-button v-for="b in perspStep.branches" :key="b.id" size="mini" @click="runPick(b.branchLabel)">选择「{{ b.branchLabel }}」</el-button>
                      </template>
                      <template v-else-if="perspStep.stepType==='OP'">
                        <div class="cklist">
                          <div v-for="(c,k) in perspStep.confirms" :key="c.id" class="ckline">
                            <el-checkbox :value="isChecked(k)" @change="toggleCk(k, $event)" />
                            <span class="rchip" :class="'r-' + c.roleCode">{{ roleLabel(c.roleCode) }}</span>
                            {{ c.confirmText }}
                          </div>
                        </div>
                        <el-button v-for="b in perspStep.branches" :key="b.id" size="mini" :type="b.branchLabel==='成功' ? 'primary' : ''" @click="runPick(b.branchLabel)">专家代录：{{ b.branchLabel }}</el-button>
                      </template>
                      <el-button v-else type="primary" size="mini" @click="runPick(perspStep.branches[0] && perspStep.branches[0].branchLabel)">{{ perspStep.stepType==='CONTACT' ? '已联络，' : '已查看，' }}进入下一步 ›</el-button>
                    </div>
                  </div>
                  <div class="driver">
                    <div class="phead">司机端 · 车载屏</div>
                    <div class="screen">
                      <template v-if="run.done && perspEnd">
                        <div class="dmsg tag">处置结论</div>
                        <div class="dmsg concl">{{ conclLabel(perspEnd.conclusion) }}</div>
                        <div class="dmsg">{{ perspEnd.stepTitle }}</div>
                      </template>
                      <template v-else-if="driverOn">
                        <div class="dmsg tag">专家指令 · 步骤 {{ circ(stepIndex(perspStep)) }}</div>
                        <div class="dmsg big">{{ perspStep.driverAction || perspStep.stepTitle }}</div>
                        <div v-if="perspStep.safetyTip" class="dmsg warn">⚠ {{ perspStep.safetyTip }}</div>
                        <div class="dmsg">请按指令操作，完成后通话报告专家</div>
                      </template>
                      <template v-else>
                        <div class="dmsg tag">故障 {{ bindingCode }} 已报警</div>
                        <div class="dmsg big">待专家通话指导</div>
                        <div class="dmsg">地面专家正在{{ driverWait }}，请保持正常驾驶，注意瞭望</div>
                      </template>
                    </div>
                    <div class="muted">一期：专家通话指导并代录司机反馈；指令同步至车载屏</div>
                  </div>
                </div>
                <div class="runlog">
                  <div class="phead">处置时间线</div>
                  <div v-if="!run.log.length" class="muted">尚未开始</div>
                  <div v-for="(l,i) in run.log" :key="i" class="lg"><span class="lt">+{{ l.min }}′</span>{{ l.no }} {{ typeLabel(l.type) }} · {{ l.title }} → <b>{{ l.choice }}</b> <span class="muted">{{ l.by }}</span></div>
                </div>
              </template>
            </el-tab-pane>
            <el-tab-pane label="历史故障试跑" name="trial">
              <div class="banner">⚠ 模拟数据，非真实回放</div>
              <el-select v-model="eventId" placeholder="选择事件" style="width:100%" @change="loadEvent">
                <el-option v-for="e in events" :key="e.id" :label="e.eventTitle" :value="e.id" />
              </el-select>
              <div v-if="!events.length" class="muted">该故障暂无预置事件</div>
              <div v-if="event" class="muted">预期走向：{{ event.expectOutcome }} · {{ event.cc }} · {{ event.sd }} · {{ event.wz }}</div>
              <div v-if="step">
                <b>{{ step.stepTitle }}</b>
                <el-button size="mini" @click="evalStep">单步 ▸</el-button>
                <el-button size="mini" @click="autoRun">自动运行 ▸▸</el-button>
              </div>
              <div v-for="c in (evalResult && evalResult.cards) || []" :key="c.cardId" class="pcard">
                <div>{{ c.paramName || '关联故障' }} <span class="mono">{{ c.paramCol }}</span></div>
                <div v-if="c.none" class="muted">窗口内无数据</div>
                <div v-for="(v,k) in c.stats" :key="k">{{ k }}：{{ v }}</div>
                <div :id="'chart-'+c.cardId" style="height:120px"></div>
                <div v-for="h in c.hits" :key="h">{{ h }}</div>
              </div>
              <div v-if="evalResult && evalResult.prejudgeLabel" class="okbox">系统预判：{{ evalResult.prejudgeLabel }}<div>{{ evalResult.prejudgeReason }}</div></div>
              <el-input v-model="reason" placeholder="改判理由（改判时必填）" size="mini" />
              <div>
                <el-button v-for="b in (step && step.branches) || []" :key="b.id" size="mini" @click="choose(b)">
                  {{ evalResult && evalResult.prejudgeLabel===b.branchLabel ? '✓ 确认预判「'+b.branchLabel+'」' : '改判为「'+b.branchLabel+'」' }}
                </el-button>
              </div>
              <div v-for="(l,i) in log" :key="'t'+i">{{ l }}</div>
            </el-tab-pane>
          </el-tabs>
          <div v-if="brick" class="brick">
            <div class="row"><b>积木池</b> <span v-if="step">当前步骤：{{ step.stepTitle }}</span> <el-button type="text" @click="brick=false">×</el-button></div>
            <el-input v-model="brickQ" size="mini" placeholder="搜索参数" />
            <div v-for="p in brickParams" :key="p.id" class="row">
              <span>{{ p.paramName }} <span class="mono">{{ p.paramCol }}</span></span>
              <el-button type="text" @click="addParamCard(p)">加为数据卡</el-button>
            </div>
          </div>
        </aside>
      </div>
      <el-drawer :visible.sync="stepOpen" :title="step ? step.stepTitle : ''" size="420px" :append-to-body="true">
        <div v-if="step" style="padding:0 16px 24px">
          <el-form label-width="90px" size="small">
            <el-form-item label="步骤类型">
              <el-select v-model="step.stepType" @change="saveStep">
                <el-option v-for="t in types" :key="t.v" :label="t.l" :value="t.v" />
              </el-select>
            </el-form-item>
            <el-form-item label="标题"><el-input v-model="step.stepTitle" @change="saveStep" /></el-form-item>
            <el-form-item label="说明"><el-input type="textarea" v-model="step.stepDesc" @change="saveStep" /></el-form-item>
            <el-form-item label="角色">
              <el-checkbox-group v-model="step.roleCodes" @change="saveStep">
                <el-checkbox label="DRIVER">司机</el-checkbox>
                <el-checkbox label="EXPERT">专家</el-checkbox>
                <el-checkbox label="SYSTEM">系统</el-checkbox>
              </el-checkbox-group>
            </el-form-item>
            <el-form-item v-if="step.stepType==='END'" label="结束结论">
              <el-select v-model="step.conclusion" @change="saveStep">
                <el-option label="维持运行" value="MAINTAIN" />
                <el-option label="限速运行" value="SPEED_LIMIT" />
                <el-option label="请求救援" value="RESCUE" />
                <el-option label="回库处理" value="RETURN_DEPOT" />
              </el-select>
              <el-checkbox :true-label="1" :false-label="0" v-model="step.pushRepair" @change="saveStep">标记回库，并向检修推送提示</el-checkbox>
            </el-form-item>
            <el-form-item label="安全提示"><el-input v-model="step.safetyTip" @change="saveStep" /></el-form-item>
            <el-form-item label="手册条目"><el-input v-model="step.manualRef" @change="saveStep" /></el-form-item>
            <el-form-item label="司机动作"><el-input type="textarea" v-model="step.driverAction" @change="saveStep" /></el-form-item>
          </el-form>
          <h4>数据卡</h4>
          <el-button size="mini" @click="addCard('NUM')">＋ 数值窗口统计</el-button>
          <el-button size="mini" @click="addCard('STATE')">＋ 状态量取值</el-button>
          <el-button size="mini" @click="addCard('FAULT')">＋ 关联故障</el-button>
          <div v-for="c in step.cards" :key="c.id" class="pcard">
            <div>{{ c.cardCode }} {{ c.cardKind }} {{ c.paramName || c.relGzdm }}</div>
            <div v-if="c.unfitCx && c.unfitCx.length" class="bad">⚠ 不适用于 {{ c.unfitCx.join('、') }}</div>
            <el-select v-if="c.cardKind!=='FAULT'" v-model="c.paramCol" filterable size="mini" @change="saveCard(c)">
              <el-option v-for="p in params" :key="p.id" :label="p.paramName" :value="p.paramCol" />
            </el-select>
            <el-input v-else v-model="c.relGzdm" size="mini" @change="saveCard(c)" />
            <div>T0 − <el-input-number v-model="c.winPreSec" size="mini" @change="saveCard(c)" /> + <el-input-number v-model="c.winPostSec" size="mini" @change="saveCard(c)" /></div>
            <el-input v-model="c.statItems" size="mini" @change="saveCard(c)" />
            <el-button type="text" @click="delCard(c)">删除</el-button>
          </div>
          <h4>判断与分支</h4>
          <div v-if="step.stepType==='END'" class="muted">结束节点无出口。</div>
          <div v-for="(b,i) in step.branches" :key="i" class="pcard">
            <el-input v-model="b.branchLabel" size="mini" style="width:100px" />
            →
            <el-select v-model="b.nextStepId" size="mini" placeholder="选择出口" :class="{badsel:!b.nextStepId}">
              <el-option v-for="s in flow.steps" :key="s.id" :label="s.stepCode+' '+s.stepTitle" :value="s.id" />
            </el-select>
            <el-select v-model="b.condSrc" size="mini">
              <el-option label="人工判断" value="NONE" />
              <el-option label="引用数据卡" value="CARD" />
              <el-option label="复用原子" value="ATOM" />
              <el-option label="复用命名组" value="GROUP" />
              <el-option label="否则" value="ELSE" />
            </el-select>
            <template v-if="b.condSrc==='CARD'">
              <el-select v-model="b.condCardId" size="mini">
                <el-option v-for="c in step.cards" :key="c.id" :label="c.cardCode" :value="c.id" />
              </el-select>
              <el-input v-model="b.condStat" size="mini" placeholder="统计项" style="width:90px" />
              <el-input v-model="b.condOp" size="mini" style="width:60px" />
              <el-input v-model="b.condVal" size="mini" style="width:70px" />
            </template>
            <el-button type="text" @click="step.branches.splice(i,1)">删除</el-button>
          </div>
          <el-button size="mini" @click="step.branches.push({branchLabel:'', condSrc:'NONE', nextStepId:null})">＋ 自定义分支</el-button>
          <el-button size="mini" type="primary" @click="saveBranches">保存分支</el-button>
          <h4>确认项</h4>
          <div v-for="(c,i) in step.confirms" :key="'c'+i" class="row">
            <el-input v-model="c.confirmText" size="mini" />
            <el-select v-model="c.roleCode" size="mini" style="width:100px">
              <el-option label="司机" value="DRIVER" /><el-option label="专家" value="EXPERT" /><el-option label="系统" value="SYSTEM" />
            </el-select>
            <el-button type="text" @click="step.confirms.splice(i,1)">删除</el-button>
          </div>
          <el-button size="mini" @click="step.confirms.push({confirmText:'', roleCode:'DRIVER', isRequired:1})">＋ 添加确认项</el-button>
          <el-button size="mini" type="primary" @click="saveConfirms">保存确认项</el-button>
        </div>
      </el-drawer>
    </div>
    <el-dialog title="选择步骤类型" :visible.sync="typeDlg" width="480px" append-to-body>
      <el-button v-for="t in types" :key="t.v" style="display:block;width:100%;margin:6px 0" @click="doAdd(t.v)">{{ t.l }} · {{ t.h }}</el-button>
    </el-dialog>
    <el-dialog title="绑定 / 解绑故障" :visible.sync="bindDlg" width="520px" append-to-body>
      <el-checkbox-group v-model="bindIds">
        <div v-for="f in actionable" :key="f.id"><el-checkbox :label="f.id">{{ f.cx }} {{ f.gzdm }} {{ f.gzmc }}</el-checkbox></div>
      </el-checkbox-group>
      <span slot="footer"><el-button type="primary" @click="saveBind">保存绑定</el-button></span>
    </el-dialog>
    <big-canvas :visible="flowBig" :title="flow ? ('处置流程图 · ' + flow.flowName) : ''"
      :subtitle="flow ? (flow.bindings.length + ' 个绑定故障 · ' + flow.steps.length + ' 步 · ' + statusText) : ''"
      :svg="svg" :legend="legend" :file-base="flow ? ('处置流程_' + flow.flowName) : '处置流程'"
      :caption="flow ? flow.flowName : ''" hint="滚轮缩放 · 拖动平移 · 点击节点定位步骤 · Esc 关闭"
      @close="flowBig=false" @node="goStep" />
    <el-dialog title="套用流程" :visible.sync="applyOpen" width="560px" append-to-body>
      <div v-for="t in flows" :key="t.id" class="fcard">
        <div>{{ t.isTemplate===1 ? '◆ ' : '' }}{{ t.flowName }}</div>
        <el-button v-if="t.isTemplate===1" size="mini" @click="bindShared(t)">绑定共用</el-button>
        <el-button size="mini" @click="copyAs(t)">复制为专属</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import http from '../api/http'
import { flowSvg, FLOW_LEGEND } from '../utils/flowSvg'
import BigCanvas from './BigCanvas.vue'
import * as echarts from 'echarts'

var TYPES = [
  { v: 'VIEW', l: '查看', h: '查看数据与现场状态' },
  { v: 'JUDGE', l: '判断', h: '多分支，系统预判' },
  { v: 'OP', l: '操作', h: '司机执行，成功 / 未成功' },
  { v: 'CONTACT', l: '联络上报', h: '联络调度 / 检修' },
  { v: 'END', l: '结束', h: '给出处置结论' }
]
var CIRC = '①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳'

export default {
  name: 'FlowBoard',
  components: { BigCanvas: BigCanvas },
  data: function () {
    return {
      faults: [], flows: [], tab: 'fault', q: '', sel: null, flow: null, step: null,
      right: 'svg', brick: false, brickQ: '', params: [],
      typeDlg: false, afterId: null, bindDlg: false, bindIds: [], applyOpen: false,
      events: [], eventId: null, event: null, evalResult: null, reason: '', log: [],
      run: { fid: null, cur: null, checks: {}, log: [], path: [], done: false, min: 0 },
      types: TYPES, flowBig: false, dragFrom: null, dragOver: null, legend: FLOW_LEGEND
    }
  },
  computed: {
    actionable: function () {
      return this.faults.filter(function (f) { return f.czdj === 'CHECK' || f.czdj === 'WATCH' })
    },
    faultRows: function () {
      var q = (this.q || '').toLowerCase()
      return this.actionable.filter(function (f) {
        return !q || (f.gzdm + f.gzmc + (f.flowName || '')).toLowerCase().indexOf(q) >= 0
      })
    },
    templates: function () {
      return this.flows.filter(function (f) { return f.isTemplate === 1 })
    },
    statusText: function () {
      if (!this.flow) return ''
      if (this.flow.flowStatus === 'PUBLISHED') return '已发布 v' + this.flow.pubVerNo
      if (this.flow.pubVerNo > 0) return '草稿 · 基于 v' + this.flow.pubVerNo
      return '草稿 · 未发布'
    },
    svg: function () {
      return this.flow ? flowSvg(this.flow.steps, { hl: this.step && this.step.id }) : ''
    },
    stepOpen: {
      get: function () { return !!this.step },
      set: function (v) { if (!v) this.step = null }
    },
    brickParams: function () {
      var q = (this.brickQ || '').toLowerCase()
      return this.params.filter(function (p) {
        return !q || (p.paramName + p.paramCol).toLowerCase().indexOf(q) >= 0
      }).slice(0, 30)
    },
    perspStep: function () {
      if (!this.flow || !this.flow.steps || !this.flow.steps.length) return null
      var cur = this.run && this.run.cur
      var found = this.flow.steps.filter(function (s) { return s.id === cur })[0]
      return found || this.flow.steps[0]
    },
    perspEnd: function () {
      if (!this.run || !this.run.done || !this.flow) return null
      var id = this.run.path[this.run.path.length - 1]
      return this.flow.steps.filter(function (s) { return s.id === id })[0] || null
    },
    driverOn: function () {
      return this.perspStep && !this.run.done && (this.perspStep.roleCodes || []).indexOf('DRIVER') >= 0
    },
    driverWait: function () {
      var t = this.perspStep && this.perspStep.stepType
      if (t === 'CONTACT') return '联络调度 / 检修'
      if (t === 'JUDGE') return '研判数据'
      return '查看数据'
    },
    runSteps: function () {
      return (this.run.log || []).filter(function (x) { return x.type !== 'END' }).length
    },
    bindingCode: function () {
      var b = this.flow && this.flow.bindings && this.flow.bindings[0]
      return b ? b.gzdm : ''
    },
    runInfoItems: function () {
      var names = { CC: '车次', SD: '速度', WZ: '位置', JL: '交路', SJ: '司机', FSSJ: '发生时间' }
      return String((this.flow && this.flow.runInfoCols) || '').split(',').map(function (c) { return c.trim() }).filter(Boolean).map(function (c) {
        return { code: c, name: names[c] || c }
      })
    }
  },
  watch: {
    flow: function (f) {
      var id = f && f.id
      if (!this.run || this.run.fid !== id) this.resetRun()
    }
  },
  mounted: function () {
    this.refresh(true)
  },
  methods: {
    refresh: function (pick) {
      var self = this
      return Promise.all([
        http.get('/api/faults'),
        http.get('/api/flows'),
        http.get('/api/params', { params: { pageSize: 500 } })
      ]).then(function (all) {
        self.faults = all[0]
        self.flows = all[1]
        self.params = (all[2].records) || []
        if (pick) {
          var want = self.$store.state.flowFaultId
          var row = self.faults.filter(function (f) { return f.id === want })[0]
          if (!row) row = self.actionable.filter(function (f) { return f.flowId })[0] || self.actionable[0]
          if (row) self.selectFault(row)
        } else if (self.flow) {
          var cur = self.flows.filter(function (f) { return f.id === self.flow.id })[0]
          if (cur) self.flow = cur
        }
      }).catch(this.fail)
    },
    selectFault: function (f) {
      this.sel = { type: 'fault', faultId: f.id, fault: f, flowId: f.flowId }
      this.step = null
      this.log = []
      if (f.flowId) this.open(f.flowId)
      else { this.flow = null; this.events = [] }
      this.loadTrials(f.id)
    },
    selectFlow: function (t) {
      this.sel = { type: 'tpl', flowId: t.id }
      this.open(t.id)
    },
    open: function (id) {
      var self = this
      http.get('/api/flows/' + id).then(function (d) {
        self.flow = d
        self.bindIds = (d.bindings || []).map(function (b) { return b.faultRuleId })
        if (self.step) {
          var found = d.steps.filter(function (s) { return s.id === self.step.id })[0]
          self.step = found || d.steps[0] || null
        }
      }).catch(this.fail)
    },
    reload: function () { if (this.flow) this.open(this.flow.id) },
    saveHeader: function () {
      var self = this
      if (!this.flow) return
      http.put('/api/flows/' + this.flow.id, {
        rev: this.flow.rev, flowName: this.flow.flowName,
        winPreSec: this.flow.winPreSec, winPostSec: this.flow.winPostSec, runInfoCols: this.flow.runInfoCols
      }).then(function (d) { self.flow = d }).catch(this.fail)
    },
    publish: function () {
      var self = this
      this.$confirm('草稿可直接发布为 v' + ((this.flow.pubVerNo || 0) + 1) + '，影响绑定故障 ' + this.flow.bindings.length + ' 条。', '发布').then(function () {
        return http.post('/api/flows/' + self.flow.id + '/publish', { rev: self.flow.rev })
      }).then(function (d) {
        self.flow = d
        self.$message.success('已发布 v' + d.pubVerNo)
        return self.refresh(false)
      }).catch(this.fail)
    },
    removeFlow: function () {
      var self = this
      this.$confirm('删除后绑定的故障会变为未配置。', '删除流程').then(function () {
        return http.delete('/api/flows/' + self.flow.id, { data: { rev: self.flow.rev } })
      }).then(function () { self.flow = null; return self.refresh(true) }).catch(this.fail)
    },
    createBlank: function () {
      var self = this
      var faultId = this.sel && (this.sel.faultId || (this.sel.fault && this.sel.fault.id))
      http.post('/api/flows', { kind: 'fault', faultRuleId: faultId }).then(function (d) {
        self.flow = d
        return self.refresh(false)
      }).catch(this.fail)
    },
    createTpl: function () {
      var self = this
      http.post('/api/flows', { kind: 'template' }).then(function (d) {
        self.tab = 'tpl'
        self.flow = d
        return self.refresh(false)
      }).catch(this.fail)
    },
    addStep: function (after) { this.afterId = after; this.typeDlg = true },
    doAdd: function (type) {
      var self = this
      this.typeDlg = false
      http.post('/api/flows/' + this.flow.id + '/steps', { rev: this.flow.rev, stepType: type, afterStepId: this.afterId }).then(function (d) {
        self.flow = d
        self.step = d.steps[d.steps.length - 1]
      }).catch(this.fail)
    },
    moveStep: function (index, dir) {
      var self = this
      var ids = this.flow.steps.map(function (s) { return s.id })
      var j = index + dir
      if (j < 0 || j >= ids.length) return
      var tmp = ids[index]
      ids[index] = ids[j]
      ids[j] = tmp
      http.post('/api/flows/' + this.flow.id + '/steps/reorder', { rev: this.flow.rev, stepIds: ids }).then(function (d) {
        self.flow = d
      }).catch(this.fail)
    },
    copyStep: function (s) {
      var self = this
      http.post('/api/flows/' + this.flow.id + '/steps/' + s.id + '/copy', { rev: this.flow.rev }).then(function (d) { self.flow = d }).catch(this.fail)
    },
    delStep: function (s) {
      var self = this
      http.delete('/api/flows/' + this.flow.id + '/steps/' + s.id, { data: { rev: this.flow.rev } }).then(function (d) {
        self.flow = d
        if (self.step && self.step.id === s.id) self.step = null
      }).catch(this.fail)
    },
    saveStep: function () {
      var self = this
      var s = this.step
      http.put('/api/flows/' + this.flow.id + '/steps/' + s.id, {
        rev: this.flow.rev, stepType: s.stepType, stepTitle: s.stepTitle, stepDesc: s.stepDesc,
        roleCodes: s.roleCodes, safetyTip: s.safetyTip, manualRef: s.manualRef,
        driverAction: s.driverAction, conclusion: s.conclusion, pushRepair: s.pushRepair
      }).then(function (d) { self.afterWrite(d, s.id) }).catch(this.fail)
    },
    addCard: function (kind) {
      var self = this
      var param = this.params[0]
      http.post('/api/flows/' + this.flow.id + '/steps/' + this.step.id + '/cards', {
        rev: this.flow.rev, cardKind: kind,
        paramCol: kind === 'FAULT' ? null : (param && param.paramCol),
        relGzdm: kind === 'FAULT' ? (this.sel && this.sel.fault ? this.sel.fault.gzdm : '1914') : null
      }).then(function (d) { self.afterWrite(d, self.step.id) }).catch(this.fail)
    },
    saveCard: function (c) {
      var self = this
      http.put('/api/flows/' + this.flow.id + '/cards/' + c.id, {
        rev: this.flow.rev, cardKind: c.cardKind, paramCol: c.paramCol, relGzdm: c.relGzdm,
        winPreSec: c.winPreSec, winPostSec: c.winPostSec, statItems: c.statItems,
        showCurve: c.showCurve, limitOp: c.limitOp, limitVal: c.limitVal, targetVal: c.targetVal
      }).then(function (d) { self.afterWrite(d, self.step.id) }).catch(this.fail)
    },
    delCard: function (c) {
      var self = this
      http.delete('/api/flows/' + this.flow.id + '/cards/' + c.id, { data: { rev: this.flow.rev } }).then(function (d) {
        self.afterWrite(d, self.step.id)
      }).catch(this.fail)
    },
    addParamCard: function (p) {
      if (!this.step) { this.$message.warning('请先打开一个步骤'); return }
      var self = this
      var kind = p.dataType === 'NUMBER' ? 'NUM' : 'STATE'
      http.post('/api/flows/' + this.flow.id + '/steps/' + this.step.id + '/cards', {
        rev: this.flow.rev, cardKind: kind, paramCol: p.paramCol
      }).then(function (d) { self.afterWrite(d, self.step.id) }).catch(this.fail)
    },
    saveBranches: function () {
      var self = this
      http.put('/api/flows/' + this.flow.id + '/steps/' + this.step.id + '/branches', {
        rev: this.flow.rev, branches: this.step.branches
      }).then(function (d) { self.afterWrite(d, self.step.id); self.$message.success('分支已保存') }).catch(this.fail)
    },
    saveConfirms: function () {
      var self = this
      http.put('/api/flows/' + this.flow.id + '/steps/' + this.step.id + '/confirms', {
        rev: this.flow.rev, confirms: this.step.confirms
      }).then(function (d) { self.afterWrite(d, self.step.id) }).catch(this.fail)
    },
    afterWrite: function (d, stepId) {
      this.flow = d
      var found = d.steps.filter(function (s) { return s.id === stepId })[0]
      if (!found && d.steps.length) found = d.steps[d.steps.length - 1]
      this.step = found || null
    },
    saveBind: function () {
      var self = this
      http.post('/api/flows/' + this.flow.id + '/bindings', { rev: this.flow.rev, faultRuleIds: this.bindIds }).then(function (d) {
        self.flow = d
        self.bindDlg = false
        return self.refresh(false)
      }).catch(this.fail)
    },
    unbind: function (b) {
      var self = this
      http.post('/api/flows/' + this.flow.id + '/unbind', { rev: this.flow.rev, faultRuleId: b.faultRuleId }).then(function (d) {
        self.flow = d
        return self.refresh(false)
      }).catch(this.fail)
    },
    asTemplate: function () {
      var self = this
      var name = this.flow.flowName + ' 通用处置'
      http.post('/api/flows/' + this.flow.id + '/save-template', { rev: this.flow.rev, flowName: name, migrateBindings: false }).then(function () {
        self.$message.success('已另存为草稿模板')
        return self.refresh(false)
      }).catch(this.fail)
    },
    bindShared: function (t) {
      var self = this
      var faultId = this.sel.faultId
      var ids = (t.bindings || []).map(function (b) { return b.faultRuleId })
      if (ids.indexOf(faultId) < 0) ids.push(faultId)
      http.post('/api/flows/' + t.id + '/bindings', { rev: t.rev, faultRuleIds: ids }).then(function (d) {
        self.applyOpen = false
        self.flow = d
        return self.refresh(false)
      }).catch(this.fail)
    },
    copyAs: function (t) {
      var self = this
      http.post('/api/flows/' + t.id + '/copy', { faultRuleId: this.sel.faultId, rev: t.rev }).then(function (d) {
        self.applyOpen = false
        self.flow = d
        if (d.notices && d.notices.length) self.$message.warning(d.notices[0])
        return self.refresh(false)
      }).catch(this.fail)
    },
    loadTrials: function (faultId) {
      var self = this
      http.get('/api/trials', { params: { faultRuleId: faultId } }).then(function (rows) {
        self.events = rows
        self.eventId = rows[0] ? rows[0].id : null
        if (self.eventId) self.loadEvent()
      }).catch(this.fail)
    },
    loadEvent: function () {
      var self = this
      if (!this.eventId) return
      http.get('/api/trials/' + this.eventId).then(function (e) { self.event = e; self.log = []; self.evalResult = null }).catch(this.fail)
    },
    evalStep: function () {
      var self = this
      if (!this.step || !this.eventId) return Promise.resolve(null)
      return http.post('/api/trials/' + this.eventId + '/steps/' + this.step.id + '/evaluate').then(function (r) {
        self.evalResult = r
        self.$nextTick(function () { self.drawCharts() })
        return r
      }).catch(function (e) { self.fail(e); return null })
    },
    drawCharts: function () {
      var cards = (this.evalResult && this.evalResult.cards) || []
      cards.forEach(function (c) {
        if (!c.points || !c.points.length) return
        var el = document.getElementById('chart-' + c.cardId)
        if (!el) return
        var chart = echarts.init(el)
        chart.setOption({
          grid: { left: 30, right: 10, top: 16, bottom: 20 },
          xAxis: { type: 'value', name: 's' },
          yAxis: { type: 'value', scale: true },
          series: [{ type: 'line', showSymbol: false, data: c.points, markLine: { data: [{ xAxis: 0 }] } }]
        })
      })
    },
    /** 换流程时把视角走步器回到第一步。同一流程刷新不打断。 */
    resetRun: function () {
      var f = this.flow
      this.run = {
        fid: f ? f.id : null,
        cur: f && f.steps && f.steps[0] ? f.steps[0].id : null,
        checks: {}, log: [], path: [], done: false, min: 0
      }
    },
    stepIndex: function (s) {
      if (!this.flow || !s) return 0
      var i = -1
      this.flow.steps.forEach(function (x, n) { if (x.id === s.id) i = n })
      return i < 0 ? 0 : i
    },
    stepColor: function (t) {
      return { VIEW: '#0369a1', JUDGE: '#b45309', OP: '#15803d', CONTACT: '#be185d', END: '#334155' }[t] || '#334155'
    },
    roleLabel: function (r) {
      return { DRIVER: '司机', EXPERT: '专家', SYSTEM: '系统' }[r] || r
    },
    conclStyle: function (c) {
      var map = {
        MAINTAIN: ['#15803d', '#f0fdf4'],
        SPEED_LIMIT: ['#b45309', '#fffbeb'],
        RESCUE: ['#b91c1c', '#fef2f2'],
        RETURN_DEPOT: ['#1d4ed8', '#eff6ff']
      }
      var x = map[c] || ['#334155', '#f1f5f9']
      return { color: x[0], background: x[1], borderColor: x[0] }
    },
    isChecked: function (k) {
      var s = this.perspStep
      var arr = s && this.run.checks[s.id]
      return !!(arr && arr[k])
    },
    toggleCk: function (k, checked) {
      var s = this.perspStep
      if (!s) return
      var checks = Object.assign({}, this.run.checks)
      var arr = (checks[s.id] || []).slice()
      arr[k] = !!checked
      checks[s.id] = arr
      this.run = Object.assign({}, this.run, { checks: checks })
    },
    hasDataCond: function (s) {
      return (s.branches || []).some(function (b) { return b.condSrc && b.condSrc !== 'NONE' && b.condSrc !== 'ELSE' })
    },
    condText: function (s, b) {
      if (!b || !b.condSrc || b.condSrc === 'NONE') return '人工判断'
      if (b.condSrc === 'ELSE') return '否则'
      if (b.condSrc === 'CARD') {
        var card = (s.cards || []).filter(function (c) { return c.id === b.condCardId })[0]
        var name = card ? (card.cardKind === 'FAULT' ? ('关联故障 ' + (card.relGzdm || '')) : (card.paramName || card.paramCol)) : '数据卡'
        return name + ' ' + (b.condStat || '') + ' ' + (b.condOp || '') + ' ' + (b.condVal || '')
      }
      if (b.condSrc === 'ATOM') return b.condAtomCode || '原子条件'
      if (b.condSrc === 'GROUP') return '命名组「' + (b.condGroupCode || '') + '」'
      return b.condSrc
    },
    branchHint: function (s) {
      var self = this
      return (s.branches || []).map(function (b) { return b.branchLabel + '：' + self.condText(s, b) }).join('；')
    },
    /**
     * 视角走步。操作步骤选「成功」前，确认项必须全部勾选。
     */
    runPick: function (label) {
      var s = this.perspStep
      if (!s || this.run.done) return
      var by = '专家确认'
      if (s.stepType === 'JUDGE') by = '专家选择'
      if (s.stepType === 'OP') {
        var confirms = s.confirms || []
        var ck = this.run.checks[s.id] || []
        if (label === '成功') {
          for (var i = 0; i < confirms.length; i++) {
            if (!ck[i]) {
              this.$message.error('请先勾选全部确认项（专家代录司机反馈）')
              return
            }
          }
        }
        by = '专家代录司机反馈'
      }
      var sim = { VIEW: 1, JUDGE: 1, OP: 4, CONTACT: 3, END: 0 }
      var min = (this.run.min || 0) + (sim[s.stepType] == null ? 1 : sim[s.stepType])
      var log = this.run.log.concat([{ no: this.circ(this.stepIndex(s)), type: s.stepType, title: s.stepTitle, choice: label || '', by: by, min: min }])
      var path = this.run.path.concat([s.id])
      var branch = (s.branches || []).filter(function (b) { return b.branchLabel === label })[0]
      var next = branch && this.flow.steps.filter(function (x) { return x.id === branch.nextStepId })[0]
      if (!next) {
        this.run = Object.assign({}, this.run, { log: log, path: path, min: min, done: true })
        return
      }
      if (next.stepType === 'END') {
        log = log.concat([{ no: this.circ(this.stepIndex(next)), type: 'END', title: next.stepTitle, choice: this.conclLabel(next.conclusion), by: '结论', min: min }])
        path = path.concat([next.id])
        this.run = Object.assign({}, this.run, { cur: next.id, log: log, path: path, min: min, done: true })
        return
      }
      this.run = Object.assign({}, this.run, { cur: next.id, log: log, path: path, min: min, done: false })
    },
    choose: function (b) {
      if (!this.evalResult) { this.advance(b.branchLabel); return }
      var pre = this.evalResult.prejudgeLabel
      if (pre && pre !== b.branchLabel && !this.reason) {
        this.$message.error('改判须填写理由')
        return
      }
      var note = pre && pre !== b.branchLabel ? ('专家改判（预判「' + pre + '」）：' + this.reason) : ('确认「' + b.branchLabel + '」')
      this.advance(b.branchLabel, note)
      this.reason = ''
    },
    advance: function (label, note) {
      this.log.push((this.step ? this.step.stepTitle : '') + ' → ' + (note || label))
      var next = null
      var branches = this.step ? this.step.branches : []
      branches.forEach(function (b) { if (b.branchLabel === label) next = b.nextStepId })
      if (next && this.flow) {
        var found = this.flow.steps.filter(function (s) { return s.id === next })[0]
        this.step = found || this.step
        if (this.right === 'trial') this.evalStep()
      }
    },
    autoRun: function () {
      var self = this
      if (!this.step && this.flow && this.flow.steps.length) this.step = this.flow.steps[0]
      var guard = 0
      var tick = function () {
        if (!self.step || self.step.stepType === 'END' || guard++ > 20) return
        self.evalStep().then(function (r) {
          var recorded = self.event && self.event.answers ? self.event.answers[self.step.stepCode] : null
          var label = (r && r.prejudgeLabel) || recorded || (self.step.branches[0] && self.step.branches[0].branchLabel)
          if (!label) return
          self.advance(label, '自动 ' + label)
          tick()
        })
      }
      tick()
    },
    onSvg: function (e) {
      var g = e.target.closest && e.target.closest('[data-id]')
      if (!g) return
      this.goStep(g.getAttribute('data-id'))
    },
    goStep: function (id) {
      if (!this.flow) return
      var found = this.flow.steps.filter(function (s) { return String(s.id) === String(id) })[0]
      if (found) {
        this.step = found
        this.flowBig = false
      }
    },
    onDragStart: function (index, e) {
      this.dragFrom = index
      e.dataTransfer.effectAllowed = 'move'
      e.dataTransfer.setData('text/plain', String(index))
    },
    onDrop: function (index) {
      var from = this.dragFrom
      this.dragFrom = null
      this.dragOver = null
      if (from == null || from === index) return
      var ids = this.flow.steps.map(function (s) { return s.id })
      var moved = ids.splice(from, 1)[0]
      ids.splice(index, 0, moved)
      var self = this
      http.post('/api/flows/' + this.flow.id + '/steps/reorder', { rev: this.flow.rev, stepIds: ids }).then(function (d) {
        self.flow = d
      }).catch(this.fail)
    },
    esc: function () {
      if (this.brick) this.brick = false
      else if (this.step) this.step = null
      else this.$emit('close')
    },
    circ: function (i) { return CIRC[i] || (i + 1) },
    typeLabel: function (t) {
      var f = TYPES.filter(function (x) { return x.v === t })[0]
      return f ? f.l : t
    },
    conclLabel: function (c) {
      return { MAINTAIN: '维持运行', SPEED_LIMIT: '限速运行', RESCUE: '请求救援', RETURN_DEPOT: '回库处理' }[c] || c
    },
    fail: function (e) { if (e && e !== 'cancel' && e.message) this.$message.error(e.message) }
  }
}
</script>

<style scoped>
.mask { position:fixed; inset:0; background:rgba(15,23,42,.45); z-index:20; display:flex; }
.board { background:#f8fafc; margin:16px; flex:1; border-radius:12px; display:flex; flex-direction:column; min-width:0; }
.bhead { display:flex; justify-content:space-between; padding:10px 14px; background:#fff; border-bottom:1px solid var(--line); }
.bcols { flex:1; display:grid; grid-template-columns: 260px 1fr 340px; min-height:0; }
.bcols.wide { grid-template-columns: 220px minmax(240px,1fr) minmax(520px,640px); }
.pane { padding:10px; min-height:0; background:#fff; border-right:1px solid var(--line); }
.fcard, .pcard, .scard { border:1px solid var(--line); border-radius:8px; padding:8px; margin:6px 0; }
.fcard, .scard { cursor:pointer; }
.fcard.active, .scard.on { border-color:#2563eb; background:#eff6ff; }
.banner { background:#fffbeb; color:#b45309; padding:6px 8px; border-radius:6px; margin-bottom:6px; }
.banner.purple { background:#faf5ff; color:#6d28d9; }
.valbox { font-size:12px; border-radius:6px; padding:7px 10px; margin:8px 0; }
.valbox.err { background:#fef2f2; border:1px solid #fecaca; color:#b91c1c; }
.valbox.warn { background:#fffbeb; border:1px solid #fde68a; color:#a16207; }
.valbox summary { cursor:pointer; }
.valbox .e { color:#b91c1c; }
.valbox .w { color:#a16207; }
.handle { cursor:grab; color:#94a3b8; padding:0 6px; letter-spacing:-1px; user-select:none; }
.scard.over { box-shadow:inset 0 3px 0 #2563eb; }
.flowbox { overflow:auto; border:1px solid var(--line); border-radius:8px; background:#fff; }
.okbox { background:#f0fdf4; color:#15803d; padding:8px; border-radius:8px; }
.fm { display:flex; flex-wrap:wrap; gap:6px; align-items:center; }
.simbanner { background:#fff7ed; border:1px solid #fdba74; color:#9a3412; border-radius:5px; padding:5px 9px; font-size:12px; font-weight:600; margin-bottom:7px; display:flex; justify-content:space-between; align-items:center; }
.simbanner.view { background:#f0f9ff; border-color:#bae6fd; color:#0369a1; font-weight:500; }
.runinfo { display:flex; flex-wrap:wrap; gap:4px; background:#1e293b; color:#e2e8f0; border-radius:6px; padding:7px 9px; margin-bottom:8px; font-size:12px; }
.runinfo span { display:inline-flex; gap:5px; margin-right:10px; }
.runinfo i { font-style:normal; color:#94a3b8; }
.persp { display:grid; grid-template-columns:minmax(0,1fr) 205px; gap:9px; }
.phead { font-size:11px; font-weight:700; color:#64748b; letter-spacing:.5px; margin-bottom:6px; }
.expert { background:#fff; border:1px solid var(--line); border-radius:8px; padding:9px; }
.curstep { border-left:4px solid #334155; background:#f8fafc; border-radius:5px; padding:7px 9px; margin-bottom:7px; font-size:12px; }
.roles { justify-content:flex-start; gap:4px; margin-top:4px; }
.sno { display:inline-flex; width:20px; height:20px; border-radius:50%; background:#1e293b; color:#fff; font-size:12px; align-items:center; justify-content:center; flex:none; }
.tbadge { font-size:11px; line-height:17px; padding:0 6px; border-radius:4px; font-weight:700; color:#fff; flex:none; }
.t-view { background:#0369a1; } .t-judge { background:#b45309; } .t-op { background:#15803d; } .t-contact { background:#be185d; } .t-end { background:#334155; }
.rchip { display:inline-block; font-size:11px; line-height:16px; border-radius:3px; padding:0 5px; font-weight:600; color:#fff; }
.r-DRIVER { background:#2563eb; } .r-EXPERT { background:#7c3aed; } .r-SYSTEM { background:#0d9488; }
.safety { color:#b91c1c; background:#fef2f2; border-radius:4px; padding:3px 7px; margin:5px 0; font-size:12px; }
.dcard { border:1px solid var(--line); border-radius:6px; padding:6px 8px; margin:6px 0; font-size:12px; }
.actbox { border-top:1px dashed var(--line); padding-top:8px; margin-top:4px; }
.pjbox { border:1px solid #e2e8f0; background:#f8fafc; border-radius:6px; padding:6px 9px; margin-bottom:7px; font-size:12px; }
.cklist { display:flex; flex-direction:column; gap:4px; margin-bottom:7px; font-size:12px; }
.ckline { display:flex; gap:6px; align-items:flex-start; }
.concbox { border:1.5px solid; border-radius:8px; padding:9px 11px; font-size:12px; line-height:1.6; }
.cb1 { font-size:15px; font-weight:700; }
.driver .screen { background:#0b1220; border:6px solid #334155; border-radius:10px; min-height:230px; padding:12px 10px; color:#e2e8f0; display:flex; flex-direction:column; gap:8px; justify-content:center; text-align:center; }
.dmsg { font-size:12px; line-height:1.5; }
.dmsg.tag { color:#fbbf24; font-size:11px; }
.dmsg.big { font-size:16px; font-weight:700; color:#fff; }
.dmsg.warn { color:#fca5a5; }
.dmsg.concl { font-size:20px; font-weight:800; color:#86efac; }
.runlog { margin-top:9px; background:#fff; border:1px solid var(--line); border-radius:8px; padding:8px 10px; }
.lg { font-size:12px; padding:3px 0; border-bottom:1px dashed #f1f5f9; }
.lt { display:inline-block; width:36px; color:#94a3b8; font-family:monospace; }
.screen { margin-top:8px; background:#0f172a; color:#e2e8f0; padding:10px; border-radius:8px; }
.brick { border-top:1px solid var(--line); margin-top:8px; max-height:240px; overflow:auto; }
.row { display:flex; justify-content:space-between; gap:6px; align-items:center; }
.empty { padding:24px; }
</style>
