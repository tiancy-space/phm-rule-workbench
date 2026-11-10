<template>
  <div class="bigmask" v-if="visible" @click.self="close" @keydown="onKey" tabindex="0" ref="mask">
    <div class="bigbox">
      <div class="bighead">
        <div>
          <b>{{ title }}</b>
          <div class="muted">{{ subtitle }}</div>
        </div>
        <div class="bigtools">
          <button type="button" @click="zoom(0.8)">−</button>
          <button type="button" @click="zoom(1.25)">＋</button>
          <button type="button" :class="{on: fitMode}" @click="fit">适应窗口</button>
          <button type="button" @click="actual">100%</button>
          <button type="button" @click="exportSvg">导出 SVG</button>
          <button type="button" @click="exportPng">导出 PNG</button>
          <span class="pct">{{ pct }}%</span>
          <button type="button" class="x" @click="close">×</button>
        </div>
      </div>
      <div class="stage" ref="stage"
           @wheel.prevent="onWheel"
           @pointerdown="onDown"
           @pointermove="onMove"
           @pointerup="onUp"
           @pointercancel="onUp">
        <div class="canvas" ref="canvas" :style="transform" v-html="svg"></div>
      </div>
      <div class="bighint">{{ hint }} 图例：{{ legend }}</div>
    </div>
  </div>
</template>

<script>
/**
 * 梯形图和流程图共用的大图。滚轮以光标为中心缩放，按住拖动平移，
 * 快捷键 + / - / F / 0 / Esc 与原型一致。导出把当前 SVG 写成文件，PNG 用 2 倍画布。
 */
export default {
  name: 'BigCanvas',
  props: {
    visible: Boolean,
    title: String,
    subtitle: String,
    svg: String,
    legend: String,
    hint: { type: String, default: '滚轮缩放 · 拖动平移 · Esc 关闭' },
    fileBase: { type: String, default: '图' },
    caption: { type: String, default: '' }
  },
  data: function () {
    return { scale: 1, tx: 0, ty: 0, fitMode: true, drag: null, W: 1, H: 1 }
  },
  computed: {
    pct: function () { return Math.round(this.scale * 100) },
    transform: function () {
      return { transform: 'translate(' + this.tx + 'px,' + this.ty + 'px) scale(' + this.scale + ')' }
    }
  },
  watch: {
    visible: function (v) { if (v) this.$nextTick(this.fit) },
    svg: function () { if (this.visible) this.$nextTick(this.refitIfNeeded) }
  },
  methods: {
    close: function () { this.$emit('close') },
    readSize: function () {
      var svg = this.$refs.canvas && this.$refs.canvas.querySelector('svg')
      if (!svg) return
      this.W = Number(svg.getAttribute('width')) || 400
      this.H = Number(svg.getAttribute('height')) || 300
    },
    refitIfNeeded: function () {
      this.readSize()
      if (this.fitMode) this.fit()
    },
    fit: function () {
      this.readSize()
      var st = this.$refs.stage
      if (!st) return
      var pad = 32
      this.scale = Math.max(0.15, Math.min((st.clientWidth - pad * 2) / this.W, (st.clientHeight - pad * 2) / this.H, 2.2))
      this.tx = (st.clientWidth - this.W * this.scale) / 2
      this.ty = (st.clientHeight - this.H * this.scale) / 2
      this.fitMode = true
    },
    actual: function () {
      this.readSize()
      var st = this.$refs.stage
      this.scale = 1
      this.tx = Math.max(24, (st.clientWidth - this.W) / 2)
      this.ty = Math.max(24, (st.clientHeight - this.H) / 2)
      this.fitMode = false
    },
    zoom: function (factor, cx, cy) {
      this.readSize()
      var st = this.$refs.stage
      if (cx == null) { cx = st.clientWidth / 2; cy = st.clientHeight / 2 }
      var ns = Math.max(0.15, Math.min(4, this.scale * factor))
      var k = ns / this.scale
      this.tx = cx - (cx - this.tx) * k
      this.ty = cy - (cy - this.ty) * k
      this.scale = ns
      this.fitMode = false
    },
    onWheel: function (e) {
      var r = this.$refs.stage.getBoundingClientRect()
      this.zoom(e.deltaY < 0 ? 1.12 : 1 / 1.12, e.clientX - r.left, e.clientY - r.top)
    },
    onDown: function (e) {
      if (e.button !== 0 || (e.target.closest && e.target.closest('[data-id],[data-code]'))) {
        var node = e.target.closest && e.target.closest('[data-id]')
        if (node) this.$emit('node', node.getAttribute('data-id'))
        var named = e.target.closest && e.target.closest('[data-code]')
        if (named) this.$emit('toggle', named.getAttribute('data-code'))
        return
      }
      this.drag = { x: e.clientX, y: e.clientY, tx: this.tx, ty: this.ty }
      e.currentTarget.setPointerCapture(e.pointerId)
    },
    onMove: function (e) {
      if (!this.drag) return
      this.tx = this.drag.tx + e.clientX - this.drag.x
      this.ty = this.drag.ty + e.clientY - this.drag.y
      this.fitMode = false
    },
    onUp: function () { this.drag = null },
    onKey: function (e) {
      if (e.key === 'Escape') { this.close(); return }
      if (e.key === '+' || e.key === '=') this.zoom(1.25)
      else if (e.key === '-') this.zoom(0.8)
      else if (e.key === 'f' || e.key === 'F') this.fit()
      else if (e.key === '0') this.actual()
    },
    svgText: function () {
      var raw = this.svg || ''
      var cap = this.caption ? '<text x="18" y="16" font-size="12" fill="#64748b" font-family="PingFang SC,Microsoft YaHei,sans-serif">' + this.caption.replace(/[&<>]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c] }) + '</text>' : ''
      return raw.replace(/<svg([^>]*)>/, '<svg$1>' + cap)
    },
    download: function (blob, name) {
      var a = document.createElement('a')
      a.href = URL.createObjectURL(blob)
      a.download = name
      document.body.appendChild(a)
      a.click()
      setTimeout(function () { URL.revokeObjectURL(a.href); a.remove() }, 800)
    },
    exportSvg: function () {
      this.readSize()
      var text = this.svgText()
      this.download(new Blob([text], { type: 'image/svg+xml;charset=utf-8' }), this.fileBase + '.svg')
      this.$message && this.$message.success('已导出 SVG')
    },
    exportPng: function () {
      var self = this
      this.readSize()
      var text = this.svgText()
      var img = new Image()
      var scale = 2
      img.onload = function () {
        var c = document.createElement('canvas')
        c.width = Math.ceil(self.W * scale)
        c.height = Math.ceil(self.H * scale)
        var g = c.getContext('2d')
        g.fillStyle = '#fff'
        g.fillRect(0, 0, c.width, c.height)
        g.scale(scale, scale)
        g.drawImage(img, 0, 0, self.W, self.H)
        c.toBlob(function (b) {
          if (b) {
            self.download(b, self.fileBase + '.png')
            if (self.$message) self.$message.success('已导出 PNG（2 倍清晰度）')
          } else if (self.$message) self.$message.error('PNG 导出失败，请改用 SVG')
        }, 'image/png')
      }
      img.onerror = function () { if (self.$message) self.$message.error('PNG 导出失败，请改用 SVG') }
      img.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(text)
    }
  },
  mounted: function () {
    if (this.visible) this.$nextTick(this.fit)
    var self = this
    this._focus = function () { if (self.visible && self.$refs.mask) self.$refs.mask.focus() }
    this.$nextTick(this._focus)
  },
  updated: function () { if (this.visible) this._focus() }
}
</script>

<style scoped>
.bigmask { position:fixed; inset:0; background:rgba(15,23,42,.55); z-index:40; display:flex; outline:none; }
.bigbox { background:#fff; margin:24px; flex:1; border-radius:12px; display:flex; flex-direction:column; min-width:0; }
.bighead { display:flex; justify-content:space-between; gap:12px; padding:10px 14px; border-bottom:1px solid #e2e8f0; }
.bigtools { display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
.bigtools button { border:1px solid #cbd5e1; background:#fff; border-radius:6px; padding:4px 8px; cursor:pointer; }
.bigtools button.on { background:#eff6ff; border-color:#2563eb; color:#1d4ed8; }
.bigtools .x { font-size:18px; }
.pct { color:#64748b; min-width:42px; }
.stage { flex:1; overflow:hidden; background:#f8fafc; position:relative; touch-action:none; cursor:grab; }
.canvas { transform-origin:0 0; position:absolute; left:0; top:0; }
.bighint { padding:8px 14px; color:#64748b; font-size:12px; border-top:1px solid #e2e8f0; }
</style>
