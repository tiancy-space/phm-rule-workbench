<template>
  <aside class="panel">
    <div class="ph">
      <div class="step">03 / 共享原子规则池</div>
      <div class="between">
        <h2>{{ kind === 'atom' ? '原子积木库' : '命名条件组' }} <span class="count">{{ kind === 'atom' ? atomRows.length : groupRows.length }}</span></h2>
        <button type="button" class="small primary" @click="$emit('create')">＋ 新建</button>
      </div>
      <div class="seg" style="margin-top:8px">
        <button type="button" :class="{ active: kind === 'atom' }" @click="$emit('kind', 'atom')">原子条件 {{ atoms.length }}</button>
        <button type="button" :class="{ active: kind === 'group' }" @click="$emit('kind', 'group')">命名条件组 {{ groups.length }}</button>
      </div>
      <div class="filters" style="margin-top:8px">
        <select :value="scope" @change="$emit('scope', $event.target.value)">
          <option value="FIT">适配当前车型（{{ cx || '当前' }} + ALL 通用）</option>
          <option value="ALL">全库全部车型</option>
        </select>
        <div v-if="kind === 'atom'" class="seg">
          <button type="button" :class="{ active: !type }" @click="$emit('type', '')">全部</button>
          <button type="button" :class="{ active: type === 'PARAM' }" @click="$emit('type', 'PARAM')">参数比较</button>
          <button type="button" :class="{ active: type === 'WINDOW' }" @click="$emit('type', 'WINDOW')">时间窗关联</button>
        </div>
        <input :value="q" placeholder="⌕ 按原子名称 / 参数 / 编码" @input="$emit('q', $event.target.value)" />
      </div>
    </div>
    <div class="scroll">
      <template v-if="kind === 'atom'">
        <article v-for="a in atomRows" :key="a.id" class="poolcard">
          <div class="between">
            <span class="mono hint">{{ a.atomCode }}</span>
            <span class="row" style="gap:4px">
              <span class="badge">{{ a.scopeCx === 'ALL' ? 'ALL 通用' : a.scopeCx }}</span>
              <span class="badge" :class="a.atomType === 'WINDOW' ? 'amber' : ''">{{ a.atomType === 'WINDOW' ? '时间窗关联' : '参数比较' }}</span>
            </span>
          </div>
          <div class="title">{{ a.atomName }}</div>
          <div class="raw mono">{{ a.atomExpr }}</div>
          <button type="button" class="link small" @click="$emit('refs', 'atom', a.id)">{{ usageText('atom', a.id) }}</button>
          <div class="poolfoot">
            <button type="button" class="small primary" :disabled="used(a.atomCode)" @click="$emit('use-atom', a)">{{ used(a.atomCode) ? ('✓ 已引用为 ' + (aliasOf(a.atomCode) || '当前')) : '＋ 引用到当前故障' }}</button>
            <button type="button" class="link small" @click="$emit('edit-atom', a)">编辑</button>
          </div>
        </article>
      </template>
      <template v-else>
        <article v-for="g in groupRows" :key="g.id" class="poolcard">
          <div class="between"><b>{{ g.groupCode }}</b> <span class="badge violet">{{ kindLabel(g) }}</span></div>
          <div class="title">◆ {{ g.groupName }}</div>
          <div class="logic">{{ phrase(g) }}</div>
          <div class="raw mono">{{ g.groupExpr }}</div>
          <button type="button" class="link small" @click="$emit('refs', 'group', g.id)">{{ usageText('group', g.id) }}</button>
          <div class="poolfoot">
            <button type="button" class="small primary" :disabled="used(g.groupCode)" @click="$emit('use-group', g)">{{ used(g.groupCode) ? ('✓ 已引用为 ' + (aliasOf(g.groupCode) || '当前')) : '＋ 引用到当前故障' }}</button>
            <button type="button" class="link small" @click="$emit('edit-group', g)">编辑</button>
          </div>
        </article>
      </template>
    </div>
    <div class="hint" style="padding:8px 14px;border-top:1px solid var(--line)">点击「引用」添加积木，再编排且 / 或 / 括号</div>
  </aside>
</template>

<script>
import { groupKind, groupPhrase } from '../../workbench/explain'
/** 右栏原子池。头部筛选固定，卡片独立滚动。引用按钮是实心蓝。 */
export default {
  name: 'AtomPoolPanel',
  props: {
    kind: { type: String, default: 'atom' },
    scope: { type: String, default: 'FIT' },
    type: { type: String, default: '' },
    q: { type: String, default: '' },
    cx: { type: String, default: '' },
    atoms: { type: Array, default: function () { return [] } },
    groups: { type: Array, default: function () { return [] } },
    atomRows: { type: Array, default: function () { return [] } },
    groupRows: { type: Array, default: function () { return [] } },
    usedCodes: { type: Array, default: function () { return [] } },
    refs: { type: Array, default: function () { return [] } },
    usageText: { type: Function, required: true }
  },
  methods: {
    used: function (code) { return this.usedCodes.indexOf(code) >= 0 },
    aliasOf: function (code) {
      var hit = (this.refs || []).filter(function (r) { return r.code === code })[0]
      return hit ? hit.alias : ''
    },
    phrase: function (g) { return groupPhrase(g, this.atoms) },
    kindLabel: function (g) { return groupKind(g) }
  }
}
</script>

<style scoped>
button.primary:disabled { opacity: .55; }
</style>
