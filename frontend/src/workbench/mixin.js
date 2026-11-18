import http from '../api/http'
import { ladderSvg } from '../utils/ladder'

var MODES = [
  { value: 'CONDITIONAL', label: '条件组合判定' },
  { value: 'DIRECT', label: '直接报出' },
  { value: 'DISABLED', label: '停用过滤' },
  { value: 'PENDING', label: '待配置规则' }
]

/**
 * 工作台的数据加载、保存和预览。模板拆到各栏组件之后，业务仍集中在这里，避免和接口各写一份。
 */
export default {
  data: function () {
    return {
      stats: null, faults: [], atoms: [], groups: [], params: [], pres: [],
      filters: { cx: '', mode: '', ly: '', cz: '', q: '' },
      draft: null, saved: '', preview: null, timer: null,
      viz: 'list', tab: 'cn', namedOpen: {}, bigOpen: false,
      checkText: '', checkResult: null,
      simValues: {}, simWindowsState: {}, simResult: null,
      poolKind: 'atom', poolScope: 'FIT', poolType: '', poolQ: '',
      preOpen: false, preForm: null,
      atomDlg: null, groupDlg: null, groupPreview: null,
      faultDlg: false, newFault: { cx: 'HXD1C', ly: 'TCMS', gzdm: '', gzmc: '', mxmc: '', jkdj: 'D' },
      library: false, libraryQ: '', refDlg: false, refInfo: null,
      /** 原子 / 命名组的引用统计，键是 a12、g3。打开页面后后台补齐，不挡首屏。 */
      usage: {},
      modeOptions: MODES,
      ops: ['==', '!=', '>', '>=', '<', '<=', 'IN', 'NOT IN', '=~'],
      winFns: ['allNotExists', 'anyExists', 'allExists', 'anyNotExists']
    }
  },
  computed: {
    cxOptions: function () {
      var s = {}
      this.faults.forEach(function (f) { s[f.cx] = 1 })
      return Object.keys(s)
    },
    filtered: function () {
      var f = this.filters
      var q = (f.q || '').toLowerCase()
      return this.faults.filter(function (row) {
        if (f.cx && row.cx !== f.cx) return false
        if (f.mode && row.ruleMode !== f.mode) return false
        if (f.ly && row.ly !== f.ly) return false
        if (f.cz && row.czdj !== f.cz) return false
        if (q && (row.gzdm + row.gzmc + (row.mxmc || '')).toLowerCase().indexOf(q) < 0) return false
        return true
      })
    },
    dirty: function () { return this.draft && JSON.stringify(this.snapshot()) !== this.saved },
    enabledPre: function () { return this.pres.filter(function (p) { return p.isEnabled === 1 }).length },
    ladderHtml: function () {
      return this.preview && this.preview.display ? ladderSvg(this.preview.display, this.namedOpen, this.draft && this.draft.gzdm) : ''
    },
    usedCodes: function () {
      return (this.draft && this.draft.refs || []).map(function (r) { return r.code })
    },
    poolAtoms: function () {
      var q = (this.poolQ || '').toLowerCase()
      var cx = this.draft ? this.draft.cx : ''
      var fit = this.poolScope === 'FIT'
      var type = this.poolType
      return this.atoms.filter(function (a) {
        if (type && a.atomType !== type) return false
        if (fit && cx && a.scopeCx !== 'ALL' && a.scopeCx.split(',').map(function (s) { return s.trim() }).indexOf(cx) < 0) return false
        if (!q) return true
        return (a.atomCode + a.atomName + (a.atomExpr || '')).toLowerCase().indexOf(q) >= 0
      })
    },
    poolGroups: function () {
      var q = (this.poolQ || '').toLowerCase()
      return this.groups.filter(function (g) {
        return !q || (g.groupCode + g.groupName + (g.groupExpr || '')).toLowerCase().indexOf(q) >= 0
      })
    },
    libraryRows: function () {
      var q = (this.libraryQ || '').toLowerCase()
      return this.atoms.filter(function (a) {
        return !q || (a.atomCode + a.atomName + (a.atomExpr || '')).toLowerCase().indexOf(q) >= 0
      })
    },
    libraryGroups: function () {
      var q = (this.libraryQ || '').toLowerCase()
      return this.groups.filter(function (g) {
        return !q || (g.groupCode + g.groupName + (g.groupExpr || '')).toLowerCase().indexOf(q) >= 0
      })
    },
    simFields: function () {
      var text = (this.preview && this.preview.faultRule) || ''
      this.liveInherited.forEach(function (p) { text += ' ' + (p.filterExpr || '') })
      var known = {}
      this.params.forEach(function (p) { known[p.paramCol] = 1 })
      var set = {}
      var re = /(^|[^A-Za-z0-9_])([A-Z][A-Z0-9_]*)(?![A-Za-z0-9_])/g
      var m
      while ((m = re.exec(text))) { if (known[m[2]]) set[m[2]] = 1 }
      return Object.keys(set)
    },
    simParams: function () {
      var self = this
      return this.simFields.map(function (code) {
        var p = self.params.filter(function (x) { return x.paramCol === code })[0]
        var enums = []
        String((p && p.enumDict) || '').split(';').forEach(function (part) {
          var i = part.indexOf(':')
          if (i > 0) enums.push({ value: part.slice(0, i).trim(), label: part.slice(i + 1).trim() })
        })
        return { code: code, name: (p && p.paramName) || code, unit: (p && p.unit) || '', source: (p && p.dataSource) || '', enums: enums }
      })
    },
    simWindows: function () {
      var out = []
      var self = this
      ;(this.draft && this.draft.refs || []).forEach(function (r) {
        if (r.refType !== 'ATOM') return
        var atom = self.atoms.filter(function (a) { return a.atomCode === r.code })[0]
        if (atom && atom.atomType === 'WINDOW') {
          String(atom.relGzdm || '').split(',').forEach(function (c) {
            if (c.trim()) out.push({ key: atom.atomCode + ':' + c.trim(), code: c.trim(), fn: atom.winFn, sec: atom.winSec })
          })
        }
      })
      return out
    },
    applicablePres: function () {
      var d = this.draft
      if (!d) return []
      return this.pres.filter(function (p) {
        if (p.isEnabled !== 1) return false
        var cx = String(p.scopeCx || 'ALL').split(',').map(function (s) { return s.trim() })
        return (cx.indexOf('ALL') >= 0 || cx.indexOf(d.cx) >= 0) && (!p.scopeLy || p.scopeLy === 'ALL' || p.scopeLy === d.ly)
      })
    },
    liveInherited: function () {
      var ids = (this.draft && this.draft.skipFilterIds) || []
      return this.applicablePres.filter(function (p) { return ids.indexOf(p.id) < 0 })
    },
    preFormVisible: {
      get: function () { return !!this.preForm },
      set: function (v) { if (!v) this.preForm = null }
    },
    atomVisible: {
      get: function () { return !!this.atomDlg },
      set: function (v) { if (!v) this.atomDlg = null }
    },
    groupVisible: {
      get: function () { return !!this.groupDlg },
      set: function (v) { if (!v) this.groupDlg = null }
    }
  },
  watch: {
    'draft.ruleExpr': function () { this.queuePreview() },
    'draft.refs': { deep: true, handler: function () { this.queuePreview() } },
    groupDlg: function (v) {
      if (!v) { this.groupPreview = null; return }
      this.previewGroup()
    }
  },
  mounted: function () {
    var self = this
    this._onKey = function (e) { self.onKey(e) }
    window.addEventListener('keydown', this._onKey)
    this.boot()
  },
  beforeDestroy: function () {
    window.removeEventListener('keydown', this._onKey)
  },
  methods: {
    boot: function () {
      var self = this
      return Promise.all([
        http.get('/api/stats'), http.get('/api/faults'), http.get('/api/atoms'),
        http.get('/api/groups'), http.get('/api/params', { params: { pageSize: 500 } }), http.get('/api/pre-filters')
      ]).then(function (all) {
        self.stats = all[0]
        self.faults = all[1]
        self.atoms = all[2]
        self.groups = all[3]
        self.params = all[4].records || []
        self.pres = all[5]
        if (!self.draft && self.faults.length) {
          var prefer = self.faults.filter(function (f) { return f.gzdm === '1873' && f.cx === 'HXD1C' })[0] || self.faults[0]
          self.pick(prefer, true)
        }
      }).catch(this.fail)
    },
    pick: function (row, force) {
      var self = this
      if (!force && this.dirty) {
        this.$confirm('当前故障有未保存修改，切换将放弃这些修改。继续？', '未保存', { type: 'warning' }).then(function () {
          self.load(row.id)
        }).catch(function () {})
        return
      }
      this.load(row.id)
    },
    load: function (id) {
      var self = this
      http.get('/api/faults/' + id).then(function (d) {
        d.skipFilterIds = (d.skips || []).map(function (s) { return s.filterId })
        d.refs = d.refs || []
        self.draft = d
        self.saved = JSON.stringify(self.snapshot())
        self.simResult = null
        self.queuePreview()
        self.loadUsage()
        self.$nextTick(function () {
          var el = document.querySelector('.fault.selected')
          if (el && el.scrollIntoView) el.scrollIntoView({ block: 'nearest' })
        })
      }).catch(this.fail)
    },
    snapshot: function () {
      var d = this.draft
      return {
        ruleMode: d.ruleMode, czdj: d.czdj, jkdj: d.jkdj, mxmc: d.mxmc || '',
        ruleExpr: d.ruleExpr || '', configNote: d.configNote || '',
        refs: (d.refs || []).map(function (r) { return r.refType + ':' + r.code }),
        skips: (d.skipFilterIds || []).slice().sort()
      }
    },
    queuePreview: function () {
      var self = this
      clearTimeout(this.timer)
      this.timer = setTimeout(function () { self.runPreview() }, 250)
    },
    runPreview: function () {
      if (!this.draft || !this.draft.ruleExpr) { this.preview = null; return }
      var self = this
      http.post('/api/expr/preview', {
        gzdm: this.draft.gzdm, ruleExpr: this.draft.ruleExpr,
        refs: (this.draft.refs || []).map(function (r) { return { refType: r.refType, code: r.code } })
      }).then(function (r) { self.preview = r }).catch(function (e) {
        self.preview = { ok: false, message: e.message, pos: 0 }
      })
    },
    save: function () {
      var self = this
      var d = this.draft
      if (!d) return
      http.put('/api/faults/' + d.id, {
        rev: d.rev, ruleMode: d.ruleMode, czdj: d.czdj, jkdj: d.jkdj, mxmc: d.mxmc,
        ruleExpr: d.ruleExpr, configNote: d.configNote,
        refs: (d.refs || []).map(function (r) { return { refType: r.refType, code: r.code } }),
        skipFilterIds: d.skipFilterIds || []
      }).then(function () {
        self.$message.success('故障 ' + d.gzdm + ' 规则已保存')
        return self.boot().then(function () { return self.load(d.id) })
      }).catch(this.fail)
    },
    reset: function () { if (this.draft) this.load(this.draft.id) },
    toggleNamed: function (code) {
      if (!code) return
      var next = Object.assign({}, this.namedOpen)
      next[code] = next[code] === false
      this.namedOpen = next
    },
    setNamed: function (open) {
      var next = {}
      var walk = function (n) {
        if (!n) return
        if (n.type === 'named' && n.code) next[n.code] = open
        ;(n.children || []).forEach(walk)
        walk(n.child)
      }
      if (this.preview && this.preview.display) walk(this.preview.display)
      this.namedOpen = next
    },
    insert: function (token) { this.draft.ruleExpr = (this.draft.ruleExpr || '') + token },
    allAnd: function () { this.draft.ruleExpr = (this.draft.refs || []).map(function (r) { return r.alias }).join(' & ') },
    allOr: function () { this.draft.ruleExpr = (this.draft.refs || []).map(function (r) { return r.alias }).join(' | ') },
    used: function (code) { return this.usedCodes.indexOf(code) >= 0 },
    useAtom: function (a) { this.pushRef('ATOM', a.atomCode, a.atomName, a.atomExpr, a.scopeCx) },
    useGroup: function (g) { this.pushRef('GROUP', g.groupCode, g.groupName, g.expandExpr, g.scopeCx) },
    pushRef: function (type, code, name, expr, scope) {
      if (!this.draft || this.used(code)) return
      var n = this.draft.refs.length + 1
      this.draft.refs.push({ alias: 'A' + n, seqNo: n, refType: type, code: code, name: name, expr: expr, scopeCx: scope })
    },
    removeRef: function (r) {
      this.draft.refs = this.draft.refs.filter(function (x) { return x !== r })
      this.draft.refs.forEach(function (x, i) { x.seqNo = i + 1; x.alias = 'A' + (i + 1) })
    },
    editRef: function (r) {
      if (r.refType === 'GROUP') {
        var g = this.groups.filter(function (x) { return x.groupCode === r.code })[0]
        if (g) this.groupDlg = this.editGroup(g)
      } else {
        var a = this.atoms.filter(function (x) { return x.atomCode === r.code })[0]
        if (a) this.atomDlg = this.editAtom(a)
      }
    },
    toggleSkip: function (id) {
      var ids = ((this.draft && this.draft.skipFilterIds) || []).slice()
      var i = ids.indexOf(id)
      if (i >= 0) ids.splice(i, 1)
      else ids.push(id)
      this.draft.skipFilterIds = ids
    },
    runCheck: function () {
      var self = this
      http.post('/api/expr/check', { text: this.checkText, expect: this.preview && this.preview.faultRule }).then(function (r) {
        self.checkResult = r
      }).catch(function (e) { self.checkResult = { ok: false, message: e.message, pos: 0 } })
    },
    runSim: function () {
      var self = this
      http.post('/api/faults/' + this.draft.id + '/simulate', { values: this.simValues, windows: this.simWindowsState }).then(function (r) {
        self.simResult = r
      }).catch(this.fail)
    },
    fill: function (want) {
      var self = this
      http.post('/api/faults/' + this.draft.id + '/sim-sample?wantHit=' + want, {}).then(function (r) {
        self.simValues = Object.assign({}, r.values || {})
        self.simWindowsState = Object.assign({}, r.windows || {})
        self.simResult = r
      }).catch(this.fail)
    },
    freshAtom: function () {
      return { atomType: 'PARAM', scopeCx: 'ALL', paramCol: '', cmpOp: '>=', cmpVal: '', winFn: 'allNotExists', winSec: 10, relGzdm: '', atomName: '' }
    },
    editAtom: function (a) {
      return { id: a.id, rev: a.rev, atomType: a.atomType, scopeCx: a.scopeCx, paramCol: a.paramCol, cmpOp: a.cmpOp, cmpVal: a.cmpVal, winFn: a.winFn, winSec: a.winSec, relGzdm: a.relGzdm, atomName: a.atomName }
    },
    saveAtom: function () {
      var self = this
      var req = this.atomDlg
      var call = req.id ? http.put('/api/atoms/' + req.id, req) : http.post('/api/atoms', req)
      call.then(function (a) {
        self.$message.success(req.id ? '共享原子已更新，所有引用方同步生效' : '已保存 ' + a.atomCode)
        self.atomDlg = null
        if (!req.id && self.draft) self.pushRef('ATOM', a.atomCode, a.atomName, a.atomExpr, a.scopeCx)
        return self.boot()
      }).catch(this.fail)
    },
    removeAtom: function (row) {
      var self = this
      http.delete('/api/atoms/' + row.id).then(function () { return self.boot() }).catch(this.fail)
    },
    freshGroup: function () { return { groupName: '', scopeCx: 'ALL', groupExpr: '' } },
    editGroup: function (g) { return { id: g.id, rev: g.rev, groupName: g.groupName, scopeCx: g.scopeCx, groupExpr: g.groupExpr } },
    previewGroup: function () {
      var self = this
      if (!this.groupDlg) return
      http.post('/api/groups/preview', { groupExpr: this.groupDlg.groupExpr }).then(function (r) { self.groupPreview = r }).catch(function (e) {
        self.groupPreview = { ok: false, message: e.message }
      })
    },
    saveGroup: function () {
      var self = this
      var req = this.groupDlg
      var call = req.id ? http.put('/api/groups/' + req.id, req) : http.post('/api/groups', req)
      call.then(function () {
        self.$message.success('命名组已保存')
        self.groupDlg = null
        return self.boot()
      }).catch(this.fail)
    },
    freshPre: function () {
      return { filterName: '', paramCol: '', cmpOp: '==', cmpVal: '', scopeCx: 'ALL', scopeLy: 'ALL', execTiming: 'BEFORE_HBASE', priority: 100 }
    },
    editPre: function (p) {
      return { id: p.id, rev: p.rev, filterName: p.filterName, paramCol: p.paramCol, cmpOp: p.cmpOp, cmpVal: p.cmpVal, scopeCx: p.scopeCx, scopeLy: p.scopeLy, execTiming: p.execTiming, priority: p.priority }
    },
    savePre: function () {
      var self = this
      var req = this.preForm
      var call = req.id ? http.put('/api/pre-filters/' + req.id, req) : http.post('/api/pre-filters', req)
      call.then(function () { self.preForm = null; return self.boot() }).catch(this.fail)
    },
    togglePre: function (p, on) {
      var self = this
      http.put('/api/pre-filters/' + p.id + '/enabled', { rev: p.rev, enabled: on }).then(function () { return self.boot() }).catch(this.fail)
    },
    removePre: function (p) {
      var self = this
      this.$confirm('删除前置规则「' + p.filterName + '」？', '确认').then(function () {
        return http.delete('/api/pre-filters/' + p.id).then(function () { return self.boot() })
      }).catch(function () {})
    },
    createFault: function () {
      var self = this
      http.post('/api/faults', this.newFault).then(function (d) {
        self.faultDlg = false
        self.newFault.gzdm = ''
        self.newFault.gzmc = ''
        return self.boot().then(function () { self.load(d.id) })
      }).catch(this.fail)
    },
    /**
     * 逐条问现有引用接口，凑出「被 N 个故障引用」。没有批量接口，前端自己汇总，不改后端。
     */
    loadUsage: function () {
      if (this.usageStarted) return
      this.usageStarted = true
      var self = this
      this.atoms.forEach(function (a) {
        http.get('/api/atoms/' + a.id + '/references').then(function (r) {
          self.$set(self.usage, 'a' + a.id, r)
        }).catch(function () {})
      })
      this.groups.forEach(function (g) {
        http.get('/api/groups/' + g.id + '/references').then(function (r) {
          self.$set(self.usage, 'g' + g.id, r)
        }).catch(function () {})
      })
    },
    usageText: function (kind, id) {
      var r = this.usage[(kind === 'atom' ? 'a' : 'g') + id]
      if (!r) return '统计引用中'
      var n = (r.faults && r.faults.length) || 0
      var text = '被 ' + n + ' 个故障引用'
      if (kind === 'atom' && r.inGroups) text += ' · ' + r.inGroups + ' 个命名组使用'
      return text + ' ↗'
    },
    showRef: function (kind, id) {
      var self = this
      http.get('/api/' + (kind === 'atom' ? 'atoms' : 'groups') + '/' + id + '/references').then(function (r) {
        self.refInfo = r
        self.refDlg = true
      }).catch(this.fail)
    },
    gotoFault: function (f) {
      this.refDlg = false
      var row = this.faults.filter(function (x) { return x.id === f.id })[0]
      if (row) this.pick(row)
    },
    openFlow: function (id) { this.$store.commit('openFlow', id || (this.draft && this.draft.id)) },
    reloadAfterFlow: function () {
      this.$store.commit('closeFlow')
      var id = this.draft && this.draft.id
      var self = this
      this.boot().then(function () { if (id) self.load(id) })
    },
    onKey: function (e) {
      if ((e.ctrlKey || e.metaKey) && (e.key === 's' || e.key === 'S')) { e.preventDefault(); this.save() }
    },
    fail: function (e) { if (e && e.message) this.$message.error(e.message) }
  }
}
