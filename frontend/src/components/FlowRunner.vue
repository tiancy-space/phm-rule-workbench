<template>
  <div>
    <div v-if="!flow || !flow.steps.length" class="muted">流程无步骤</div>
    <div v-else-if="trial && !events.length" class="muted" style="margin-top:24px">
      当前流程绑定的故障暂无预置模拟事件。<br>试跑预置了 1914（正常消除 / 需要升级）与 1873（需要升级），请切换到对应故障。
    </div>
    <template v-else-if="cur">
      <div v-if="trial" class="trialbar">
        <el-select :value="event && event.id" placeholder="选择事件" size="mini" style="flex:1" @change="$emit('event', $event)">
          <el-option v-for="e in events" :key="e.id" :label="e.eventTitle" :value="e.id" />
        </el-select>
        <el-button size="mini" :disabled="run.done" @click="stepOnce">单步 ▸</el-button>
        <el-button size="mini" type="primary" :disabled="run.done" @click="autoRun">自动运行 ▸▸</el-button>
        <el-button size="mini" @click="resetRun">重置</el-button>
      </div>
      <div v-if="trial && event" class="simbanner">⚠ 模拟数据，非真实回放 · 预期走向：{{ event.expectOutcome }} · 专家可随时改判</div>
      <div v-else class="simbanner view">视角预览：按流程配置渲染专家工作台与司机车载屏（无实时数据）
        <el-button type="text" size="mini" @click="resetRun">重置</el-button>
      </div>
      <div class="runinfo">
        <span v-for="k in runInfoItems" :key="k.code"><i>{{ k.name }}</i><b>{{ k.value }}</b></span>
      </div>
      <div class="persp">
        <div class="expert">
          <div class="phead">专家工作台 · 处置单</div>
          <div v-if="!run.done" class="curstep" :style="{ borderLeftColor: stepColor(cur.stepType) }">
            <div class="row">
              <span class="sno">{{ circ(stepIndex(cur)) }}</span>
              <span class="tbadge" :class="'t-' + cur.stepType.toLowerCase()">{{ typeLabel(cur.stepType) }}</span>
              <b>{{ cur.stepTitle }}</b>
            </div>
            <div class="row roles">
              <span v-for="r in cur.roleCodes" :key="r" class="rchip" :class="'r-' + r">{{ roleLabel(r) }}</span>
            </div>
            <div v-if="cur.stepDesc" class="muted">{{ cur.stepDesc }}</div>
            <div v-if="cur.safetyTip" class="safety">⚠ {{ cur.safetyTip }}</div>
            <div v-if="cur.manualRef" class="muted">📖 {{ cur.manualRef }}</div>
          </div>
          <template v-if="!run.done">
            <div v-for="c in displayCards" :key="c.key" class="dcard">
              <div>{{ c.title }}</div>
              <div v-if="c.hint" class="muted">{{ c.hint }}</div>
              <div v-for="(v, k) in c.stats" :key="k">{{ k }}：{{ v }}</div>
              <div v-if="c.cardId && c.points && c.points.length" :id="chartId(c.cardId)" class="chart"></div>
              <div v-if="c.changes && c.changes.length" class="muted">变位：{{ c.changes.join('；') }}</div>
              <div v-for="h in c.hits" :key="h">{{ h }}</div>
            </div>
          </template>
          <div class="actbox">
            <div v-if="run.done && endStep && endStep.stepType==='END'" class="concbox" :style="conclStyle(endStep.conclusion)">
              <div class="cb1">处置结论：{{ conclLabel(endStep.conclusion) }}</div>
              <div>{{ endStep.stepTitle }}<template v-if="endStep.pushRepair"><br>⚑ 已标记回库，并向检修推送提示（模拟）</template></div>
              <div class="muted">共 {{ runSteps }} 步 · 模拟用时约 {{ run.min }} 分钟</div>
            </div>
            <div v-else-if="run.done" class="concbox">流程中断：出口无效</div>
            <template v-else-if="cur.stepType==='JUDGE'">
              <div class="pjbox" :class="preLabel ? 'hit' : 'none'">
                <b>{{ judgeTitle }}</b>
                <div class="muted">{{ judgeReason }}</div>
              </div>
              <el-button v-for="b in cur.branches" :key="b.id" size="mini" :type="preLabel && preLabel===b.branchLabel ? 'primary' : ''" @click="runPick(b.branchLabel)">{{ judgeBtn(b) }}</el-button>
              <el-input v-if="trial && preLabel" v-model="reason" size="mini" placeholder="改判理由（改判时必填）" style="margin-top:6px" />
            </template>
            <template v-else-if="cur.stepType==='OP'">
              <div class="cklist">
                <div v-for="(c, k) in cur.confirms" :key="c.id" class="ckline">
                  <el-checkbox :value="isChecked(k)" @change="toggleCk(k, $event)" />
                  <span class="rchip" :class="'r-' + c.roleCode">{{ roleLabel(c.roleCode) }}</span>
                  {{ c.confirmText }}
                </div>
              </div>
              <el-button v-for="b in cur.branches" :key="b.id" size="mini" :type="b.branchLabel==='成功' ? 'primary' : ''" @click="runPick(b.branchLabel)">专家代录：{{ b.branchLabel }}</el-button>
            </template>
            <el-button v-else type="primary" size="mini" @click="runPick(cur.branches[0] && cur.branches[0].branchLabel)">{{ cur.stepType==='CONTACT' ? '已联络，' : '已查看，' }}进入下一步 ›</el-button>
          </div>
        </div>
        <div class="driver">
          <div class="phead">司机端 · 车载屏</div>
          <div class="screen">
            <template v-if="run.done && endStep">
              <div class="dmsg tag">处置结论</div>
              <div class="dmsg concl">{{ conclLabel(endStep.conclusion) }}</div>
              <div class="dmsg">{{ endStep.stepTitle }}</div>
            </template>
            <template v-else-if="driverOn">
              <div class="dmsg tag">专家指令 · 步骤 {{ circ(stepIndex(cur)) }}</div>
              <div class="dmsg big">{{ cur.driverAction || cur.stepTitle }}</div>
              <div v-if="cur.safetyTip" class="dmsg warn">⚠ {{ cur.safetyTip }}</div>
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
        <div v-for="(l, i) in run.log" :key="i" class="lg"><span class="lt">+{{ l.min }}′</span>{{ l.no }} {{ typeLabel(l.type) }} · {{ l.title }} → <b>{{ l.choice }}</b> <span class="muted">{{ l.by }}</span></div>
      </div>
    </template>
  </div>
</template>

<script>
import http from '../api/http'
import * as echarts from 'echarts'

var CIRC = '①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳'
var TYPES = { VIEW: '查看', JUDGE: '判断', OP: '操作', CONTACT: '联络上报', END: '结束' }
var SIMMIN = { VIEW: 1, JUDGE: 1, OP: 4, CONTACT: 3, END: 0 }

/**
 * 视角预览和历史试跑共用的左右分屏走步器。
 * trial 为真时按模拟事件取数、画曲线并给出系统预判；操作步骤选「成功」前必须勾完确认项。
 */
export default {
  name: 'FlowRunner',
  props: {
    flow: { type: Object, default: null },
    trial: { type: Boolean, default: false },
    events: { type: Array, default: function () { return [] } },
    event: { type: Object, default: null },
    active: { type: Boolean, default: true }
  },
  data: function () {
    return {
      run: { fid: null, cur: null, checks: {}, log: [], path: [], done: false, min: 0 },
      evalResult: null,
      reason: '',
      ticking: false
    }
  },
  computed: {
    cur: function () {
      if (!this.flow || !this.flow.steps || !this.flow.steps.length) return null
      var id = this.run && this.run.cur
      var found = this.flow.steps.filter(function (s) { return s.id === id })[0]
      return found || this.flow.steps[0]
    },
    endStep: function () {
      if (!this.run || !this.run.done || !this.flow) return null
      var id = this.run.path[this.run.path.length - 1]
      return this.flow.steps.filter(function (s) { return s.id === id })[0] || null
    },
    driverOn: function () {
      return this.cur && !this.run.done && (this.cur.roleCodes || []).indexOf('DRIVER') >= 0
    },
    driverWait: function () {
      var t = this.cur && this.cur.stepType
      if (t === 'CONTACT') return '联络调度 / 检修'
      if (t === 'JUDGE') return '研判数据'
      return '查看数据'
    },
    bindingCode: function () {
      if (this.event && this.event.gzdm) return this.event.gzdm
      var b = this.flow && this.flow.bindings && this.flow.bindings[0]
      return b ? b.gzdm : ''
    },
    runSteps: function () {
      return (this.run.log || []).filter(function (x) { return x.type !== 'END' }).length
    },
    preLabel: function () {
      return this.trial && this.evalResult && this.evalResult.stepId === (this.cur && this.cur.id) ? this.evalResult.prejudgeLabel : ''
    },
    judgeTitle: function () {
      if (this.trial && this.preLabel) return '系统预判：' + this.preLabel
      if (this.trial && this.evalResult && this.hasDataCond(this.cur)) return '系统预判：无法判定'
      if (this.hasDataCond(this.cur)) return this.trial ? '系统预判' : '系统预判（运行时按数据卡自动判定）'
      return '人工判断'
    },
    judgeReason: function () {
      if (this.trial && this.evalResult && this.evalResult.stepId === (this.cur && this.cur.id) && this.evalResult.prejudgeReason) {
        return this.evalResult.prejudgeReason
      }
      return this.branchHint(this.cur)
    },
    runInfoItems: function () {
      var names = { CC: '车次', SD: '速度', WZ: '位置', JL: '交路', SJ: '司机', FSSJ: '发生时间' }
      var ev = this.trial ? this.event : null
      var vals = ev ? { CC: ev.cc, SD: ev.sd, WZ: ev.wz, JL: ev.jl, SJ: ev.sjxm, FSSJ: ev.fssj } : {}
      return String((this.flow && this.flow.runInfoCols) || '').split(',').map(function (c) { return c.trim() }).filter(Boolean).map(function (c) {
        return { code: c, name: names[c] || c, value: ev ? (vals[c] || '—') : '—' }
      })
    },
    displayCards: function () {
      var s = this.cur
      if (!s) return []
      if (!this.trial) {
        return (s.cards || []).map(function (c) {
          var title = c.cardKind === 'FAULT' ? ('关联故障 ' + (c.relGzdm || '')) : ((c.paramName || c.paramCol || '') + (c.paramCol ? ' ' + c.paramCol : ''))
          return {
            key: c.id, title: title, cardId: null, points: null, stats: null, changes: [], hits: [],
            hint: '窗口 T0−' + c.winPreSec + 's ～ T0+' + c.winPostSec + 's · ' + (c.statItems || '') + '（上线后按故障时刻自动取数）'
          }
        })
      }
      var same = this.evalResult && this.evalResult.stepId === s.id
      var rows = same ? (this.evalResult.cards || []) : []
      if (!rows.length) {
        return (s.cards || []).map(function (c) {
          return { key: c.id, title: c.paramName || c.relGzdm || c.cardCode, hint: '正在按模拟事件取数', stats: null, points: null, changes: [], hits: [], cardId: null }
        })
      }
      return rows.map(function (c) {
        var title = c.cardKind === 'FAULT' ? '关联故障' : ((c.paramName || '参数') + (c.paramCol ? ' ' + c.paramCol : ''))
        return {
          key: c.cardId, title: title, cardId: c.cardId, points: c.points || [], stats: c.stats, changes: c.changes || [], hits: c.hits || [],
          hint: c.none ? '该模拟事件无此参数数据' : ''
        }
      })
    }
  },
  watch: {
    'flow.id': function () { this.resetRun() },
    'event.id': function () { this.resetRun() },
    'run.cur': function () { if (this.trial && !this.run.done) this.evaluate() },
    active: function (v) { if (v) this.$nextTick(this.drawCharts) }
  },
  mounted: function () {
    if (!this.run.fid) this.resetRun()
  },
  methods: {
    resetRun: function () {
      var f = this.flow
      this.evalResult = null
      this.reason = ''
      this.run = {
        fid: f ? f.id : null,
        cur: f && f.steps && f.steps[0] ? f.steps[0].id : null,
        checks: {}, log: [], path: [], done: false, min: 0
      }
      if (this.trial) this.evaluate()
    },
    /** 向试跑接口取当前步的统计、曲线和系统预判。 */
    evaluate: function () {
      var self = this
      var step = this.cur
      if (!this.trial || !this.event || !step) return Promise.resolve(null)
      var stepId = step.id
      return http.post('/api/trials/' + this.event.id + '/steps/' + stepId + '/evaluate').then(function (r) {
        if (self.cur && self.cur.id === stepId) {
          self.evalResult = r
          self.$nextTick(function () { self.drawCharts() })
        }
        return r
      }).catch(function (e) {
        if (e && e.message) self.$message.error(e.message)
        return null
      })
    },
    drawCharts: function () {
      var self = this
      ;(this.displayCards || []).forEach(function (c) {
        if (!c.cardId || !c.points || !c.points.length) return
        var el = document.getElementById(self.chartId(c.cardId))
        if (!el) return
        var chart = echarts.getInstanceByDom(el) || echarts.init(el)
        chart.resize()
        chart.setOption({
          grid: { left: 30, right: 8, top: 12, bottom: 18 },
          xAxis: { type: 'value', name: 's' },
          yAxis: { type: 'value', scale: true },
          series: [{ type: 'line', showSymbol: false, data: c.points, markLine: { data: [{ xAxis: 0 }] } }]
        })
      })
    },
    chartId: function (id) { return (this.trial ? 'tchart-' : 'vchart-') + id },
    stepIndex: function (s) {
      if (!this.flow || !s) return 0
      var i = -1
      this.flow.steps.forEach(function (x, n) { if (x.id === s.id) i = n })
      return i < 0 ? 0 : i
    },
    stepColor: function (t) {
      return { VIEW: '#0369a1', JUDGE: '#b45309', OP: '#15803d', CONTACT: '#be185d', END: '#334155' }[t] || '#334155'
    },
    typeLabel: function (t) { return TYPES[t] || t },
    roleLabel: function (r) { return { DRIVER: '司机', EXPERT: '专家', SYSTEM: '系统' }[r] || r },
    conclLabel: function (c) {
      return { MAINTAIN: '维持运行', SPEED_LIMIT: '限速运行', RESCUE: '请求救援', RETURN_DEPOT: '回库处理' }[c] || (c || '')
    },
    conclStyle: function (c) {
      var map = {
        MAINTAIN: ['#15803d', '#f0fdf4'], SPEED_LIMIT: ['#b45309', '#fffbeb'],
        RESCUE: ['#b91c1c', '#fef2f2'], RETURN_DEPOT: ['#1d4ed8', '#eff6ff']
      }
      var x = map[c] || ['#334155', '#f1f5f9']
      return { color: x[0], background: x[1], borderColor: x[0] }
    },
    circ: function (i) { return CIRC[i] || (i + 1) },
    isChecked: function (k) {
      var arr = this.cur && this.run.checks[this.cur.id]
      return !!(arr && arr[k])
    },
    toggleCk: function (k, checked) {
      var s = this.cur
      if (!s) return
      var checks = Object.assign({}, this.run.checks)
      var arr = (checks[s.id] || []).slice()
      arr[k] = !!checked
      checks[s.id] = arr
      this.run = Object.assign({}, this.run, { checks: checks })
    },
    checkAll: function () {
      var s = this.cur
      if (!s) return
      var checks = Object.assign({}, this.run.checks)
      checks[s.id] = (s.confirms || []).map(function () { return true })
      this.run = Object.assign({}, this.run, { checks: checks })
    },
    hasDataCond: function (s) {
      return !!s && (s.branches || []).some(function (b) { return b.condSrc && b.condSrc !== 'NONE' && b.condSrc !== 'ELSE' })
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
      if (!s) return ''
      return (s.branches || []).map(function (b) { return b.branchLabel + '：' + self.condText(s, b) }).join('；')
    },
    judgeBtn: function (b) {
      if (!this.trial) return '选择「' + b.branchLabel + '」'
      if (this.preLabel && this.preLabel === b.branchLabel) return '✓ 确认预判「' + b.branchLabel + '」'
      if (this.preLabel) return '改判为「' + b.branchLabel + '」'
      return '选择「' + b.branchLabel + '」'
    },
    /**
     * 手工选分支。试跑里改判要填理由；操作步骤选「成功」必须先勾完确认项。
     */
    runPick: function (label) {
      var s = this.cur
      if (!s || this.run.done) return
      var by = '专家确认'
      var reason = ''
      if (s.stepType === 'JUDGE') {
        if (this.trial && this.preLabel) {
          if (this.preLabel !== label) {
            reason = (this.reason || '').trim()
            if (!reason) { this.$message.error('改判须填写理由'); return }
            by = '专家改判（预判「' + this.preLabel + '」）'
          } else by = '系统预判 · 专家确认'
        } else by = '专家选择'
      }
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
      this.commit(label, by, reason)
      this.reason = ''
    },
    commit: function (label, by, reason) {
      var s = this.cur
      if (!s || this.run.done) return
      var min = (this.run.min || 0) + (SIMMIN[s.stepType] == null ? 1 : SIMMIN[s.stepType])
      var log = this.run.log.concat([{ no: this.circ(this.stepIndex(s)), type: s.stepType, title: s.stepTitle, choice: label || '', by: by, reason: reason || '', min: min }])
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
    /** 单步和自动运行按预判或事件记录往下走，操作步会先视为确认项已勾选。 */
    autoChoice: function (r) {
      var s = this.cur
      if (!s) return null
      var recorded = this.event && this.event.answers ? this.event.answers[s.stepCode] : null
      if (s.stepType === 'JUDGE') {
        var label = (r && r.prejudgeLabel) || recorded || (s.branches[0] && s.branches[0].branchLabel)
        var by = (r && r.prejudgeLabel) ? '系统预判 · 专家确认' : (recorded ? '专家选择（按事件记录）' : '专家选择')
        return { label: label, by: by }
      }
      if (s.stepType === 'OP') {
        this.checkAll()
        return { label: recorded || '成功', by: '专家代录司机反馈' }
      }
      return { label: s.branches[0] && s.branches[0].branchLabel, by: '专家确认' }
    },
    stepOnce: function () {
      var self = this
      if (this.run.done || !this.cur) return
      var go = function (r) {
        var pick = self.autoChoice(r)
        if (pick && pick.label) self.commit(pick.label, pick.by, '')
      }
      if (this.trial) this.evaluate().then(go)
      else go(null)
    },
    autoRun: function () {
      var self = this
      if (this.ticking || this.run.done) return
      this.ticking = true
      var guard = 0
      var tick = function () {
        if (!self.cur || self.run.done || self.cur.stepType === 'END' || guard++ > 20) { self.ticking = false; return }
        var go = function (r) {
          var pick = self.autoChoice(r)
          if (!pick || !pick.label) { self.ticking = false; return }
          self.commit(pick.label, pick.by, '')
          self.$nextTick(tick)
        }
        if (self.trial) self.evaluate().then(go)
        else go(null)
      }
      tick()
    }
  }
}
</script>

<style scoped>
.trialbar { display:flex; gap:6px; align-items:center; margin-bottom:6px; }
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
.row { display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
.sno { display:inline-flex; width:20px; height:20px; border-radius:50%; background:#1e293b; color:#fff; font-size:12px; align-items:center; justify-content:center; flex:none; }
.tbadge { font-size:11px; line-height:17px; padding:0 6px; border-radius:4px; font-weight:700; color:#fff; flex:none; }
.t-view { background:#0369a1; } .t-judge { background:#b45309; } .t-op { background:#15803d; } .t-contact { background:#be185d; } .t-end { background:#334155; }
.rchip { display:inline-block; font-size:11px; line-height:16px; border-radius:3px; padding:0 5px; font-weight:600; color:#fff; }
.r-DRIVER { background:#2563eb; } .r-EXPERT { background:#7c3aed; } .r-SYSTEM { background:#0d9488; }
.safety { color:#b91c1c; background:#fef2f2; border-radius:4px; padding:3px 7px; margin:5px 0; font-size:12px; }
.dcard { border:1px solid var(--line); border-radius:6px; padding:6px 8px; margin:6px 0; font-size:12px; }
.chart { height:110px; }
.actbox { border-top:1px dashed var(--line); padding-top:8px; margin-top:4px; }
.pjbox { border-radius:6px; padding:6px 9px; margin-bottom:7px; font-size:12px; }
.pjbox.hit { border:1px solid #99f6e4; background:#f0fdfa; color:#0f766e; }
.pjbox.none { border:1px solid #e2e8f0; background:#f8fafc; color:#334155; }
.cklist { display:flex; flex-direction:column; gap:4px; margin-bottom:7px; font-size:12px; }
.ckline { display:flex; gap:6px; align-items:flex-start; }
.concbox { border:1.5px solid; border-radius:8px; padding:9px 11px; font-size:12px; line-height:1.6; }
.cb1 { font-size:15px; font-weight:700; }
.driver .screen { background:#0b1220; border:6px solid #334155; border-radius:10px; min-height:210px; padding:12px 10px; color:#e2e8f0; display:flex; flex-direction:column; gap:8px; justify-content:center; text-align:center; }
.dmsg { font-size:12px; line-height:1.5; }
.dmsg.tag { color:#fbbf24; font-size:11px; }
.dmsg.big { font-size:15px; font-weight:700; color:#fff; }
.dmsg.warn { color:#fca5a5; }
.dmsg.concl { font-size:18px; font-weight:800; color:#86efac; }
.runlog { margin-top:9px; background:#fff; border:1px solid var(--line); border-radius:8px; padding:8px 10px; }
.lg { font-size:12px; padding:3px 0; border-bottom:1px dashed #f1f5f9; }
.lt { display:inline-block; width:36px; color:#94a3b8; font-family:monospace; }
</style>
