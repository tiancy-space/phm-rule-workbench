/**
 * 把后端返回的展示树画成简易梯形图。串联是「且」，并联是「或」。
 * Element UI 和 ECharts 都不适合继电器梯形图，所以这里自己画 SVG。
 */
function textWidth (s) {
  var w = 0
  var str = String(s || '')
  for (var i = 0; i < str.length; i++) w += str.charCodeAt(i) > 255 ? 12 : 7
  return w
}

function layout (node, open) {
  if (!node) return { w: 80, h: 36, kind: 'bad', lines: ['表达式有误'] }
  if (node.type === 'named') {
    var opened = !open || open[node.code] !== false
    if (!opened || !node.child) {
      return box('◆ ' + (node.name || '') + (opened ? '' : ' ▸'), node.alias, 'named')
    }
    var inner = layout(node.child, open)
    return { w: inner.w + 28, h: inner.h + 28, kind: 'named', name: node.name, alias: node.alias, child: inner }
  }
  if (node.type === 'and') {
    var kids = (node.children || []).map(function (c) { return layout(c, open) })
    var w = 0
    var h = 36
    kids.forEach(function (k) { w += k.w + 18; h = Math.max(h, k.h) })
    return { w: Math.max(80, w), h: h, kind: 'and', kids: kids }
  }
  if (node.type === 'or') {
    var ors = (node.children || []).map(function (c) { return layout(c, open) })
    var ow = 80
    var oh = 8
    ors.forEach(function (k) { ow = Math.max(ow, k.w); oh += k.h + 10 })
    return { w: ow + 36, h: oh, kind: 'or', kids: ors }
  }
  return box(node.text || node.expr || '', node.alias, 'leaf')
}

function box (text, alias, kind) {
  var lines = wrap(text, 28)
  var w = 96
  lines.forEach(function (l) { w = Math.max(w, textWidth(l) + 28) })
  return { w: w, h: lines.length * 16 + 18, kind: kind || 'leaf', lines: lines, alias: alias }
}

function wrap (s, n) {
  var str = String(s || '')
  if (str.length <= n) return [str]
  var out = []
  for (var i = 0; i < str.length && out.length < 3; i += n) out.push(str.slice(i, i + n))
  return out
}

function draw (node, x, y) {
  var svg = ''
  if (node.kind === 'leaf' || node.kind === 'bad' || (node.kind === 'named' && !node.child)) {
    svg += '<rect x="' + x + '" y="' + y + '" width="' + node.w + '" height="' + node.h + '" rx="4" fill="#fff" stroke="' + (node.kind === 'named' ? '#7c3aed' : '#64748b') + '" ' + (node.kind === 'named' ? 'stroke-dasharray="4 3"' : '') + '/>'
    ;(node.lines || []).forEach(function (l, i) {
      svg += '<text x="' + (x + 8) + '" y="' + (y + 16 + i * 16) + '" font-size="12" fill="#0f172a">' + esc(l) + '</text>'
    })
    if (node.alias) svg += '<text x="' + (x + node.w - 8) + '" y="' + (y + 14) + '" text-anchor="end" font-size="10" fill="#2563eb">' + esc(node.alias) + '</text>'
    return svg
  }
  if (node.kind === 'named') {
    svg += '<rect x="' + x + '" y="' + y + '" width="' + node.w + '" height="' + node.h + '" rx="6" fill="#faf5ff" stroke="#7c3aed" stroke-dasharray="5 3"/>'
    svg += '<text x="' + (x + 8) + '" y="' + (y + 16) + '" font-size="12" fill="#6d28d9">◆ ' + esc(node.name || '') + '</text>'
    svg += draw(node.child, x + 14, y + 22)
    return svg
  }
  if (node.kind === 'and') {
    var cx = x
    var mid = y + node.h / 2
    svg += '<line x1="' + x + '" y1="' + mid + '" x2="' + (x + node.w) + '" y2="' + mid + '" stroke="#334155" stroke-width="2"/>'
    node.kids.forEach(function (k) {
      svg += draw(k, cx, y + (node.h - k.h) / 2)
      cx += k.w + 18
    })
    return svg
  }
  var yy = y + 4
  svg += '<line x1="' + (x + 8) + '" y1="' + (y + 8) + '" x2="' + (x + 8) + '" y2="' + (y + node.h - 8) + '" stroke="#334155" stroke-width="2"/>'
  svg += '<line x1="' + (x + node.w - 8) + '" y1="' + (y + 8) + '" x2="' + (x + node.w - 8) + '" y2="' + (y + node.h - 8) + '" stroke="#334155" stroke-width="2"/>'
  node.kids.forEach(function (k) {
    var midY = yy + k.h / 2
    svg += '<line x1="' + (x + 8) + '" y1="' + midY + '" x2="' + (x + 20) + '" y2="' + midY + '" stroke="#334155" stroke-width="2"/>'
    svg += draw(k, x + 20, yy)
    svg += '<line x1="' + (x + 20 + k.w) + '" y1="' + midY + '" x2="' + (x + node.w - 8) + '" y2="' + midY + '" stroke="#334155" stroke-width="2"/>'
    yy += k.h + 10
  })
  return svg
}

function esc (s) {
  return String(s || '').replace(/[&<>]/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]
  })
}

export function ladderSvg (ast, open) {
  if (!ast) return ''
  var tree = layout(ast, open || {})
  var w = tree.w + 80
  var h = tree.h + 24
  return '<svg xmlns="http://www.w3.org/2000/svg" width="' + w + '" height="' + h + '" class="ladder">' +
    '<line x1="16" y1="8" x2="16" y2="' + (h - 8) + '" stroke="#0f172a" stroke-width="3"/>' +
    '<line x1="' + (w - 16) + '" y1="8" x2="' + (w - 16) + '" y2="' + (h - 8) + '" stroke="#0f172a" stroke-width="3"/>' +
    draw(tree, 28, 12) + '</svg>'
}

export function checklistLines (ruleDesc) {
  return String(ruleDesc || '').split('\n').filter(Boolean)
}
