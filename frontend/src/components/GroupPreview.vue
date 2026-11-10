<template>
  <div v-if="preview">
    <div v-if="preview.ok" class="ok">✓ 组合式有效 · {{ kindText }} · {{ atomCount }} 个原子 · 规范写法 <span class="mono">{{ preview.canonicalExpr }}</span></div>
    <div v-else class="bad">第 {{ (preview.pos || 0) + 1 }} 字符：{{ preview.message }}</div>
    <template v-if="preview.ok && preview.display">
      <div class="muted">展开表达式（入库内容，实时预览）</div>
      <pre class="pre">{{ preview.faultRule }}</pre>
      <div class="muted">现场说法预览</div>
      <div class="checklist">
        <details class="named" open>
          <summary>
            <span class="gicon">◆</span>
            <b>{{ name || '（未命名组）' }}</b>
            <span class="kind">（{{ kindText }}）</span>
          </summary>
          <div class="sublist">
            <div v-for="(c, i) in children" :key="i">
              <div v-if="i" class="pillrow"><span class="pill" :class="joiner === '或' ? 'or' : 'and'">{{ joiner }}</span></div>
              <div class="subitem">{{ line(c) }}</div>
            </div>
          </div>
        </details>
      </div>
    </template>
  </div>
</template>

<script>
/**
 * 命名组编辑弹窗里的实时分组清单。结构跟原型现场说法一致：组名、且/或药丸、叶子中文。
 */
export default {
  name: 'GroupPreview',
  props: {
    preview: { type: Object, default: null },
    name: { type: String, default: '' }
  },
  computed: {
    root: function () { return this.preview && this.preview.display },
    children: function () {
      var n = this.root
      if (!n) return []
      if (n.type === 'and' || n.type === 'or') return n.children || []
      return [n]
    },
    joiner: function () {
      return this.root && this.root.type === 'or' ? '或' : '且'
    },
    kindText: function () {
      var n = this.root
      if (!n) return '表达式有误'
      if (n.type === 'or') return '满足其一'
      if (n.type === 'and') return '同时满足'
      return '单项条件'
    },
    atomCount: function () {
      var ids = {}
      var walk = function (n) {
        if (!n) return
        if (n.type === 'leaf' && n.code) ids[n.code] = 1
        ;(n.children || []).forEach(walk)
        if (n.child) walk(n.child)
      }
      walk(this.root)
      return Object.keys(ids).length
    }
  },
  methods: {
    line: function (n) {
      if (!n) return ''
      if (n.type === 'leaf') return n.text || n.code || ''
      if (n.type === 'named') return n.name || n.code || ''
      return this.inline(n, true)
    },
    /** 嵌套的且/或收成一行，外层加括号，和原型 inlineText 一样。 */
    inline: function (n, top) {
      if (!n) return ''
      if (n.type === 'leaf') return n.text || ''
      if (n.type === 'named') return n.name || ''
      var sep = n.type === 'or' ? ' 或 ' : ' 且 '
      var self = this
      var s = (n.children || []).map(function (c) { return self.inline(c, false) }).join(sep)
      return top ? s : '（' + s + '）'
    }
  }
}
</script>

<style scoped>
.checklist { border:1px solid #e2e8f0; border-radius:7px; background:#fff; padding:8px 10px; margin-top:4px; }
.named { border:1px dashed #c4b5fd; background:#faf8ff; border-radius:6px; padding:4px 10px 8px; }
.named summary { cursor:pointer; list-style:none; display:flex; align-items:center; gap:4px; flex-wrap:wrap; }
.gicon { color:#7c3aed; }
.kind { color:#64748b; }
.sublist { margin:6px 0 0; border-left:2px solid #e2e8f0; padding-left:10px; }
.subitem { background:#f8fafc; border:1px solid #eef2f6; border-radius:5px; padding:5px 9px; font-size:12.5px; }
.pillrow { padding:3px 0 3px 8px; }
.pill { display:inline-block; font-size:11px; line-height:18px; padding:0 9px; border-radius:9px; font-weight:600; }
.pill.or { background:#fff7ed; color:#c2410c; border:1px solid #fed7aa; }
.pill.and { background:#eff6ff; color:#1d4ed8; border:1px solid #bfdbfe; }
.pre { background:#f8fafc; border-radius:8px; padding:8px; white-space:pre-wrap; }
</style>
