<template>
  <div class="param-select" v-click-away="close">
    <div class="box" :class="{ open: open }" @click="toggle">
      <span v-if="selected" class="text">{{ labelOf(selected) }}</span>
      <span v-else class="placeholder">{{ placeholder || '按中文名 / 编码 / 子系统搜索' }}</span>
      <button v-if="selected" type="button" class="clear" @click.stop="clear">×</button>
      <i class="el-icon-arrow-down arrow"></i>
    </div>
    <div v-show="open" class="panel">
      <el-input ref="search" v-model="keyword" size="small" clearable prefix-icon="el-icon-search"
                placeholder="搜索名称 / 编码 / 子系统" @input="onType" />
      <div class="tabs">
        <button v-for="t in visibleTabs" :key="t.code" type="button"
                :class="{ on: t.code === active }" @click="pickTab(t.code)">
          {{ t.label }} <b>{{ t.count }}</b>
        </button>
        <span v-if="!visibleTabs.length" class="empty">这个车型没有可选参数</span>
      </div>
      <div class="list" ref="list" @scroll="onScroll">
        <div v-if="loading" class="empty">加载中…</div>
        <div v-else-if="!lines.length" class="empty">没有匹配的参数</div>
        <div v-else class="track" :style="{ height: totalHeight + 'px' }">
          <div v-for="row in windowRows" :key="row.key" class="line" :class="row.kind"
               :style="{ top: row.top + 'px', height: row.h + 'px' }"
               @click="row.item && choose(row.item)">
            {{ row.text }}
          </div>
        </div>
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
var HEAD = 26
var ITEM = 32

/**
 * 参数下拉。页签按数据源分，点开某个来源会一次载入该车型下这个来源的全部可见参数，
 * 再按子系统分组。搜索时跨来源匹配，页签上的数字改成命中数。
 * 对外仍回传 paramCol，已保存的原子打开时按编码把中文名回显出来。
 */
export default {
  name: 'ParamSelect',
  directives: {
    /** 点到组件外面就收起，不依赖 Element 下拉的点击外部。 */
    clickAway: {
      bind: function (el, binding) {
        el._away = function (e) { if (!el.contains(e.target)) binding.value() }
        document.addEventListener('mousedown', el._away)
      },
      unbind: function (el) { document.removeEventListener('mousedown', el._away) }
    }
  },
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
      selected: null,
      scrollTop: 0
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
    lines: function () {
      var lines = []
      var y = 0
      this.grouped(this.shown).forEach(function (g) {
        lines.push({ kind: 'head', text: g.name, item: null, top: y, h: HEAD, key: 'h-' + g.name })
        y += HEAD
        g.items.forEach(function (p) {
          lines.push({ kind: 'item', text: '', item: p, top: y, h: ITEM, key: 'i-' + p.id })
          y += ITEM
        })
      })
      return lines
    },
    totalHeight: function () {
      var last = this.lines[this.lines.length - 1]
      return last ? last.top + last.h : 0
    },
    windowRows: function () {
      var top = this.scrollTop
      var bottom = top + 320
      var self = this
      return this.lines.filter(function (row) {
        return row.top + row.h >= top && row.top <= bottom
      }).map(function (row) {
        return { kind: row.kind, text: row.item ? self.labelOf(row.item) : row.text, item: row.item, top: row.top, h: row.h, key: row.key }
      })
    }
  },
  watch: {
    value: function () { this.echo() },
    cx: function () {
      this.cache = {}
      this.searchRows = null
      this.loadCounts()
    },
    visibleTabs: function (tabs) {
      if (!tabs.length) return
      if (!tabs.some(function (t) { return t.code === this.active }, this)) this.active = tabs[0].code
    }
  },
  mounted: function () {
    this.loadCounts()
    this.echo()
  },
  beforeDestroy: function () { clearTimeout(this.timer) },
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
    toggle: function () {
      this.open = !this.open
      if (this.open) {
        this.scrollTop = 0
        if (!this.keyword && !this.cache[this.active]) this.loadSource(this.active)
        var self = this
        this.$nextTick(function () {
          var input = self.$refs.search
          if (input && input.focus) input.focus()
        })
      }
    },
    close: function () { this.open = false },
    clear: function () {
      this.selected = null
      this.$emit('input', '')
    },
    pickTab: function (code) {
      this.active = code
      this.scrollTop = 0
      if (this.$refs.list) this.$refs.list.scrollTop = 0
      if (!this.keyword && !this.cache[code]) this.loadSource(code)
    },
    onScroll: function (e) { this.scrollTop = e.target.scrollTop },
    onType: function () {
      var self = this
      clearTimeout(this.timer)
      this.timer = setTimeout(function () { self.search() }, 300)
    },
    loadCounts: function () {
      var self = this
      http.get('/api/params/source-counts', { params: { cx: this.cxParam() } }).then(function (rows) {
        var map = {}
        ;(rows || []).forEach(function (r) { map[r.dataSource] = r.count })
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
      }).catch(function () { self.loading = false })
    },
    search: function () {
      var word = (this.keyword || '').trim()
      if (!word) { this.searchRows = null; return }
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
      }).catch(function () { self.loading = false })
    },
    choose: function (row) {
      this.selected = row
      this.open = false
      this.$emit('input', row.paramCol)
      this.$emit('pick', row)
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
        self.$emit('pick', hit)
      }).catch(function () {})
    }
  }
}
</script>

<style scoped>
.param-select { position: relative; width: 100%; }
.box {
  display: flex; align-items: center; gap: 6px; min-height: 32px;
  border: 1px solid #cfd8e4; border-radius: 6px; background: #fff;
  padding: 4px 8px; cursor: pointer;
}
.box.open { border-color: #2563eb; box-shadow: 0 0 0 2px #bfdbfe; }
.text { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #1e293b; }
.placeholder { flex: 1; color: #94a3b8; }
.clear { border: 0; background: transparent; color: #94a3b8; padding: 0 2px; cursor: pointer; }
.arrow { color: #94a3b8; font-size: 12px; }
.panel {
  position: absolute; z-index: 30; left: 0; right: 0; top: calc(100% + 4px);
  background: #fff; border: 1px solid #e2e8f0; border-radius: 8px;
  box-shadow: 0 8px 24px #0f172a22; padding: 8px;
}
.tabs { display: flex; flex-wrap: wrap; gap: 4px; margin: 8px 0; }
.tabs button {
  border: 1px solid #e2e8f0; background: #f8fafc; border-radius: 6px;
  padding: 3px 8px; font-size: 12px; cursor: pointer; color: #475569;
}
.tabs button.on { background: #eff6ff; border-color: #2563eb; color: #1d4ed8; font-weight: 600; }
.tabs b { font-weight: 600; margin-left: 2px; }
.list { height: 280px; overflow: auto; position: relative; }
.track { position: relative; }
.line { position: absolute; left: 0; right: 0; display: flex; align-items: center; padding: 0 8px; box-sizing: border-box; }
.line.item { cursor: pointer; font-size: 12px; color: #1e293b; }
.line.item:hover { background: #eff6ff; }
.line.head { font-size: 12px; font-weight: 600; color: #64748b; background: #f8fafc; }
.empty { color: #94a3b8; font-size: 12px; padding: 12px 4px; }
</style>
