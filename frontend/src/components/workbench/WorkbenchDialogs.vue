<template>
  <div>
    <el-drawer title="通用前置故障规则" :visible.sync="host.preOpen" size="610px" custom-class="proto-drawer">
      <div style="padding:0 16px 16px">
        <div class="note">前置先于组合执行，任一未通过即拦截。范围和执行时机可配置，此处是沙盒，不会改现网。</div>
        <button type="button" class="primary" style="width:100%" @click="host.preForm = host.freshPre()">＋ 新增前置规则</button>
        <article v-for="p in host.pres" :key="p.id" class="card">
          <div class="between">
            <b>{{ p.filterName }}</b>
            <el-switch :value="p.isEnabled === 1" @change="host.togglePre(p, $event)" />
          </div>
          <p class="mono" style="font-size:12px;overflow-wrap:anywhere;margin:8px 0">{{ p.filterExpr }}</p>
          <div class="chips">
            <span class="badge">{{ p.scopeCx }}</span>
            <span class="badge blue">{{ p.scopeLy || 'ALL' }}</span>
            <span class="badge">{{ timing(p.execTiming) }}</span>
            <span class="badge">优先级 {{ p.priority }}</span>
          </div>
          <div class="between" style="margin-top:9px">
            <span class="hint mono">{{ p.filterCode || ('PF_' + p.id) }}</span>
            <div>
              <button type="button" class="link small" @click="host.preForm = host.editPre(p)">编辑</button>
              <button type="button" class="link small danger" @click="host.removePre(p)">删除</button>
            </div>
          </div>
        </article>
      </div>
    </el-drawer>

    <proto-modal :visible="!!host.preForm" :title="host.preForm && host.preForm.id ? '编辑通用前置规则' : '新增通用前置规则'" @close="host.preForm = null">
      <form v-if="host.preForm" @submit.prevent="host.savePre()">
        <label class="field">规则名称
          <el-input v-model="host.preForm.filterName" />
        </label>
        <label class="field">协议指标
          <el-select v-model="host.preForm.paramCol" filterable>
            <el-option v-for="p in host.params" :key="p.id" :label="p.paramName + ' ' + p.paramCol" :value="p.paramCol" />
          </el-select>
        </label>
        <div class="cols2">
          <label class="field">比较符
            <el-select v-model="host.preForm.cmpOp">
              <el-option v-for="o in host.ops" :key="o" :label="o === '=~' ? '=~ 正则匹配' : o" :value="o" />
            </el-select>
          </label>
          <label class="field">目标值
            <el-input v-model="host.preForm.cmpVal" />
          </label>
        </div>
        <label class="field">适用车型范围（ALL 与具体车型互斥）</label>
        <div class="checkgrid">
          <label v-for="m in scopeModels" :key="m">
            <input type="checkbox" :checked="scopeOn(m)" @change="toggleScope(m, $event.target.checked)">
            {{ m === 'ALL' ? 'ALL 全部车型' : m }}
          </label>
        </div>
        <div class="cols2" style="margin-top:13px">
          <label class="field">适用来源
            <el-select v-model="host.preForm.scopeLy">
              <el-option label="ALL 全部来源" value="ALL" />
              <el-option label="TCMS" value="TCMS" />
              <el-option label="6A" value="6A" />
            </el-select>
          </label>
          <label class="field">执行时机
            <el-select v-model="host.preForm.execTiming">
              <el-option label="查 HBase 前短路拦截" value="BEFORE_HBASE" />
              <el-option label="查 HBase 后拦截" value="AFTER_HBASE" />
            </el-select>
          </label>
        </div>
        <label class="field">优先级（数字越小越先执行）
          <el-input-number v-model="host.preForm.priority" :min="1" />
        </label>
        <p class="hint">指标若来自 HBase，执行时机应选「查 HBase 后拦截」。保存后按车型与来源重新计算各故障继承的前置。</p>
      </form>
      <template slot="footer">
        <button type="button" @click="host.preForm = null">取消</button>
        <button type="button" class="primary" @click="host.savePre()">保存前置规则</button>
      </template>
    </proto-modal>

    <proto-modal :visible="!!host.atomDlg" :title="atomTitle" @close="host.atomDlg = null">
      <form v-if="host.atomDlg" @submit.prevent="host.saveAtom()">
        <div v-if="atomUsage && atomUsage.faults && atomUsage.faults.length" class="warning">
          当前原子规则已被 {{ atomUsage.faults.length }} 条故障代码共享引用，保存修改后将自动同步更新所有引用方的展开表达式。<br>
          {{ usageFaults(atomUsage) }}
        </div>
        <div class="cols2">
          <label class="field">原子类型
            <el-select v-model="host.atomDlg.atomType">
              <el-option label="参数测点比较" value="PARAM" />
              <el-option label="关联故障时间窗" value="WINDOW" />
            </el-select>
          </label>
          <label class="field">适用车型
            <el-select v-model="host.atomDlg.scopeCx">
              <el-option v-for="c in atomScopes" :key="c" :label="c === 'ALL' ? 'ALL 全部车型' : c" :value="c" />
            </el-select>
          </label>
        </div>
        <template v-if="host.atomDlg.atomType === 'PARAM'">
          <label class="field">V3 协议参数元数据
            <el-select v-model="host.atomDlg.paramCol" filterable placeholder="按中文名 / 编码检索协议参数">
              <el-option v-for="p in host.params" :key="p.paramCol + p.id" :label="p.paramName + ' · ' + p.paramCol + (p.dataSource ? ' · ' + p.dataSource : '') + (p.unit ? ' · ' + p.unit : '')" :value="p.paramCol" />
            </el-select>
          </label>
          <div v-if="atomParam" class="note">
            <b>{{ atomParam.paramName }}</b> · <code>{{ atomParam.paramCol }}</code><br>
            数据源 {{ atomParam.dataSource || '—' }}　单位 {{ atomParam.unit || '无' }}
          </div>
          <div class="cols2">
            <label class="field">比较符
              <el-select v-model="host.atomDlg.cmpOp">
                <el-option v-for="o in host.ops" :key="o" :label="o === '=~' ? '=~ 正则匹配' : o" :value="o" />
              </el-select>
            </label>
            <label class="field">目标值
              <el-select v-if="atomEnums.length" v-model="host.atomDlg.cmpVal">
                <el-option v-for="e in atomEnums" :key="e.value" :label="e.value + ' : ' + e.label" :value="e.value" />
              </el-select>
              <el-input v-else v-model="host.atomDlg.cmpVal" :placeholder="cmpPlaceholder" />
              <span class="hint">{{ cmpHint }}</span>
            </label>
          </div>
        </template>
        <template v-else>
          <label class="field">时间窗函数
            <el-select v-model="host.atomDlg.winFn">
              <el-option v-for="f in host.winFns" :key="f" :label="f + ' · ' + winFnLabel(f)" :value="f" />
            </el-select>
          </label>
          <label class="field">同车事件窗口（秒）
            <el-input-number v-model="host.atomDlg.winSec" :min="1" />
          </label>
          <label class="field">关联故障代码（英文逗号分隔）
            <el-input v-model="host.atomDlg.relGzdm" placeholder="如 1873,1874" />
          </label>
          <div class="toolbar">
            <button v-for="c in quickCodes" :key="c" type="button" @click="pickCode(c)">＋ {{ c }}</button>
          </div>
        </template>
        <label class="field">原子规则名称（留空自动生成）
          <el-input v-model="host.atomDlg.atomName" placeholder="根据中文参数与阈值自动生成" />
        </label>
        <p v-if="!host.atomDlg.id" class="hint">新建后自动加入当前故障组合，记得再保存故障规则。</p>
      </form>
      <template slot="footer">
        <button type="button" @click="host.atomDlg = null">取消</button>
        <button type="button" class="primary" @click="host.saveAtom()">保存共享定义</button>
      </template>
    </proto-modal>

    <proto-modal wide :visible="!!host.groupDlg" :title="groupTitle" @close="host.groupDlg = null">
      <form v-if="host.groupDlg" @submit.prevent="host.saveGroup()">
        <div v-if="groupUsage && groupUsage.faults && groupUsage.faults.length" class="warning">
          该命名组已被 {{ groupUsage.faults.length }} 条故障引用，保存后所有引用方的展开表达式同步更新。<br>
          {{ usageFaults(groupUsage) }}
        </div>
        <div class="cols2">
          <label class="field">组名称（业务说法，组内唯一）
            <el-input v-model="host.groupDlg.groupName" placeholder="如 机车在运行" />
          </label>
          <label class="field">适用车型
            <el-select v-model="host.groupDlg.scopeCx">
              <el-option v-for="c in groupScopes" :key="c" :label="c === 'ALL' ? 'ALL 全部车型' : c" :value="c" />
            </el-select>
          </label>
        </div>
        <div class="field" style="margin-bottom:6px">① 点击原子插入组合式（以原子编号 R001… 引用，命名组内不再嵌套命名组）</div>
        <input v-model="groupAtomQ" class="full" placeholder="⌕ 按中文 / 编号 / 参数筛选原子">
        <div class="grouppicker">
          <button v-for="a in groupAtoms" :key="a.id" type="button" class="pick" @click="insertGroupToken(a.atomCode)">
            <span class="mono">{{ a.atomCode }}</span> {{ a.atomName }}
          </button>
        </div>
        <div class="field" style="margin:10px 0 6px">② 编排组合式</div>
        <div class="toolbar">
          <button type="button" @click="insertGroupToken(' & ')">且 (&amp;)</button>
          <button type="button" @click="insertGroupToken(' | ')">或 (|)</button>
          <button type="button" @click="insertGroupToken('(')">左括号 (</button>
          <button type="button" @click="insertGroupToken(')')">右括号 )</button>
        </div>
        <el-input ref="gexpr" type="textarea" :rows="3" class="expr" v-model="host.groupDlg.groupExpr" placeholder="(R001 & R002) | (R003 & R002)" @input="host.previewGroup()" />
        <group-preview :preview="host.groupPreview" :name="host.groupDlg.groupName" />
      </form>
      <template slot="footer">
        <button type="button" @click="host.groupDlg = null">取消</button>
        <button type="button" class="primary" @click="host.saveGroup()">保存命名组</button>
      </template>
    </proto-modal>

    <el-dialog title="新增故障条目" :visible.sync="host.faultDlg" width="480px" custom-class="proto-dialog">
      <el-form label-width="90px" size="small">
        <el-form-item label="车型"><el-input v-model="host.newFault.cx" /></el-form-item>
        <el-form-item label="来源">
          <el-select v-model="host.newFault.ly"><el-option label="TCMS" value="TCMS" /><el-option label="6A" value="6A" /></el-select>
        </el-form-item>
        <el-form-item label="故障代码"><el-input v-model="host.newFault.gzdm" /></el-form-item>
        <el-form-item label="名称"><el-input v-model="host.newFault.gzmc" /></el-form-item>
        <el-form-item label="模型"><el-input v-model="host.newFault.mxmc" /></el-form-item>
        <el-form-item label="健康等级">
          <el-select v-model="host.newFault.jkdj"><el-option v-for="k in ['A','B','C','D']" :key="k" :label="k" :value="k" /></el-select>
        </el-form-item>
      </el-form>
      <span slot="footer"><button type="button" class="primary" @click="host.createFault()">引入并开始配置</button></span>
    </el-dialog>

    <el-dialog title="引用关系" :visible.sync="host.refDlg" width="480px" custom-class="proto-dialog">
      <div v-if="host.refInfo">
        <div><b>{{ host.refInfo.code }}</b> {{ host.refInfo.name }}</div>
        <div class="hint">直接故障 {{ host.refInfo.directFaults }} · 命名组 {{ host.refInfo.inGroups }} · 分支 {{ host.refInfo.inBranches }}</div>
        <div v-for="f in host.refInfo.faults" :key="f.id">
          <button type="button" class="link" @click="host.gotoFault(f)">{{ f.cx }} / {{ f.ly }} / {{ f.gzdm }} {{ f.gzmc }}</button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { timingLabel } from '../../workbench/explain'
import GroupPreview from '../GroupPreview.vue'
import ProtoModal from './ProtoModal.vue'
/**
 * 前置、原子、命名组和故障的编辑弹窗。保存仍走宿主上的原接口。
 * 前置规则的新建/编辑用原型 modal：标题、分组字段、说明、底部按钮。
 */
export default {
  name: 'WorkbenchDialogs',
  components: { GroupPreview: GroupPreview, ProtoModal: ProtoModal },
  props: { host: { type: Object, required: true } },
  data: function () { return { groupAtomQ: '' } },
  computed: {
    /** 车型勾选：ALL 在前，再加底账里出现过的车型，以及当前值里多出来的车型。 */
    scopeModels: function () {
      var set = { ALL: 1 }
      ;(this.host.cxOptions || []).forEach(function (c) { if (c) set[c] = 1 })
      this.scopeList().forEach(function (s) { set[s] = 1 })
      return Object.keys(set).sort(function (a, b) {
        if (a === 'ALL') return -1
        if (b === 'ALL') return 1
        return a < b ? -1 : a > b ? 1 : 0
      })
    },
    /** 标题带原子编号，和原型「编辑共享原子规则 · R00x」一致。 */
    atomTitle: function () {
      var a = this.host.atomDlg
      if (!a) return ''
      if (!a.id) return '新建原子规则'
      var row = (this.host.atoms || []).filter(function (x) { return x.id === a.id })[0]
      return '编辑共享原子规则 · ' + ((row && row.atomCode) || a.id)
    },
    atomUsage: function () {
      var a = this.host.atomDlg
      if (!a || !a.id) return null
      return (this.host.usage || {})['a' + a.id] || null
    },
    atomParam: function () {
      var col = this.host.atomDlg && this.host.atomDlg.paramCol
      if (!col) return null
      return (this.host.params || []).filter(function (p) { return p.paramCol === col })[0] || null
    },
    /** 枚举比较才改成下拉，写入的仍是编码值。集合和正则继续用手填。 */
    atomEnums: function () {
      var p = this.atomParam
      var dlg = this.host.atomDlg
      if (!p || !dlg || !p.enumDict) return []
      if (dlg.cmpOp === 'IN' || dlg.cmpOp === 'NOT IN' || dlg.cmpOp === '=~') return []
      var out = []
      String(p.enumDict).split(';').forEach(function (part) {
        var i = part.indexOf(':')
        if (i > 0) out.push({ value: part.slice(0, i).trim(), label: part.slice(i + 1).trim() })
      })
      return out
    },
    atomScopes: function () {
      var set = { ALL: 1 }
      ;(this.host.cxOptions || []).forEach(function (c) { if (c) set[c] = 1 })
      var cur = this.host.atomDlg && this.host.atomDlg.scopeCx
      if (cur) set[cur] = 1
      return Object.keys(set).sort(function (a, b) {
        if (a === 'ALL') return -1
        if (b === 'ALL') return 1
        return a < b ? -1 : a > b ? 1 : 0
      })
    },
    cmpPlaceholder: function () {
      var op = this.host.atomDlg && this.host.atomDlg.cmpOp
      if (op === '=~') return '如 ^[A-Za-z]'
      if (op === 'IN' || op === 'NOT IN') return '逗号分隔的编码值'
      return (this.atomParam && this.atomParam.unit) || '目标值，缺失写 -'
    },
    cmpHint: function () {
      var p = this.atomParam
      var op = this.host.atomDlg && this.host.atomDlg.cmpOp
      var unit = p && p.unit ? ('单位：' + p.unit) : '文本 / 编码值'
      if (op === 'IN' || op === 'NOT IN' || op === '=~') unit += ' · 支持集合或正则'
      return unit
    },
    quickCodes: function () { return ['1873', '1874', '1031', '1742'] },
    groupTitle: function () {
      var g = this.host.groupDlg
      if (!g) return ''
      if (!g.id) return '新建命名条件组'
      var row = (this.host.groups || []).filter(function (x) { return x.id === g.id })[0]
      return '编辑命名条件组 · ' + ((row && row.groupCode) || g.id)
    },
    groupUsage: function () {
      var g = this.host.groupDlg
      if (!g || !g.id) return null
      return (this.host.usage || {})['g' + g.id] || null
    },
    groupScopes: function () {
      var set = { ALL: 1 }
      ;(this.host.cxOptions || []).forEach(function (c) { if (c) set[c] = 1 })
      var cur = this.host.groupDlg && this.host.groupDlg.scopeCx
      if (cur) set[cur] = 1
      return Object.keys(set).sort(function (a, b) {
        if (a === 'ALL') return -1
        if (b === 'ALL') return 1
        return a < b ? -1 : a > b ? 1 : 0
      })
    },
    /** 成员原子列表。只展示原子，命名组不能再套命名组。 */
    groupAtoms: function () {
      var q = (this.groupAtomQ || '').toLowerCase()
      return (this.host.atoms || []).filter(function (a) {
        if (!q) return true
        return (a.atomCode + ' ' + (a.atomName || '') + ' ' + (a.paramCol || '') + ' ' + (a.atomExpr || '')).toLowerCase().indexOf(q) >= 0
      })
    }
  },
  methods: {
    timing: timingLabel,
    winFnLabel: function (f) {
      return { allNotExists: '窗口内均未出现', anyExists: '窗口内任一出现', allExists: '窗口内全部出现', anyNotExists: '窗口内不全出现' }[f] || f
    },
    /** 点一下把故障代码补进逗号串，已有的不重复。 */
    usageFaults: function (usage) {
      return ((usage && usage.faults) || []).map(function (f) { return f.cx + '/' + f.gzdm }).join('、')
    },
    /**
     * 在光标处插入原子编号或且/或/括号。前面已有内容且不是运算符时，原子前自动补「且」。
     * 组合式文本仍交给原来的预览和保存接口。
     */
    insertGroupToken: function (token) {
      var dlg = this.host.groupDlg
      if (!dlg) return
      var input = this.$refs.gexpr
      var el = input && (input.$refs.textarea || input.$refs.input)
      var value = dlg.groupExpr || ''
      var start = el && el.selectionStart != null ? el.selectionStart : value.length
      var end = el && el.selectionEnd != null ? el.selectionEnd : start
      var piece = token
      if (/^R\d+/.test(token) && value.slice(0, start).trim() && !/[&|(]\s*$/.test(value.slice(0, start))) piece = ' & ' + token
      dlg.groupExpr = value.slice(0, start) + piece + value.slice(end)
      this.host.previewGroup()
      var pos = start + piece.length
      this.$nextTick(function () {
        if (!el) return
        el.focus()
        if (el.setSelectionRange) el.setSelectionRange(pos, pos)
      })
    },
    pickCode: function (code) {
      var dlg = this.host.atomDlg
      if (!dlg) return
      var cur = String(dlg.relGzdm || '').split(/[,，]/).map(function (s) { return s.trim() }).filter(Boolean)
      if (cur.indexOf(code) < 0) cur.push(code)
      dlg.relGzdm = cur.join(',')
    },
    scopeList: function () {
      var raw = (this.host.preForm && this.host.preForm.scopeCx) || ''
      return String(raw).split(',').map(function (s) { return s.trim() }).filter(Boolean)
    },
    scopeOn: function (m) { return this.scopeList().indexOf(m) >= 0 },
    /** 勾选写回 scopeCx 字符串。选 ALL 会清掉具体车型，选具体车型会去掉 ALL。 */
    toggleScope: function (code, on) {
      if (!this.host.preForm) return
      var cur = this.scopeList()
      if (on) {
        cur = code === 'ALL' ? ['ALL'] : cur.filter(function (x) { return x !== 'ALL' && x !== code }).concat([code])
      } else {
        cur = cur.filter(function (x) { return x !== code })
      }
      this.host.preForm.scopeCx = cur.join(',')
    }
  }
}
</script>

<style scoped>
/* Element 控件嵌在原型 label.field 里，拉成和原生输入框一样的整行。 */
.field >>> .el-input,
.field >>> .el-select,
.field >>> .el-input-number { display: block; width: 100%; margin-top: 5px; }
.hint { margin: 4px 0 0; }
</style>
