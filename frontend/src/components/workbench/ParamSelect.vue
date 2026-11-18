<template>
  <div class="param-select">
    <div ref="trigger" class="box" :class="{ open: open }" @click="toggle">
      <span v-if="selected" class="text">{{ labelOf(selected) }}</span>
      <span v-else class="placeholder">{{ placeholder || '按中文名 / 编码 / 子系统搜索' }}</span>
      <button v-if="selected" type="button" class="clear" aria-label="清除"
              @mousedown.stop.prevent @click.stop.prevent="clear">×</button>
      <i class="el-icon-arrow-down arrow"></i>
    </div>
    <!-- 面板挂到 body，避免被外层 label 的点击转发和弹窗底部挡住。 -->
    <div v-show="open" ref="panel" class="panel" @mousedown.stop>
      <el-input ref="search" v-model="keyword" size="small" clearable prefix-icon="el-icon-search"
                placeholder="搜索名称 / 编码 / 子系统" @input="onType" />
      <div class="tabs" role="tablist">
        <button v-for="t in visibleTabs" :key="t.code" type="button" role="tab"
                :class="{ on: t.code === active }"
                @mousedown.prevent @click="pickTab(t.code)">
          {{ t.label }}<span class="count">{{ t.count }}</span>
        </button>
        <span v-if="!visibleTabs.length" class="empty">这个车型没有可选参数</span>
      </div>
      <div class="list" ref="list">
        <div v-if="loading" class="empty">加载中…</div>
        <div v-else-if="!groups.length" class="empty">没有匹配的参数</div>
        <template v-else>
          <div v-for="g in groups" :key="g.name">
            <div class="head">{{ g.name }} <span>{{ g.items.length }}</span></div>
            <!-- 按下时先拦住默认行为，搜索框失焦不会把这次点击吃掉；松手再选中，面板还在，点击不会穿透到弹窗里。 -->
            <div v-for="p in g.items" :key="p.id" class="item"
                 :class="{ on: selected && selected.id === p.id }"
                 @mousedown.prevent.stop @click.stop="choose(p)">
              <span class="name">
                <span v-if="p.subsystem" class="sub">{{ p.subsystem }}</span>{{ p.paramName }}
              </span>
              <span class="code">{{ p.paramCol }}</span>
              <span v-if="p.unit" class="unit">{{ p.unit }}</span>
              <i v-if="selected && selected.id === p.id" class="el-icon-check mark"></i>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import http from '../../api/http'

/** 页签顺序。DWD 在页面上叫故障实时字段，DIM 叫维表。 */
var SOURCES = [
  { code: 'TCMS', label: 'TCMS' },
  { code: '6A', label: '6A' },
  { code: 'LKJ', label: 'LKJ' },
  { code: 'DWD', label: '故障实时字段' },
  { code: 'DIM', label: '维表' }
]

/**
 * 参数下拉。面板挂在 document.body 上，避免包在 label 里时点击被转发给清空按钮，
 * 也不会被弹窗裁切、被底栏挡住，或把弹窗正文撑出滚动条。
 * 页签按数据源分，点开某个来源会一次载入该车型下这个来源的全部可见参数，再按子系统分组。
 * 一个来源大约几百行，直接渲染，分组标题用真实的 position:sticky，不再做虚拟滚动。
 * 搜索时跨来源匹配，页签数字改成命中数。对外仍回传 paramCol。
 */
export default {
  name: 'ParamSelect',
  props: {
    value: { type: String, default: '' },
    cx: { type: String, default: '' },
    placeholder: { type: String, default: '' }
  },
  data: function () {
    return {
      open: false,
      loading: false,
      keyword: '',
      timer: null,
      active: 'TCMS',
      counts: {},
      cache: {},
      searchRows: null,
      selected: null
    }
  },
  computed: {
    /** 搜索时数字来自本次命中；平时来自 source-counts。0 条的页签不显示。 */
    visibleTabs: function () {
      var counts = this.keyword ? this.countRows(this.searchRows || []) : this.counts
      return SOURCES.map(function (s) {
        return { code: s.code, label: s.label, count: counts[s.code] || 0 }
      }).filter(function (s) { return s.count > 0 })
    },
    shown: function () {
      var rows = this.keyword ? (this.searchRows || []) : (this.cache[this.active] || [])
      var active = this.active
      return rows.filter(function (p) { return (p.dataSource || '') === active })
    },
    groups: function () {
      return this.grouped(this.shown)
    }
  },
  watch: {
    value: function () { this.echo() },
    cx: function () {
      this.cache = {}
      this.searchRows = null
      this.loadCounts()
    },
    open: function (v) {
      if (v) this.$nextTick(this.attach)
      else this.detach()
    },
    visibleTabs: function (tabs) {
      if (!tabs.length) return
      if (!tabs.some(function (t) { return t.code === this.active }, this)) this.active = tabs[0].code
    }
  },
  mounted: function () {
    var self = this
    this._away = function (e) { self.onAway(e) }
    this._place = function () { if (self.open) self.place() }
    document.addEventListener('mousedown', this._away)
    window.addEventListener('resize', this._place)
    window.addEventListener('scroll', this._place, true)
    this.loadCounts()
    this.echo()
  },
  beforeDestroy: function () {
    clearTimeout(this.timer)
    document.removeEventListener('mousedown', this._away)
    window.removeEventListener('resize', this._place)
    window.removeEventListener('scroll', this._place, true)
    this.detach()
  },
  methods: {
    /** 子系统.中文名 · 编码 · 单位。没有子系统就不加点，没有单位就不写单位。 */
    labelOf: function (p) {
      if (!p) return ''
      var head = p.subsystem ? (p.subsystem + '.' + p.paramName) : (p.paramName || '')
      var text = head + ' · ' + (p.paramCol || '')
      if (p.unit) text += ' · ' + p.unit
      return text
    },
    countRows: function (rows) {
      var map = {}
      ;(rows || []).forEach(function (p) { map[p.dataSource] = (map[p.dataSource] || 0) + 1 })
      return map
    },
    /** 未分类放在最后，其余按名称排。 */
    grouped: function (rows) {
      var map = {}
      rows.forEach(function (p) {
        var name = p.subsystem || '未分类'
        if (!map[name]) map[name] = []
        map[name].push(p)
      })
      var names = Object.keys(map).filter(function (n) { return n !== '未分类' }).sort()
      if (map['未分类']) names.push('未分类')
      return names.map(function (n) { return { name: n, items: map[n] } })
    },
    cxParam: function () {
      return this.cx && this.cx !== 'ALL' ? this.cx : ''
    },
    /** 点在触发器或面板里都不算离开。面板已经挂到 body 上，不能只用组件根节点判断。 */
    onAway: function (e) {
      if (!this.open) return
      var panel = this.$refs.panel
      if (this.$el.contains(e.target)) return
      if (panel && panel.contains(e.target)) return
      this.open = false
    },
    toggle: function () {
      this.open = !this.open
      if (!this.open) return
      if (!this.keyword && !this.cache[this.active]) this.loadSource(this.active)
      var self = this
      this.$nextTick(function () {
        var input = self.$refs.search
        if (input && input.focus) input.focus()
      })
    },
    clear: function () {
      this.selected = null
      this.$emit('input', '')
    },
    pickTab: function (code) {
      this.active = code
      if (this.$refs.list) this.$refs.list.scrollTop = 0
      if (!this.keyword && !this.cache[code]) this.loadSource(code)
    },
    onType: function () {
      var self = this
      clearTimeout(this.timer)
      this.timer = setTimeout(function () { self.search() }, 300)
    },
    /** 打开时把面板移到 body，并贴在触发器下面，宽度跟触发器一样。 */
    attach: function () {
      var panel = this.$refs.panel
      if (panel && panel.parentNode !== document.body) document.body.appendChild(panel)
      this.place()
    },
    detach: function () {
      var panel = this.$refs.panel
      if (panel && panel.parentNode === document.body && this.$el) this.$el.appendChild(panel)
    },
    place: function () {
      var trigger = this.$refs.trigger
      var panel = this.$refs.panel
      if (!trigger || !panel || !this.open) return
      var rect = trigger.getBoundingClientRect()
      var width = rect.width
      panel.style.width = width + 'px'
      panel.style.left = Math.max(8, rect.left) + 'px'
      var top = rect.bottom + 4
      var height = panel.offsetHeight || 340
      if (top + height > window.innerHeight - 8 && rect.top > height + 8) top = rect.top - height - 4
      panel.style.top = Math.max(8, top) + 'px'
    },
    loadCounts: function () {
      var self = this
      http.get('/api/params/source-counts', { params: { cx: this.cxParam() } }).then(function (rows) {
        var map = {}
        ;(rows || []).forEach(function (r) { map[r.dataSource] = Number(r.count) || 0 })
        self.counts = map
        var first = SOURCES.filter(function (s) { return map[s.code] })[0]
        if (first && !map[self.active]) self.active = first.code
      }).catch(function () {})
    },
    /** 一个数据源一次取完，缓存在本组件里，来回切页签不再请求。 */
    loadSource: function (code) {
      var self = this
      this.loading = true
      http.get('/api/params/options', { params: { cx: this.cxParam(), dataSource: code } }).then(function (rows) {
        var next = Object.assign({}, self.cache)
        next[code] = rows || []
        self.cache = next
        self.loading = false
        self.$nextTick(self.place)
      }).catch(function () { self.loading = false })
    },
    search: function () {
      var word = (this.keyword || '').trim()
      if (!word) {
        this.searchRows = null
        if (!this.cache[this.active]) this.loadSource(this.active)
        return
      }
      var self = this
      this.loading = true
      http.get('/api/params/options', { params: { cx: this.cxParam(), keyword: word } }).then(function (rows) {
        self.searchRows = rows || []
        self.loading = false
        var counts = self.countRows(self.searchRows)
        if (!counts[self.active]) {
          var first = SOURCES.filter(function (s) { return counts[s.code] })[0]
          if (first) self.active = first.code
        }
        self.$nextTick(self.place)
      }).catch(function () { self.loading = false })
    },
    choose: function (row) {
      this.selected = row
      this.open = false
      this.$emit('input', row.paramCol)
      this.emitFull(row)
    },
    /** 选项接口是轻量行。再取一次完整参数，码表才能驱动枚举目标值。 */
    emitFull: function (row) {
      var self = this
      http.get('/api/params/' + row.id).then(function (full) {
        var merged = Object.assign({}, row, full || {})
        self.selected = merged
        self.$emit('pick', merged)
      }).catch(function () { self.$emit('pick', row) })
    },
    /** 编辑已有规则时，value 只有编码。按编码把这一条找回来，输入框才能显示中文名。 */
    echo: function () {
      var code = this.value
      if (!code) { this.selected = null; return }
      if (this.selected && this.selected.paramCol === code) return
      var self = this
      http.get('/api/params/options', { params: { cx: this.cxParam(), keyword: code } }).then(function (rows) {
        var hit = (rows || []).filter(function (p) { return p.paramCol === code })[0]
        if (!hit) return
        self.selected = hit
        self.emitFull(hit)
      }).catch(function () {})
    }
  }
}
</script>

<style scoped>
.param-select { position: relative; width: 100%; }
.box {
  display: flex; align-items: center; gap: 6px; height: 40px; box-sizing: border-box;
  border: 1px solid #cfd8e4; border-radius: 6px; background: #fff;
  padding: 0 10px; cursor: pointer; font-size: 14px;
}
.box.open { border-color: #2563eb; }
.text { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #1e293b; }
.placeholder { flex: 1; color: #c0c4cc; }
.clear { border: 0; background: transparent; color: #94a3b8; padding: 0 2px; cursor: pointer; font-size: 14px; }
.arrow { color: #c0c4cc; font-size: 12px; }
.panel {
  position: fixed; z-index: 5000; box-sizing: border-box;
  background: #fff; border: 1px solid #e2e8f0; border-radius: 8px;
  box-shadow: 0 8px 24px #0f172a22; padding: 8px 8px 4px; max-height: 340px;
  display: flex; flex-direction: column;
}
.tabs { display: flex; gap: 14px; border-bottom: 1px solid #e2e8f0; margin: 8px 0 0; flex: none; overflow-x: auto; }
.tabs button {
  border: 0; background: none; border-radius: 0; padding: 8px 0;
  border-bottom: 2px solid transparent; color: #64748b; font-size: 13px; cursor: pointer; white-space: nowrap;
}
.tabs button.on { color: #2563eb; border-bottom-color: #2563eb; font-weight: 600; }
.count { margin-left: 4px; font-size: 11px; line-height: 16px; padding: 0 5px; border-radius: 8px; background: #f1f5f9; color: #64748b; font-weight: 500; }
.tabs button.on .count { background: #eff6ff; color: #2563eb; }
.list { flex: 1; min-height: 120px; max-height: 250px; overflow: auto; margin-top: 4px; }
.head {
  position: sticky; top: 0; z-index: 1;
  background: #f8fafc; color: #64748b; font-size: 12px; font-weight: 600;
  padding: 6px 8px; border-bottom: 1px solid #eef2f6;
}
.head span { margin-left: 4px; font-weight: 500; }
.item {
  display: flex; align-items: center; gap: 8px; min-height: 34px;
  padding: 4px 8px; cursor: pointer; font-size: 13px;
}
.item:hover { background: #f8fafc; }
.item.on { color: #2563eb; background: #eff6ff; }
.name { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #1e293b; }
.item.on .name { color: #2563eb; }
.sub { color: #94a3b8; margin-right: 4px; }
.code { font-family: Consolas, monospace; font-size: 12px; color: #94a3b8; }
.unit { font-size: 11px; color: #64748b; background: #f1f5f9; border-radius: 4px; padding: 0 5px; line-height: 18px; }
.mark { color: #2563eb; font-size: 14px; }
.empty { color: #94a3b8; font-size: 12px; padding: 12px 4px; }
</style>
