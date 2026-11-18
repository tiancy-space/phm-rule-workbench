<template>
  <el-select :value="currentId" filterable remote reserve-keyword clearable
             :remote-method="onType" :loading="loading" :placeholder="placeholder || '按中文名 / 编码 / 子系统搜索'"
             style="width:100%" @change="onChange" @visible-change="onOpen">
    <el-option-group v-for="g in groups" :key="g.code" :label="g.label">
      <el-option v-for="p in g.items" :key="p.id" :label="labelOf(p)" :value="p.id" />
    </el-option-group>
  </el-select>
</template>

<script>
import http from '../../api/http'

/** 页面上的分组名。DWD 不显示英文码，叫故障实时字段。 */
var GROUPS = [
  { code: 'TCMS', label: 'TCMS' },
  { code: '6A', label: '6A' },
  { code: 'LKJ', label: 'LKJ' },
  { code: 'DWD', label: '故障实时字段' },
  { code: 'DIM', label: '维表' }
]
/** 未迁移库里的旧数据源，归到新分组里，避免下拉空白。 */
var LEGACY = {
  HBASE: 'TCMS', HBASE_PHM: 'TCMS', HBASE_6A: '6A', HBASE_LKJ: 'LKJ', KAFKA: 'DWD'
}

/**
 * 参数下拉。按车型远程搜索，用子系统、中文名、编码和单位区分同名测点。
 * 对外仍回传 paramCol，和原子、前置、数据卡现有字段一致。
 */
export default {
  name: 'ParamSelect',
  props: {
    value: { type: String, default: '' },
    cx: { type: String, default: '' },
    placeholder: { type: String, default: '' }
  },
  data: function () {
    return { loading: false, rows: [], timer: null, currentId: null }
  },
  computed: {
    groups: function () {
      var buckets = {}
      GROUPS.forEach(function (g) { buckets[g.code] = [] })
      this.rows.forEach(function (p) {
        var code = LEGACY[p.dataSource] || p.dataSource
        if (!buckets[code]) buckets[code] = []
        buckets[code].push(p)
      })
      return GROUPS.map(function (g) {
        return { code: g.code, label: g.label, items: buckets[g.code] || [] }
      }).filter(function (g) { return g.items.length })
    }
  },
  watch: {
    value: function () { this.ensureSelected() },
    cx: function () { this.fetch('') }
  },
  mounted: function () { this.fetch('') },
  beforeDestroy: function () { clearTimeout(this.timer) },
  methods: {
    /** 子系统.中文名 · 编码 · 单位。没有子系统或单位时把对应一段省掉。 */
    labelOf: function (p) {
      var head = p.subsystem ? (p.subsystem + '.' + p.paramName) : p.paramName
      var tail = p.paramCol + (p.unit ? ' · ' + p.unit : '')
      return head + ' · ' + tail
    },
    onOpen: function (open) {
      if (open && !this.rows.length) this.fetch('')
    },
    onType: function (word) {
      var self = this
      clearTimeout(this.timer)
      this.timer = setTimeout(function () { self.fetch(word) }, 300)
    },
    fetch: function (word) {
      var self = this
      this.loading = true
      var params = { keyword: word || '', pageNum: 1, pageSize: 50 }
      if (this.cx && this.cx !== 'ALL') params.cx = this.cx
      http.get('/api/params', { params: params }).then(function (page) {
        self.rows = (page && page.records) || []
        self.loading = false
        self.ensureSelected()
      }).catch(function () { self.loading = false })
    },
    /** 已选编码不在当前页时，按编码再查一次，保证输入框能显示出中文名。 */
    ensureSelected: function () {
      var code = this.value
      if (!code) { this.currentId = null; return }
      var hit = this.rows.filter(function (p) { return p.paramCol === code })[0]
      if (hit) { this.currentId = hit.id; return }
      var self = this
      var params = { keyword: code, pageNum: 1, pageSize: 20 }
      if (this.cx && this.cx !== 'ALL') params.cx = this.cx
      http.get('/api/params', { params: params }).then(function (page) {
        var extra = ((page && page.records) || []).filter(function (p) { return p.paramCol === code })[0]
        if (!extra) return
        if (!self.rows.some(function (p) { return p.id === extra.id })) self.rows = [extra].concat(self.rows)
        self.currentId = extra.id
        self.$emit('pick', extra)
      }).catch(function () {})
    },
    onChange: function (id) {
      var row = this.rows.filter(function (p) { return p.id === id })[0]
      this.currentId = id || null
      this.$emit('input', row ? row.paramCol : '')
      if (row) this.$emit('pick', row)
    }
  }
}
</script>
