<template>
  <aside class="panel">
    <div class="ph">
      <div class="between">
        <div>
          <div class="step">01 / 故障底账</div>
          <h2>选择故障代码 <span class="count">{{ rows.length }} / {{ total }}</span></h2>
        </div>
        <button type="button" class="small" @click="$emit('create')">＋ 新增条目</button>
      </div>
      <div class="filters" style="margin-top:10px">
        <select :value="filters.cx" @change="set('cx', $event.target.value)">
          <option value="">全部车型</option>
          <option v-for="c in cxOptions" :key="c" :value="c">{{ c }}</option>
        </select>
        <select :value="filters.mode" @change="set('mode', $event.target.value)">
          <option value="">全部判定模式</option>
          <option v-for="m in modes" :key="m.value" :value="m.value">{{ m.label }}</option>
        </select>
        <div class="seg">
          <button type="button" :class="{ active: !filters.ly }" @click="set('ly', '')">全部来源</button>
          <button type="button" :class="{ active: filters.ly === 'TCMS' }" @click="set('ly', 'TCMS')">TCMS</button>
          <button type="button" :class="{ active: filters.ly === '6A' }" @click="set('ly', '6A')">6A</button>
        </div>
        <div class="seg czseg">
          <button type="button" :class="{ active: !filters.cz }" @click="set('cz', '')">全部 {{ total }}</button>
          <button type="button" :class="{ active: filters.cz === 'CHECK' }" @click="set('cz', 'CHECK')"><i class="czdot cz-check"></i>排查 <b>{{ count('CHECK') }}</b></button>
          <button type="button" :class="{ active: filters.cz === 'WATCH' }" @click="set('cz', 'WATCH')"><i class="czdot cz-watch"></i>关注 <b>{{ count('WATCH') }}</b></button>
          <button type="button" :class="{ active: filters.cz === 'NONE' }" @click="set('cz', 'NONE')"><i class="czdot cz-none"></i>无需干预 <b>{{ count('NONE') }}</b></button>
        </div>
        <input :value="filters.q" placeholder="搜索故障代码 / 名称 / 模型" @input="set('q', $event.target.value)" />
      </div>
    </div>
    <div class="scroll">
      <div v-for="f in rows" :key="f.id" class="fault" :class="{ selected: currentId === f.id }" tabindex="0" @click="$emit('pick', f)">
        <div class="between">
          <b class="code">{{ f.gzdm }}</b>
          <span class="cztag" :class="'cz-' + (f.czdj || '').toLowerCase()">{{ czLabel(f.czdj) }}</span>
        </div>
        <div class="name">{{ f.gzmc }}</div>
        <div class="model">{{ f.cx }} · {{ f.ly }} · 健康 {{ f.jkdj }} · {{ modeLabel(f.ruleMode) }}<template v-if="f.ruleMode === 'CONDITIONAL'"> · {{ f.refCount }} 个条件</template></div>
        <div class="status" :class="{ disabled: !f.flowId, pending: f.flowStatus !== 'PUBLISHED' }">
          <span v-if="f.flowId" class="stpill" :class="f.flowStatus === 'PUBLISHED' ? 'pub' : 'draft'">{{ f.flowStatus === 'PUBLISHED' ? ('处置流程 v' + f.pubVerNo) : '处置流程 草稿' }}</span>
          <span v-else>未配置处置流程</span>
          <span v-if="f.skipCount" class="badge">前置豁免 {{ f.skipCount }}</span>
        </div>
      </div>
    </div>
  </aside>
</template>

<script>
/** 左栏故障底账。头部固定，列表单独滚动，选中项左侧 3px 蓝条。 */
export default {
  name: 'FaultListPanel',
  props: {
    rows: { type: Array, default: function () { return [] } },
    total: { type: Number, default: 0 },
    faults: { type: Array, default: function () { return [] } },
    filters: { type: Object, required: true },
    cxOptions: { type: Array, default: function () { return [] } },
    modes: { type: Array, default: function () { return [] } },
    currentId: { type: [Number, String], default: null }
  },
  methods: {
    set: function (key, value) {
      var next = Object.assign({}, this.filters)
      next[key] = value
      this.$emit('filter', next)
    },
    count: function (cz) { return this.faults.filter(function (f) { return f.czdj === cz }).length },
    czLabel: function (v) { return { CHECK: '排查', WATCH: '关注', NONE: '无需干预' }[v] || v },
    modeLabel: function (v) {
      var m = this.modes.filter(function (x) { return x.value === v })[0]
      return m ? m.label : v
    }
  }
}
</script>

