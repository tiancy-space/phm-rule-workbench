<template>
  <div class="mask" @keydown.esc="esc">
    <div class="board">
      <header class="bhead">
        <div>
          <b>处置流程管理</b>
          <div class="hint">粒度：车型＋来源＋故障代码 · 五类步骤（查看 / 判断 / 操作 / 联络上报 / 结束）· 司机 / 专家 / 系统协同</div>
        </div>
        <el-button type="text" @click="$emit('close')">× 关闭</el-button>
      </header>
      <div class="bcols" :class="{ wide: right === 'view' || right === 'trial' }">
        <aside class="scroll pane">
          <div class="seg">
            <button type="button" :class="{ active: tab === 'fault' }" @click="tab = 'fault'">故障 {{ actionable.length }}</button>
            <button type="button" :class="{ active: tab === 'tpl' }" @click="tab = 'tpl'">通用模板 {{ templates.length }}</button>
          </div>
          <div class="row" style="margin:6px 0">
            <select v-model="flowCx" class="mini">
              <option value="">全部车型</option>
              <option v-for="c in flowCxOptions" :key="c" :value="c">{{ c }}</option>
            </select>
            <select v-model="flowSt" class="mini">
              <option value="">全部状态</option>
              <option value="PUBLISHED">已发布</option>
              <option value="DRAFT">草稿</option>
              <option value="NONE">未配置</option>
            </select>
          </div>
          <input v-model="q" placeholder="⌕ 搜索故障代码 / 名称 / 模板" style="width:100%;margin:6px 0" />
          <template v-if="tab==='fault'">
            <div v-for="f in faultRows" :key="f.id" class="flitem" :class="{sel: sel && sel.type==='fault' && sel.faultId===f.id}" @click="selectFault(f)">
              <div class="between">
                <b class="flcode">{{ f.gzdm }}</b>
                <span class="row" style="gap:4px">
                  <span class="cztag" :class="'cz-'+(f.czdj||'').toLowerCase()">{{ f.czdj==='CHECK'?'排查':(f.czdj==='WATCH'?'关注':'无需干预') }}</span>
                  <span class="badge">{{ f.cx }}</span>
                  <span class="badge blue">{{ f.ly }}</span>
                </span>
              </div>
              <div class="flname">{{ f.gzmc }}</div>
              <div v-if="f.flowId"><span class="stpill" :class="f.flowStatus==='PUBLISHED'?'pub':'draft'">{{ f.flowStatus==='PUBLISHED' ? ('已发布 v'+f.pubVerNo) : '草稿' }} · {{ f.stepCount }} 步</span></div>
              <div v-else class="unset">○ 未配置处置流程</div>
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
          <div v-for="(s,i) in flow.steps" :key="s.id" class="scard" :class="{open: step && step.id===s.id, dropin: dragOver===i}"
               :style="{ '--tc': stepColor(s.stepType) }" @click="step=s"
               @dragover.prevent="dragOver=i" @drop.stop.prevent="onDrop(i)">
            <span class="sgrip" draggable="true" title="拖拽排序" @dragstart.stop="onDragStart(i, $event)" @dragend="dragFrom=null; dragOver=null">⋮⋮</span>
            <div class="sbody">
              <div class="srow1">
                <span class="sno">{{ circ(i) }}</span>
                <span class="tbadge" :class="'t-' + s.stepType.toLowerCase()">{{ typeLabel(s.stepType) }}</span>
                <b class="stt">{{ s.stepTitle }}</b>
              </div>
              <div class="srow2">
                <span v-for="r in s.roleCodes" :key="r" class="rchip" :class="roleClass(r)">{{ roleLabel(r) }}</span>
                <span class="cardcnt">卡 {{ (s.cards||[]).length }}</span>
                <span class="exits">
                  <span v-for="b in s.branches" :key="b.id" :class="{ missing: !b.nextStepId && s.stepType!=='END' }">{{ b.branchLabel }} → {{ b.nextStepCode || '未配置' }}</span>
                </span>
                <span v-if="s.stepType==='END'" class="concl">■ {{ conclLabel(s.conclusion) }}</span>
              </div>
            </div>
            <div class="sacts">
              <button type="button" class="link small" @click.stop="moveStep(i, -1)">上移</button>
              <button type="button" class="link small" @click.stop="moveStep(i, 1)">下移</button>
              <button type="button" class="link small" @click.stop="addStep(s.id)">＋插入</button>
              <button type="button" class="link small" @click.stop="copyStep(s)">复制</button>
              <button type="button" class="link small danger" @click.stop="delStep(s)">删除</button>
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
        <aside class="pane chartpane">
          <el-tabs v-model="right">
            <el-tab-pane label="流程图" name="svg">
              <div class="svgtab">
                <div class="between">
                  <div class="glegend">
                    <span><i class="lgs lg-view"></i>查看</span>
                    <span><i class="lgs lg-judge"></i>判断</span>
                    <span><i class="lgs lg-op"></i>操作</span>
                    <span><i class="lgs lg-contact"></i>联络上报</span>
                    <span><i class="lgs lg-end"></i>结束</span>
                    <span><i class="lgs lg-ref"></i>转至 · 已展开</span>
                  </div>
                  <span>
                    <el-button size="mini" @click="fitFlow">适应窗口</el-button>
                    <el-button size="mini" @click="flowBig=true">展开大图</el-button>
                  </span>
                </div>
                <div class="flowstage" ref="flowbox"
                     @wheel.prevent="onFlowWheel"
                     @pointerdown="onFlowDown"
                     @pointermove="onFlowMove"
                     @pointerup="onFlowUp"
                     @pointercancel="onFlowUp">
                  <div class="flowcanvas" :style="flowTransform" v-html="svg" @click="onSvg"></div>
                </div>
              </div>
            </el-tab-pane>
            <el-tab-pane label="司机 / 专家视角" name="view">
              <flow-runner v-if="flow" :flow="flow" :trial="false" :active="right==='view'" />
            </el-tab-pane>
            <el-tab-pane label="历史故障试跑" name="trial">
              <flow-runner v-if="flow" :flow="flow" :trial="true" :active="right==='trial'" :events="events" :event="event" @event="pickEvent" />
            </el-tab-pane>
          </el-tabs>
        </aside>
      </div>
      <el-drawer :visible.sync="stepOpen" :title="step ? step.stepTitle : ''" size="520px" :append-to-body="true">
        <div v-if="step" style="padding:0 16px 24px">
          <div class="row">
            <span class="sno">{{ circ(stepPos) }}</span>
            <span class="tbadge" :class="'t-' + step.stepType.toLowerCase()">{{ typeLabel(step.stepType) }}</span>
            <el-button type="text" :disabled="stepPos<=0" @click="goRel(-1)">‹ 上一步</el-button>
            <el-button type="text" :disabled="stepPos>=flow.steps.length-1" @click="goRel(1)">下一步 ›</el-button>
          </div>
          <el-tabs v-model="stepTab">
            <el-tab-pane label="基本信息" name="basic">
              <el-form label-width="90px" size="small">
                <el-form-item label="步骤类型">
                  <el-select v-model="step.stepType" @change="saveStep">
                    <el-option v-for="t in types" :key="t.v" :label="t.l" :value="t.v" />
                  </el-select>
                  <div class="muted">{{ typeHint }}</div>
                </el-form-item>
                <el-form-item label="标题"><el-input v-model="step.stepTitle" placeholder="判断类写成问题" @change="saveStep" /></el-form-item>
                <el-form-item label="说明"><el-input type="textarea" v-model="step.stepDesc" @change="saveStep" /></el-form-item>
                <el-form-item label="角色">
                  <el-checkbox-group v-model="step.roleCodes" @change="saveStep">
                    <el-checkbox label="DRIVER">司机 · 执行</el-checkbox>
                    <el-checkbox label="EXPERT">专家 · 确认 / 记录 / 改判</el-checkbox>
                    <el-checkbox label="SYSTEM">系统 · 预答</el-checkbox>
                  </el-checkbox-group>
                  <div class="muted">查看 / 联络 / 结束由专家处理；判断由系统预答、专家确认；操作由司机执行、专家代录。</div>
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
                <el-form-item label="安全提示"><el-input v-model="step.safetyTip" placeholder="如：下车作业前须确认停稳并做好防溜" @change="saveStep" /></el-form-item>
                <el-form-item label="手册条目"><el-input v-model="step.manualRef" placeholder="如：司机手册 · 制动系统 · 停放制动" @change="saveStep" /></el-form-item>
              </el-form>
            </el-tab-pane>
            <el-tab-pane :label="'数据卡 ' + (step.cards||[]).length" name="cards">
              <div class="note">以故障时刻 T0 为锚点取数。判断条件在「判断与分支」里配置，可以引用这里的统计结果。</div>
              <div v-for="c in step.cards" :key="c.id" class="pcard">
                <div class="row"><b>{{ c.cardCode }} · {{ cardKindLabel(c.cardKind) }}</b><el-button type="text" @click="delCard(c)">删除</el-button></div>
                <div v-if="c.unfitCx && c.unfitCx.length" class="bad">⚠ 不适用于 {{ c.unfitCx.join('、') }}</div>
                <el-select v-if="c.cardKind!=='FAULT'" v-model="c.paramCol" filterable size="mini" style="width:100%" @change="saveCard(c)">
                  <el-option v-for="p in params" :key="p.id" :label="p.paramName+' '+p.paramCol" :value="p.paramCol" />
                </el-select>
                <el-input v-else v-model="c.relGzdm" size="mini" placeholder="关联故障代码，逗号分隔" @change="saveCard(c)" />
                <div class="muted" v-if="paramOf(c)">{{ paramOf(c).unit || '无单位' }} · {{ paramOf(c).dataSource }}</div>
                <div>窗口 T0 − <el-input-number v-model="c.winPreSec" size="mini" :min="0" @change="saveCard(c)" /> ～ T0 + <el-input-number v-model="c.winPostSec" size="mini" :min="0" @change="saveCard(c)" /> 秒</div>
                <div class="statrow">
                  <el-checkbox v-for="st in statOptions(c)" :key="st" :value="hasStat(c, st)" @change="toggleStat(c, st, $event)">{{ st }}</el-checkbox>
                </div>
                <div v-if="c.cardKind==='NUM'" class="row">
                  越限
                  <el-select v-model="c.limitOp" size="mini" style="width:74px" @change="saveCard(c)">
                    <el-option v-for="o in limitOps" :key="o" :label="o" :value="o" />
                  </el-select>
                  <el-input v-model="c.limitVal" size="mini" style="width:80px" placeholder="阈值" @change="saveCard(c)" />
                  <el-checkbox :true-label="1" :false-label="0" v-model="c.showCurve" @change="saveCard(c)">显示小曲线</el-checkbox>
                </div>
                <div v-if="c.cardKind==='STATE' && enumOptions(c).length">
                  目标状态
                  <el-select v-model="c.targetVal" size="mini" @change="saveCard(c)">
                    <el-option v-for="e in enumOptions(c)" :key="e.value" :label="e.value+' : '+e.label" :value="e.value" />
                  </el-select>
                </div>
              </div>
              <el-button size="mini" @click="addCard('NUM')">＋ 数值窗口统计</el-button>
              <el-button size="mini" @click="addCard('STATE')">＋ 状态量取值</el-button>
              <el-button size="mini" @click="addCard('FAULT')">＋ 关联故障</el-button>
              <el-button size="mini" @click="openBrick('param')">▦ 从积木池选参数</el-button>
            </el-tab-pane>
            <el-tab-pane label="判断与分支" name="branch">
              <div v-if="step.stepType==='END'" class="note">结束节点无出口。结论在「基本信息」中设置：{{ conclLabel(step.conclusion) }}<template v-if="step.pushRepair">（回库并推送检修提示）</template></div>
              <div v-else-if="step.stepType==='VIEW' || step.stepType==='CONTACT'" class="note">{{ typeLabel(step.stepType) }}步骤：单一下一步。</div>
              <div v-else-if="step.stepType==='OP'" class="note">操作步骤：司机执行，专家记录 / 复核；按结果走「成功」或「未成功」。</div>
              <template v-else>
                <div class="note">系统按分支顺序判定，首个成立的即系统预判；都不成立走「否则」。专家可改判，须填写理由。条件可引用本步数据卡，也可复用原子或命名组。</div>
                <div class="row">
                  <span class="muted">分支预设：</span>
                  <el-button size="mini" @click="presetBranches(['是','否'])">是 / 否</el-button>
                  <el-button size="mini" @click="presetBranches(['正常','异常'])">正常 / 异常</el-button>
                </div>
              </template>
              <template v-if="step.stepType!=='END'">
              <div v-for="(b,i) in step.branches" :key="i" class="pcard">
                <div class="row">
                  <span class="sno">{{ i+1 }}</span>
                  <el-input v-if="step.stepType==='JUDGE'" v-model="b.branchLabel" size="mini" style="width:120px" />
                  <b v-else>{{ b.branchLabel }}</b>
                  <span>→</span>
                  <el-select v-model="b.nextStepId" size="mini" placeholder="选择出口" :class="{badsel:!b.nextStepId}">
                    <el-option v-for="s in flow.steps" :key="s.id" :label="s.stepCode+' '+s.stepTitle" :value="s.id" />
                  </el-select>
                  <el-button v-if="step.stepType==='JUDGE' && step.branches.length>2" type="text" @click="step.branches.splice(i,1)">删除</el-button>
                </div>
                <template v-if="step.stepType==='JUDGE'">
                  <el-select v-model="b.condSrc" size="mini" style="width:130px">
                    <el-option label="人工判断" value="NONE" />
                    <el-option label="引用数据卡" value="CARD" />
                    <el-option label="复用原子" value="ATOM" />
                    <el-option label="复用命名组" value="GROUP" />
                    <el-option label="否则" value="ELSE" />
                  </el-select>
                  <template v-if="b.condSrc==='CARD'">
                    <el-select v-model="b.condCardId" size="mini">
                      <el-option v-for="c in step.cards" :key="c.id" :label="(c.paramName||c.relGzdm||c.cardCode)" :value="c.id" />
                    </el-select>
                    <el-input v-model="b.condStat" size="mini" placeholder="统计项" style="width:90px" />
                    <el-input v-model="b.condOp" size="mini" style="width:60px" />
                    <el-input v-model="b.condVal" size="mini" style="width:70px" />
                  </template>
                  <el-select v-if="b.condSrc==='ATOM'" v-model="b.condAtomId" filterable size="mini" placeholder="选择原子">
                    <el-option v-for="a in atoms" :key="a.id" :label="a.atomCode+' '+a.atomName" :value="a.id" />
                  </el-select>
                  <el-select v-if="b.condSrc==='GROUP'" v-model="b.condGroupId" filterable size="mini" placeholder="选择命名组">
                    <el-option v-for="g in groups" :key="g.id" :label="g.groupCode+' '+g.groupName" :value="g.id" />
                  </el-select>
                </template>
              </div>
              </template>
              <div v-if="step.stepType==='JUDGE'">
                <el-button size="mini" @click="step.branches.push({branchLabel:'', condSrc:'NONE', nextStepId:null})">＋ 自定义分支</el-button>
              </div>
              <el-button v-if="step.stepType!=='END'" size="mini" type="primary" @click="saveBranches()">保存分支</el-button>
            </el-tab-pane>
            <el-tab-pane label="确认项" name="confirm">
              <el-form label-width="90px" size="small">
                <el-form-item label="司机动作">
                  <el-input type="textarea" :rows="2" v-model="step.driverAction" placeholder="车载屏显示；一期由专家通话指导并代录" @change="saveStep" />
                </el-form-item>
              </el-form>
              <div class="muted">确认项按执行角色定义。一期司机项由专家代录，选「成功」前必须全部勾选。</div>
              <div v-for="(c,i) in step.confirms" :key="'c'+i" class="row">
                <el-input v-model="c.confirmText" size="mini" />
                <el-select v-model="c.roleCode" size="mini" style="width:100px">
                  <el-option label="司机" value="DRIVER" /><el-option label="专家" value="EXPERT" /><el-option label="系统" value="SYSTEM" />
                </el-select>
                <el-button type="text" @click="step.confirms.splice(i,1)">删除</el-button>
              </div>
              <div v-if="!step.confirms.length" class="muted">暂无确认项</div>
              <el-button size="mini" @click="step.confirms.push({confirmText:'', roleCode:'DRIVER', isRequired:1})">＋ 添加确认项</el-button>
              <el-button size="mini" type="primary" @click="saveConfirms">保存确认项</el-button>
            </el-tab-pane>
          </el-tabs>
        </div>
      </el-drawer>
      <el-drawer :visible.sync="brick" title="积木池" size="420px" :append-to-body="true">
        <div style="padding:0 16px 16px">
          <el-radio-group v-model="brickTab" size="mini">
            <el-radio-button label="param">参数元数据</el-radio-button>
            <el-radio-button label="atom">原子规则</el-radio-button>
            <el-radio-button label="group">命名组</el-radio-button>
          </el-radio-group>
          <el-input v-model="brickQ" size="mini" placeholder="搜索" clearable style="margin:8px 0" />
          <div class="muted">{{ step ? ('当前步骤：' + circ(stepPos) + ' ' + step.stepTitle) : '打开某个步骤后可把积木加入该步骤' }}</div>
          <template v-if="brickTab==='param'">
            <div v-for="p in brickParams" :key="p.id" class="pcard">
              <div><b>{{ p.paramName }}</b> <span class="mono">{{ p.paramCol }}</span></div>
              <div class="muted">{{ p.dataType }} · {{ p.unit || '无单位' }} · {{ p.dataSource }}</div>
              <el-button v-if="step" size="mini" @click="addParamCard(p)">加为数据卡</el-button>
            </div>
          </template>
          <template v-else>
            <div v-for="a in brickRules" :key="a.kind+a.id" class="pcard">
              <div><b>{{ a.code }}</b> {{ a.name }}</div>
              <div class="muted">适用 {{ a.scope || 'ALL' }}</div>
              <el-button v-if="step && step.stepType==='JUDGE'" size="mini" @click="setBrickCond(a)">设为判断条件</el-button>
            </div>
          </template>
          <div v-if="brickTab!=='param' && !brickRules.length" class="muted">无匹配</div>
        </div>
      </el-drawer>
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
  </div>
</template>

<script>
import http from '../api/http'
import { flowSvg, FLOW_LEGEND, contentBox, fitTransform } from '../utils/flowSvg'
import BigCanvas from './BigCanvas.vue'
import FlowRunner from './FlowRunner.vue'

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
  components: { BigCanvas: BigCanvas, FlowRunner: FlowRunner },
  data: function () {
    return {
      faults: [], flows: [], tab: 'fault', q: '', flowCx: '', flowSt: '', sel: null, flow: null, step: null,
      right: 'svg', brick: false, brickTab: 'param', brickQ: '', params: [], atoms: [], groups: [],
      stepTab: 'basic',
      typeDlg: false, afterId: null, bindDlg: false, bindIds: [], applyOpen: false,
      events: [], eventId: null, event: null,
      types: TYPES, limitOps: ['<', '<=', '>', '>='], flowBig: false, dragFrom: null, dragOver: null, legend: FLOW_LEGEND,
      flowScale: 1, flowTx: 0, flowTy: 0, flowFit: true, flowDrag: null
    }
  },
  computed: {
    actionable: function () {
      return this.faults.filter(function (f) { return f.czdj === 'CHECK' || f.czdj === 'WATCH' })
    },
    flowCxOptions: function () {
      var s = {}
      this.actionable.forEach(function (f) { s[f.cx] = 1 })
      return Object.keys(s)
    },
    faultRows: function () {
      var q = (this.q || '').toLowerCase()
      var cx = this.flowCx
      var st = this.flowSt
      return this.actionable.filter(function (f) {
        if (cx && f.cx !== cx) return false
        if (st === 'NONE' && f.flowId) return false
        if (st === 'PUBLISHED' && f.flowStatus !== 'PUBLISHED') return false
        if (st === 'DRAFT' && !(f.flowId && f.flowStatus !== 'PUBLISHED')) return false
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
    flowTransform: function () {
      return { transform: 'translate(' + this.flowTx + 'px,' + this.flowTy + 'px) scale(' + this.flowScale + ')' }
    },
    stepOpen: {
      get: function () { return !!this.step },
      set: function (v) { if (!v) this.step = null }
    },
    brickParams: function () {
      var q = (this.brickQ || '').toLowerCase()
      return this.params.filter(function (p) {
        return !q || (p.paramName + p.paramCol).toLowerCase().indexOf(q) >= 0
      }).slice(0, 40)
    },
    brickRules: function () {
      var q = (this.brickQ || '').toLowerCase()
      var src = this.brickTab === 'group' ? this.groups : this.atoms
      var kind = this.brickTab === 'group' ? 'group' : 'atom'
      return src.filter(function (a) {
        var text = kind === 'group' ? (a.groupCode + a.groupName) : (a.atomCode + a.atomName + (a.atomExpr || ''))
        return !q || text.toLowerCase().indexOf(q) >= 0
      }).slice(0, 40).map(function (a) {
        return kind === 'group'
          ? { id: a.id, code: a.groupCode, name: a.groupName, scope: a.scopeCx, kind: 'group' }
          : { id: a.id, code: a.atomCode, name: a.atomName, scope: a.scopeCx, kind: 'atom' }
      })
    },
    stepPos: function () {
      if (!this.flow || !this.step) return -1
      var id = this.step.id
      var i = -1
      this.flow.steps.forEach(function (s, n) { if (s.id === id) i = n })
      return i
    },
    typeHint: function () {
      var type = this.step && this.step.stepType
      var t = TYPES.filter(function (x) { return x.v === type })[0]
      return t ? t.h : ''
    }
  },
  watch: {
    svg: function () { if (this.flowFit && this.right === 'svg') this.$nextTick(this.fitFlow) },
    right: function (v) { if (v === 'svg') this.$nextTick(this.fitFlow) }
  },
  mounted: function () {
    this.refresh(true)
    var self = this
    this._fitResize = function () { if (self.flowFit && self.right === 'svg') self.fitFlow() }
    window.addEventListener('resize', this._fitResize)
  },
  beforeDestroy: function () {
    window.removeEventListener('resize', this._fitResize)
  },
  methods: {
    refresh: function (pick) {
      var self = this
      return Promise.all([
        http.get('/api/faults'),
        http.get('/api/flows'),
        http.get('/api/params', { params: { pageSize: 500 } }),
        http.get('/api/atoms'),
        http.get('/api/groups')
      ]).then(function (all) {
        self.faults = all[0]
        self.flows = all[1]
        self.params = (all[2].records) || []
        self.atoms = all[3] || []
        self.groups = all[4] || []
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
      this.stepTab = 'cards'
      http.post('/api/flows/' + this.flow.id + '/steps/' + this.step.id + '/cards', {
        rev: this.flow.rev, cardKind: kind, paramCol: p.paramCol
      }).then(function (d) {
        self.afterWrite(d, self.step.id)
        self.$message.success('已将「' + p.paramName + '」加为数据卡')
      }).catch(this.fail)
    },
    saveBranches: function (quiet) {
      var self = this
      var stepId = this.step.id
      return http.put('/api/flows/' + this.flow.id + '/steps/' + stepId + '/branches', {
        rev: this.flow.rev, branches: this.step.branches
      }).then(function (d) {
        self.afterWrite(d, stepId)
        if (!quiet) self.$message.success('分支已保存')
        return d
      }).catch(this.fail)
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
    pickEvent: function (id) {
      this.eventId = id
      this.loadEvent()
    },
    loadEvent: function () {
      var self = this
      if (!this.eventId) { this.event = null; return }
      http.get('/api/trials/' + this.eventId).then(function (e) { self.event = e }).catch(this.fail)
    },
    /** 侧栏流程图：按内容包围盒适应容器，留边，不放大超过 1。 */
    fitFlow: function () {
      var st = this.$refs.flowbox
      if (!st || this.right !== 'svg') return
      var svg = st.querySelector('svg')
      if (!svg) return
      if (st.clientWidth < 8 || st.clientHeight < 8) {
        var self = this
        if (!this._fitRetry) {
          this._fitRetry = true
          requestAnimationFrame(function () { self._fitRetry = false; if (self.flowFit) self.fitFlow() })
        }
        return
      }
      var t = fitTransform(contentBox(svg), { width: st.clientWidth, height: st.clientHeight }, 12)
      this.flowScale = t.scale
      this.flowTx = t.tx
      this.flowTy = t.ty
      this.flowFit = true
    },
    onFlowWheel: function (e) {
      var st = this.$refs.flowbox
      if (!st) return
      var r = st.getBoundingClientRect()
      var cx = e.clientX - r.left
      var cy = e.clientY - r.top
      var ns = Math.max(0.15, Math.min(4, this.flowScale * (e.deltaY < 0 ? 1.12 : 1 / 1.12)))
      var k = ns / (this.flowScale || 1)
      this.flowTx = cx - (cx - this.flowTx) * k
      this.flowTy = cy - (cy - this.flowTy) * k
      this.flowScale = ns
      this.flowFit = false
    },
    onFlowDown: function (e) {
      if (e.button !== 0) return
      if (e.target.closest && e.target.closest('[data-id]')) return
      this.flowDrag = { x: e.clientX, y: e.clientY, tx: this.flowTx, ty: this.flowTy }
      if (e.currentTarget.setPointerCapture) e.currentTarget.setPointerCapture(e.pointerId)
    },
    onFlowMove: function (e) {
      if (!this.flowDrag) return
      this.flowTx = this.flowDrag.tx + e.clientX - this.flowDrag.x
      this.flowTy = this.flowDrag.ty + e.clientY - this.flowDrag.y
      this.flowFit = false
    },
    onFlowUp: function () { this.flowDrag = null },
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
    stepColor: function (t) {
      return { VIEW: '#0369a1', JUDGE: '#b45309', OP: '#15803d', CONTACT: '#be185d', END: '#334155' }[t] || '#334155'
    },
    roleLabel: function (r) { return { DRIVER: '司机', EXPERT: '专家', SYSTEM: '系统' }[r] || r },
    roleClass: function (r) { return { DRIVER: 'r-driver', EXPERT: 'r-expert', SYSTEM: 'r-system' }[r] || '' },
    typeLabel: function (t) {
      var f = TYPES.filter(function (x) { return x.v === t })[0]
      return f ? f.l : t
    },
    conclLabel: function (c) {
      return { MAINTAIN: '维持运行', SPEED_LIMIT: '限速运行', RESCUE: '请求救援', RETURN_DEPOT: '回库处理' }[c] || c
    },
    goRel: function (dir) {
      var i = this.stepPos + dir
      if (!this.flow || i < 0 || i >= this.flow.steps.length) return
      this.step = this.flow.steps[i]
    },
    openBrick: function (tab) {
      this.brickTab = tab || 'param'
      this.brick = true
    },
    cardKindLabel: function (k) {
      return { NUM: '数值窗口', STATE: '状态量', FAULT: '关联故障' }[k] || k
    },
    paramOf: function (c) {
      if (!c || !c.paramCol) return null
      return this.params.filter(function (p) { return p.paramCol === c.paramCol })[0] || null
    },
    statOptions: function (c) {
      return {
        NUM: ['T0值', '最大', '最小', '平均', '首值', '末值', '变化量', '越限时长'],
        STATE: ['T0值', '变位次数', '占用时长', '是否出现过'],
        FAULT: ['出现次数', 'T0后再次出现']
      }[c.cardKind] || []
    },
    hasStat: function (c, st) {
      return String(c.statItems || '').split(',').map(function (s) { return s.trim() }).indexOf(st) >= 0
    },
    toggleStat: function (c, st, on) {
      var arr = String(c.statItems || '').split(',').map(function (s) { return s.trim() }).filter(Boolean)
      var i = arr.indexOf(st)
      if (on && i < 0) arr.push(st)
      if (!on && i >= 0) arr.splice(i, 1)
      c.statItems = arr.join(',')
      this.saveCard(c)
    },
    enumOptions: function (c) {
      var out = []
      String((c && c.enumDict) || '').split(';').forEach(function (part) {
        var i = part.indexOf(':')
        if (i > 0) out.push({ value: part.slice(0, i).trim(), label: part.slice(i + 1).trim() })
      })
      return out
    },
    /** 判断步骤的是/否、正常/异常预设，保留已有出口。 */
    presetBranches: function (labels) {
      var old = this.step.branches || []
      this.step.branches = labels.map(function (label, i) {
        var prev = old[i] || {}
        return {
          branchLabel: label,
          nextStepId: prev.nextStepId || null,
          condSrc: prev.condSrc || 'NONE',
          condCardId: prev.condCardId || null,
          condStat: prev.condStat || '',
          condOp: prev.condOp || '',
          condVal: prev.condVal || '',
          condAtomId: prev.condAtomId || null,
          condGroupId: prev.condGroupId || null
        }
      })
    },
    /**
     * 把原子或命名组写到判断步骤的第一个人工分支，其余没有「否则」时补一条。
     */
    setBrickCond: function (a) {
      if (!this.step || this.step.stepType !== 'JUDGE') {
        this.$message.warning('请先打开一个判断步骤')
        return
      }
      var list = this.step.branches || []
      var b = null
      for (var i = 0; i < list.length; i++) {
        if (!list[i].condSrc || list[i].condSrc === 'NONE') { b = list[i]; break }
      }
      if (!b) b = list[0]
      if (!b) { this.$message.warning('该步骤没有分支'); return }
      b.condSrc = a.kind === 'atom' ? 'ATOM' : 'GROUP'
      if (a.kind === 'atom') { b.condAtomId = a.id; b.condGroupId = null }
      else { b.condGroupId = a.id; b.condAtomId = null }
      var hasElse = list.some(function (x) { return x !== b && x.condSrc === 'ELSE' })
      if (!hasElse) {
        for (var j = 0; j < list.length; j++) {
          if (list[j] !== b) {
            list[j].condSrc = 'ELSE'
            list[j].condCardId = null
            list[j].condAtomId = null
            list[j].condGroupId = null
            break
          }
        }
      }
      this.stepTab = 'branch'
      this.brick = false
      var label = b.branchLabel
      var self = this
      this.saveBranches(true).then(function (d) {
        if (d) self.$message.success('已设为「' + label + '」分支的判断条件')
      })
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
.chartpane { display:flex; flex-direction:column; overflow:hidden; }
.chartpane >>> .el-tabs { flex:1; min-height:0; display:flex; flex-direction:column; }
.chartpane >>> .el-tabs__content { flex:1; min-height:0; overflow:auto; }
.chartpane >>> .el-tab-pane { height:100%; }
.svgtab { height:100%; display:flex; flex-direction:column; min-height:0; }
.flowstage { flex:1; min-height:180px; overflow:hidden; position:relative; border:1px solid var(--line); border-radius:8px; background:#fff; touch-action:none; cursor:grab; }
.flowcanvas { position:absolute; left:0; top:0; transform-origin:0 0; }
.glegend { font-size: 11px; color: #64748b; }
select.mini { font-size: 12px; padding: 4px 6px; max-width: 120px; }
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
.note { background:#f8fafc; border-radius:6px; padding:6px 8px; margin:6px 0; color:#475569; font-size:12px; }
.statrow { display:flex; flex-wrap:wrap; gap:4px 10px; margin:6px 0; }
.bad { color:#b91c1c; }
.row { display:flex; justify-content:space-between; gap:6px; align-items:center; }
.empty { padding:24px; }
</style>
