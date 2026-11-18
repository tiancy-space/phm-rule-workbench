/**
 * 处置流程图：广度优先生成树，已经画过的步骤用「↪ 转至」虚线框代替回边。
 * 这样同一层用水平母线分叉，不会出现交叉连线。算法来自原型 V5.1，不使用 dagre：
 * dagre 会把回边画成真正的连线，和原型「避免交叉」的读图方式相反。
 */
import { textW, wrapText, esc, circ } from './textsvg'

var FG = { GX: 22, VG: 84, PAD: 24 }
var STEP = {
  VIEW: { label: '查看', color: '#0369a1', bg: '#f0f9ff' },
  JUDGE: { label: '判断', color: '#b45309', bg: '#fffbeb' },
  OP: { label: '操作', color: '#15803d', bg: '#f0fdf4' },
  CONTACT: { label: '联络上报', color: '#be185d', bg: '#fdf2f8' },
  END: { label: '结束', color: '#334155', bg: '#f8fafc' }
}
var ROLE = {
  DRIVER: { label: '司机', color: '#2563eb' },
  EXPERT: { label: '专家', color: '#7c3aed' },
  SYSTEM: { label: '系统', color: '#0d9488' }
}
var CONCL = {
  MAINTAIN: ['#15803d', '#f0fdf4', '维持运行'],
  SPEED_LIMIT: ['#b45309', '#fffbeb', '限速运行'],
  RESCUE: ['#b91c1c', '#fef2f2', '请求救援'],
  RETURN_DEPOT: ['#1d4ed8', '#eff6ff', '回库处理']
}

export var FLOW_STYLE = [
  '.flowsvg .fnode{cursor:pointer}',
  '.flowsvg text{font-family:"PingFang SC","Microsoft YaHei",sans-serif}'
].join('')

export var FLOW_LEGEND = '查看（矩形） · 判断（菱形） · 操作（圆角） · 联络上报（六边形） · 结束（胶囊） · ↪ 转至表示该步骤已在图中展开，避免交叉连线'

function nodeSize (t) {
  if (t === 'JUDGE') return [200, 100]
  if (t === 'END') return [168, 54]
  if (t === 'CONTACT') return [188, 72]
  return [176, 72]
}

function shape (t, x, y, w, h, col, fill, sw) {
  var a = 'fill="' + fill + '" stroke="' + col + '" stroke-width="' + sw + '"'
  if (t === 'JUDGE') return '<polygon points="' + (x + w / 2) + ',' + y + ' ' + (x + w) + ',' + (y + h / 2) + ' ' + (x + w / 2) + ',' + (y + h) + ' ' + x + ',' + (y + h / 2) + '" ' + a + '/>'
  if (t === 'CONTACT') {
    var k = 14
    return '<polygon points="' + (x + k) + ',' + y + ' ' + (x + w - k) + ',' + y + ' ' + (x + w) + ',' + (y + h / 2) + ' ' + (x + w - k) + ',' + (y + h) + ' ' + (x + k) + ',' + (y + h) + ' ' + x + ',' + (y + h / 2) + '" ' + a + '/>'
  }
  var r = t === 'END' ? h / 2 : t === 'OP' ? 14 : 3
  return '<rect x="' + x + '" y="' + y + '" width="' + w + '" height="' + h + '" rx="' + r + '" ' + a + '/>'
}

function buildTree (steps) {
  var byId = {}
  steps.forEach(function (s) { byId[s.id] = s })
  var placed = {}
  var roots = []
  function mk (s) { return { kind: 'step', s: s, ch: [] } }
  function grow (root) {
    placed[root.s.id] = true
    var q = [root]
    while (q.length) {
      var n = q.shift()
      if (n.s.stepType === 'END') continue
      ;(n.s.branches || []).forEach(function (b) {
        var c
        if (!b.nextStepId || !byId[b.nextStepId]) c = { kind: 'miss', label: b.nextStepId ? '出口无效' : '未配置出口', ch: [] }
        else if (placed[b.nextStepId]) c = { kind: 'ref', s: byId[b.nextStepId], ch: [] }
        else {
          placed[b.nextStepId] = true
          c = mk(byId[b.nextStepId])
          q.push(c)
        }
        n.ch.push({ label: b.branchLabel || '', n: c })
      })
    }
  }
  if (steps.length) {
    var r = mk(steps[0])
    grow(r)
    roots.push(r)
  }
  steps.forEach(function (s) {
    if (!placed[s.id]) {
      var orphan = mk(s)
      orphan.orphan = true
      grow(orphan)
      roots.push(orphan)
    }
  })
  return roots
}

function measure (n) {
  if (n.kind === 'step') {
    var sz = nodeSize(n.s.stepType)
    n.w = sz[0]
    n.h = sz[1]
  } else if (n.kind === 'ref') {
    n.w = Math.min(196, Math.max(120, textW('↪ 转至 ⑥ ' + String(n.s.stepTitle || '').slice(0, 9)) + 22))
    n.h = 34
  } else {
    n.w = 118
    n.h = 34
  }
  n.ch.forEach(function (c) {
    measure(c.n)
    c.lw = Math.max(34, textW(c.label) + 16)
  })
  var cw = n.ch.reduce(function (a, c) { return a + Math.max(c.n.tw, c.lw + 8) }, 0) + FG.GX * Math.max(0, n.ch.length - 1)
  n.tw = Math.max(n.w, cw)
}

function place (n, x, d, rows) {
  n.d = d
  n.cx = x + n.tw / 2
  rows[d] = Math.max(rows[d] || 0, n.h)
  var cw = n.ch.reduce(function (a, c) { return a + Math.max(c.n.tw, c.lw + 8) }, 0) + FG.GX * Math.max(0, n.ch.length - 1)
  var cx = x + (n.tw - cw) / 2
  n.ch.forEach(function (c) {
    var w = Math.max(c.n.tw, c.lw + 8)
    place(c.n, cx + (w - c.n.tw) / 2, d + 1, rows)
    cx += w + FG.GX
  })
}

function stepNo (steps, id) {
  for (var i = 0; i < steps.length; i++) if (steps[i].id === id) return i
  return 0
}

function pill (x, y, t, w) {
  return '<g><rect x="' + (x - w / 2) + '" y="' + (y - 10) + '" width="' + w + '" height="20" rx="10" fill="#fff" stroke="#cbd5e1"/>' +
    '<text x="' + x + '" y="' + (y + 4) + '" text-anchor="middle" font-size="11.5" fill="#334155" font-weight="600">' + esc(t) + '</text></g>'
}

/**
 * @param steps 流程步骤，按序号排列
 * @param opt {hl: 高亮步骤 id}
 */
export function flowSvg (steps, opt) {
  var list = steps || []
  if (!list.length) return ''
  var highlight = opt && opt.hl
  var roots = buildTree(list)
  var rows = []
  var X = FG.PAD
  roots.forEach(function (r) {
    measure(r)
    r.x0 = X
    place(r, X, 0, rows)
    X += r.tw + FG.GX * 3
  })
  var Y = []
  var y = FG.PAD + (roots.length > 1 ? 18 : 0)
  rows.forEach(function (h) {
    Y.push(y)
    y += h + FG.VG
  })
  var W = X - FG.GX * 3 + FG.PAD
  var H = y - FG.VG + FG.PAD
  var edges = ''
  var nodes = ''
  var labels = ''
  function topOf (n) { return Y[n.d] }
  function walk (n) {
    var top = topOf(n)
    var bot = top + n.h
    var busY = Y[n.d] + rows[n.d] + FG.VG * 0.36
    if (n.kind === 'step') {
      var s = n.s
      var D = STEP[s.stepType] || STEP.VIEW
      var no = stepNo(list, s.id)
      var x = n.cx - n.w / 2
      var on = highlight === s.id
      var concl = CONCL[s.conclusion] || null
      var col = s.stepType === 'END' ? (concl ? concl[0] : D.color) : D.color
      var fill = s.stepType === 'END' ? (concl ? concl[1] : D.bg) : D.bg
      var maxW = s.stepType === 'JUDGE' ? n.w - 74 : n.w - 30
      var lines = wrapText(s.stepTitle || '（未命名）', maxW).slice(0, 2)
      if (wrapText(s.stepTitle || '', maxW).length > 2) lines[1] = lines[1].slice(0, -1) + '…'
      var cy = top + n.h / 2
      var base = cy - (lines.length - 1) * 8 + (s.stepType === 'END' ? 4 : 1)
      var conclName = concl ? concl[2] : ''
      nodes += '<g class="fnode" data-id="' + s.id + '">' +
        shape(s.stepType, x, top, n.w, n.h, on ? '#1d4ed8' : col, fill, on ? 2.6 : 1.5) +
        '<text x="' + n.cx + '" y="' + (s.stepType === 'JUDGE' ? top + 24 : top + 14) + '" text-anchor="middle" font-size="10.5" fill="' + col + '" font-weight="700">' +
        circ(no) + ' ' + D.label + (s.stepType === 'END' ? ' · ' + esc(conclName) : '') + '</text>'
      if (s.stepType === 'END') {
        nodes += '<text x="' + n.cx + '" y="' + (top + 36) + '" text-anchor="middle" font-size="12" font-weight="600" fill="#0f172a">' + esc(lines[0]) + '</text>'
        if (s.pushRepair) nodes += '<text x="' + (x + n.w - 14) + '" y="' + (bot - 7) + '" text-anchor="end" font-size="10" fill="#1d4ed8">⚑检修</text>'
      } else {
        lines.forEach(function (l, i) {
          nodes += '<text x="' + n.cx + '" y="' + (base + 8 + i * 16) + '" text-anchor="middle" font-size="12.5" font-weight="600" fill="#0f172a">' + esc(l) + '</text>'
        })
      }
      var roles = s.roleCodes || []
      if (s.stepType !== 'END') {
        roles.forEach(function (code, i) {
          var role = ROLE[code]
          if (!role) return
          var dx = n.cx - (roles.length - 1) * 9 + i * 18
          nodes += '<circle cx="' + dx + '" cy="' + (s.stepType === 'JUDGE' ? top + n.h - 16 : bot - 9) + '" r="4.2" fill="' + role.color + '"><title>' + role.label + '</title></circle>'
        })
      }
      if ((s.cards || []).length && s.stepType !== 'JUDGE') {
        nodes += '<text x="' + (x + n.w - 8) + '" y="' + (bot - 6) + '" text-anchor="end" font-size="10" fill="#64748b">卡' + s.cards.length + '</text>'
      }
      nodes += '<title>' + circ(no) + ' ' + D.label + '：' + esc(s.stepTitle) + '</title></g>'
    } else if (n.kind === 'ref') {
      var rno = stepNo(list, n.s.id)
      var rx = n.cx - n.w / 2
      var rcol = (STEP[n.s.stepType] || STEP.VIEW).color
      var titleLine = wrapText(n.s.stepTitle, n.w - 70)
      nodes += '<g class="fnode" data-id="' + n.s.id + '"><rect x="' + rx + '" y="' + top + '" width="' + n.w + '" height="' + n.h + '" rx="17" fill="#fff" stroke="' + rcol + '" stroke-dasharray="5 3" stroke-width="1.4"/>' +
        '<text x="' + n.cx + '" y="' + (top + 21) + '" text-anchor="middle" font-size="11.5" fill="' + rcol + '" font-weight="600">↪ 转至 ' + circ(rno) + ' ' + esc(titleLine[0] || '') + (titleLine.length > 1 ? '…' : '') + '</text></g>'
    } else {
      var mx = n.cx - n.w / 2
      nodes += '<g><rect x="' + mx + '" y="' + top + '" width="' + n.w + '" height="' + n.h + '" rx="6" fill="#fef2f2" stroke="#dc2626" stroke-dasharray="4 3"/>' +
        '<text x="' + n.cx + '" y="' + (top + 21) + '" text-anchor="middle" font-size="11.5" fill="#b91c1c" font-weight="600">✕ ' + esc(n.label) + '</text></g>'
    }
    if (!n.ch.length) return
    var one = n.ch.length === 1 && Math.abs(n.ch[0].n.cx - n.cx) < 1
    if (one) {
      var c0 = n.ch[0]
      var ct0 = topOf(c0.n)
      edges += '<path d="M' + n.cx + ',' + bot + ' V' + (ct0 - 1) + '" stroke="#64748b" stroke-width="1.5" fill="none" marker-end="url(#fa)"/>'
      labels += pill(n.cx, (bot + ct0) / 2, c0.label, c0.lw)
    } else {
      edges += '<path d="M' + n.cx + ',' + bot + ' V' + busY + '" stroke="#64748b" stroke-width="1.5" fill="none"/>'
      var xs = n.ch.map(function (c) { return c.n.cx }).concat([n.cx])
      edges += '<path d="M' + Math.min.apply(null, xs) + ',' + busY + ' H' + Math.max.apply(null, xs) + '" stroke="#64748b" stroke-width="1.5" fill="none"/>'
      n.ch.forEach(function (c) {
        var ct = topOf(c.n)
        edges += '<path d="M' + c.n.cx + ',' + busY + ' V' + (ct - 1) + '" stroke="#64748b" stroke-width="1.5" fill="none" marker-end="url(#fa)"/>'
        labels += pill(c.n.cx, (busY + ct) / 2, c.label, c.lw)
      })
    }
    n.ch.forEach(function (c) { walk(c.n) })
  }
  roots.forEach(function (r) {
    if (r.orphan) labels += '<text x="' + r.x0 + '" y="' + (FG.PAD + 4) + '" font-size="11" fill="#dc2626" font-weight="700">⚠ 不可达（无分支指向）</text>'
    walk(r)
  })
  return '<svg class="flowsvg" xmlns="http://www.w3.org/2000/svg" width="' + W + '" height="' + H + '" viewBox="0 0 ' + W + ' ' + H + '">' +
    '<style>' + FLOW_STYLE + '</style>' +
    '<defs><marker id="fa" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#64748b"/></marker></defs>' +
    '<rect width="' + W + '" height="' + H + '" fill="#ffffff"/>' +
    '<g class="flowbody">' + edges + labels + nodes + '</g></svg>'
}

/**
 * 内容包围盒。优先量 .flowbody，这样铺满画布的白底不会把盒子撑满。
 * 图还没挂进文档时 getBBox 会抛，退回 width/height 属性。
 */
export function contentBox (svg) {
  if (!svg) return { x: 0, y: 0, width: 1, height: 1 }
  var node = svg.querySelector ? (svg.querySelector('.flowbody') || svg) : svg
  try {
    var b = node.getBBox()
    if (b && b.width > 0 && b.height > 0) return { x: b.x, y: b.y, width: b.width, height: b.height }
  } catch (e) { /* 未入文档 */ }
  return {
    x: 0,
    y: 0,
    width: Number(svg.getAttribute && svg.getAttribute('width')) || 1,
    height: Number(svg.getAttribute && svg.getAttribute('height')) || 1
  }
}

/**
 * 把包围盒放进容器。缩放取宽、高两个方向里较小的那个，四周留边，不放大超过 1。
 * tx/ty 按 transform-origin 在左上角来算，使缩放后的包围盒在容器中居中。
 */
export function fitTransform (box, view, pad) {
  var margin = pad == null ? 16 : pad
  var bw = Math.max(box.width || 1, 1)
  var bh = Math.max(box.height || 1, 1)
  var aw = Math.max((view.width || 0) - margin * 2, 1)
  var ah = Math.max((view.height || 0) - margin * 2, 1)
  var scale = Math.min(aw / bw, ah / bh, 1)
  if (!isFinite(scale) || scale <= 0) scale = 1
  var x = box.x || 0
  var y = box.y || 0
  return {
    scale: scale,
    tx: ((view.width || 0) - bw * scale) / 2 - x * scale,
    ty: ((view.height || 0) - bh * scale) / 2 - y * scale
  }
}
