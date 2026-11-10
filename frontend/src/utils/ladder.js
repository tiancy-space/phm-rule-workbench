/**
 * 继电器梯形图。串联触点是「且」，上下并联是「或」。
 * 布局直接移植原型 V5.1，不使用通用图布局库：电气图的母线和触点不是普通节点连线。
 */
import { textW, wrapText, esc } from './textsvg'

export var LADDER_STYLE = [
  '.ladder .rail{stroke:#334155;stroke-width:3}',
  '.ladder .wire{stroke:#64748b;stroke-width:1.4}',
  '.ladder .node{fill:#64748b}',
  '.ladder .ct rect{fill:#fff;stroke:#94a3b8;stroke-width:1.2}',
  '.ladder .ct .cbar{stroke:#cbd5e1;stroke-width:1}',
  '.ladder .ltx{font-size:12px;fill:#1e293b;font-family:"PingFang SC","Microsoft YaHei",sans-serif}',
  '.ladder .lal{font:10px Consolas,monospace;fill:#94a3b8}',
  '.ladder .ct.named rect{fill:#faf8ff;stroke:#a78bfa;stroke-dasharray:4 3}',
  '.ladder .ct.named .ltx{fill:#5b21b6;font-weight:600}',
  '.ladder .nframe>rect{fill:#faf8ff;stroke:#c4b5fd;stroke-dasharray:4 3}',
  '.ladder .nlabel rect{fill:#ede9fe;stroke:#c4b5fd}',
  '.ladder .nlabel text{font-size:11px;fill:#5b21b6;font-weight:600;font-family:"PingFang SC","Microsoft YaHei",sans-serif}',
  '.ladder .coil path{fill:none;stroke:#1d4ed8;stroke-width:2}',
  '.ladder .coiltx{font-size:12px;fill:#1d4ed8;font-weight:600;font-family:"PingFang SC","Microsoft YaHei",sans-serif}',
  '.ladder [data-code]{cursor:pointer}'
].join('')

function leaf (label, alias, opts) {
  var o = opts || {}
  var lines = wrapText(label, 220)
  var bw = Math.max(96, Math.max.apply(null, lines.map(textW)) + 26)
  var bh = lines.length * 16 + 14
  var top = 15
  return {
    w: bw,
    h: top + bh + 6,
    cy: top + bh / 2,
    svg: function (x, y) {
      var cls = o.cls ? ' ' + o.cls : ''
      var act = o.code ? ' data-code="' + esc(o.code) + '"' : ''
      return '<g class="ct' + cls + '"' + act + '><title>' + esc((alias ? alias + ' · ' : '') + (o.tip || label)) + '</title>' +
        (alias ? '<text class="lal" x="' + (x + 2) + '" y="' + (y + 11) + '">' + esc(alias) + '</text>' : '') +
        '<rect x="' + x + '" y="' + (y + top) + '" width="' + bw + '" height="' + bh + '" rx="4"/>' +
        '<line class="cbar" x1="' + (x + 7) + '" y1="' + (y + top + 5) + '" x2="' + (x + 7) + '" y2="' + (y + top + bh - 5) + '"/>' +
        '<line class="cbar" x1="' + (x + bw - 7) + '" y1="' + (y + top + 5) + '" x2="' + (x + bw - 7) + '" y2="' + (y + top + bh - 5) + '"/>' +
        lines.map(function (l, i) {
          return '<text class="ltx" x="' + (x + bw / 2) + '" y="' + (y + top + 18 + i * 16) + '" text-anchor="middle">' + esc(l) + '</text>'
        }).join('') + '</g>'
    }
  }
}

function series (cs) {
  var gap = 20
  var cy = Math.max.apply(null, cs.map(function (c) { return c.cy }))
  var below = Math.max.apply(null, cs.map(function (c) { return c.h - c.cy }))
  var w = cs.reduce(function (s, c) { return s + c.w }, 0) + gap * (cs.length - 1)
  return {
    w: w, h: cy + below, cy: cy,
    svg: function (x, y) {
      var o = ''
      var xo = x
      cs.forEach(function (c, i) {
        if (i) o += '<line class="wire" x1="' + (xo - gap) + '" y1="' + (y + cy) + '" x2="' + xo + '" y2="' + (y + cy) + '"/>'
        o += c.svg(xo, y + cy - c.cy)
        xo += c.w + gap
      })
      return o
    }
  }
}

function parallel (cs) {
  var pad = 18
  var vg = 4
  var w = Math.max.apply(null, cs.map(function (c) { return c.w })) + pad * 2
  var ys = []
  var h = 0
  cs.forEach(function (c, i) {
    ys.push(h)
    h += c.h + (i < cs.length - 1 ? vg : 0)
  })
  return {
    w: w, h: h, cy: cs[0].cy,
    svg: function (x, y) {
      var yTop = y + cs[0].cy
      var yBot = y + ys[ys.length - 1] + cs[cs.length - 1].cy
      var o = '<line class="wire" x1="' + x + '" y1="' + yTop + '" x2="' + x + '" y2="' + yBot + '"/>' +
        '<line class="wire" x1="' + (x + w) + '" y1="' + yTop + '" x2="' + (x + w) + '" y2="' + yBot + '"/>'
      cs.forEach(function (c, i) {
        var yy = y + ys[i] + c.cy
        o += '<line class="wire" x1="' + x + '" y1="' + yy + '" x2="' + (x + pad) + '" y2="' + yy + '"/>' +
          c.svg(x + pad, y + ys[i]) +
          '<line class="wire" x1="' + (x + pad + c.w) + '" y1="' + yy + '" x2="' + (x + w) + '" y2="' + yy + '"/>' +
          '<circle class="node" cx="' + x + '" cy="' + yy + '" r="2.4"/>' +
          '<circle class="node" cx="' + (x + w) + '" cy="' + yy + '" r="2.4"/>'
      })
      return o
    }
  }
}

function isOpen (open, code) {
  return !open || open[code] !== false
}

function layout (n, open) {
  if (!n) return leaf('表达式有误', '', { cls: 'bad' })
  if (n.type === 'leaf') return leaf(n.text || n.expr || '', n.alias, { tip: n.expr || n.text })
  if (n.type === 'named') {
    if (!n.child) return leaf((n.name || '') + '（有误）', n.alias, { cls: 'bad' })
    if (!isOpen(open, n.code)) {
      return leaf('◆ ' + n.name + ' ▸', n.alias, { cls: 'named', code: n.code, tip: '点击展开' })
    }
    var inner = layout(n.child, open)
    var side = 12
    var top = 24
    var label = '◆ ' + n.name + ' ▾'
    var w = inner.w + side * 2
    var h = inner.h + top + 8
    return {
      w: w, h: h, cy: top + inner.cy,
      svg: function (x, y) {
        return '<g class="nframe"><rect x="' + x + '" y="' + (y + 12) + '" width="' + w + '" height="' + (h - 12) + '" rx="6"/>' +
          '<g class="nlabel" data-code="' + esc(n.code) + '"><title>点击折叠为一个触点</title>' +
          '<rect x="' + (x + 8) + '" y="' + (y + 3) + '" width="' + (textW(label) + 18) + '" height="18" rx="9"/>' +
          '<text x="' + (x + 15) + '" y="' + (y + 16) + '">' + esc(label) + '</text></g></g>' +
          '<line class="wire" x1="' + x + '" y1="' + (y + top + inner.cy) + '" x2="' + (x + side) + '" y2="' + (y + top + inner.cy) + '"/>' +
          inner.svg(x + side, y + top) +
          '<line class="wire" x1="' + (x + side + inner.w) + '" y1="' + (y + top + inner.cy) + '" x2="' + (x + w) + '" y2="' + (y + top + inner.cy) + '"/>'
      }
    }
  }
  var cs = (n.children || []).map(function (c) { return layout(c, open) })
  if (!cs.length) return leaf('（空）', '')
  return n.type === 'and' ? series(cs) : parallel(cs)
}

/**
 * @param ast 后端 display 树
 * @param open 命名组展开表，缺省全部展开
 * @param faultCode 报出故障代码，画在线圈上
 * @return 含 style 的完整 svg 字符串
 */
export function ladderSvg (ast, open, faultCode) {
  if (!ast) return ''
  var b = layout(ast, open || {})
  var L = 18
  var pre = 28
  var coilGap = 34
  var coilW = 34
  var label = '报出故障 ' + (faultCode || '')
  var labW = Math.max(textW(label) + 10, coilW)
  var post = 28
  var padT = 22
  var bx = L + pre
  var cx = bx + b.w + coilGap
  var W = cx + Math.max(coilW, labW) + post + L
  var H = b.h + padT + 20
  var ry = padT + b.cy
  var R = W - L
  var ccx = cx + coilW / 2
  return '<svg class="ladder" width="' + W + '" height="' + H + '" viewBox="0 0 ' + W + ' ' + H + '" xmlns="http://www.w3.org/2000/svg">' +
    '<style>' + LADDER_STYLE + '</style>' +
    '<line class="rail" x1="' + L + '" y1="6" x2="' + L + '" y2="' + (H - 6) + '"/>' +
    '<line class="rail" x1="' + R + '" y1="6" x2="' + R + '" y2="' + (H - 6) + '"/>' +
    '<line class="wire" x1="' + L + '" y1="' + ry + '" x2="' + bx + '" y2="' + ry + '"/>' +
    b.svg(bx, padT) +
    '<line class="wire" x1="' + (bx + b.w) + '" y1="' + ry + '" x2="' + cx + '" y2="' + ry + '"/>' +
    '<g class="coil"><path d="M' + (cx + 8) + ' ' + (ry - 12) + ' A14 14 0 0 0 ' + (cx + 8) + ' ' + (ry + 12) + '"/>' +
    '<path d="M' + (cx + coilW - 8) + ' ' + (ry - 12) + ' A14 14 0 0 1 ' + (cx + coilW - 8) + ' ' + (ry + 12) + '"/>' +
    '<text class="coiltx" x="' + ccx + '" y="' + (ry - 18) + '" text-anchor="middle">' + esc(label) + '</text></g>' +
    '<line class="wire" x1="' + (cx + coilW - 1) + '" y1="' + ry + '" x2="' + R + '" y2="' + ry + '"/></svg>'
}

export function checklistLines (ruleDesc) {
  return String(ruleDesc || '').split('\n').filter(Boolean)
}
