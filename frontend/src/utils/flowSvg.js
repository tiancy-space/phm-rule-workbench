/**
 * 处置流程图。按步骤顺序自上而下排列，箭头文字是分支名称。
 * 指向后面或前面的步骤用「转至」标出，避免长线交叉。
 */
var SHAPE = {
  VIEW: { label: '查看', color: '#0369a1', fill: '#f0f9ff' },
  JUDGE: { label: '判断', color: '#b45309', fill: '#fffbeb' },
  OP: { label: '操作', color: '#15803d', fill: '#f0fdf4' },
  CONTACT: { label: '联络', color: '#be185d', fill: '#fdf2f8' },
  END: { label: '结束', color: '#334155', fill: '#f8fafc' }
}
var CIRC = '①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳'

function circ (i) {
  return CIRC[i] || ('(' + (i + 1) + ')')
}

function esc (s) {
  return String(s || '').replace(/[&<>]/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]
  })
}

export function flowSvg (steps) {
  var list = steps || []
  if (!list.length) return ''
  var index = {}
  list.forEach(function (s, i) { index[s.id] = i })
  var rowH = 92
  var w = 360
  var h = list.length * rowH + 16
  var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + w + '" height="' + h + '" class="flowsvg">'
  list.forEach(function (s, i) {
    var y = 12 + i * rowH
    var meta = SHAPE[s.stepType] || SHAPE.VIEW
    var title = (s.stepTitle || '').slice(0, 18)
    svg += '<g class="fnode" data-id="' + s.id + '" style="cursor:pointer">'
    if (s.stepType === 'JUDGE') {
      svg += '<polygon points="180,' + y + ' 320,' + (y + 32) + ' 180,' + (y + 64) + ' 40,' + (y + 32) + '" fill="' + meta.fill + '" stroke="' + meta.color + '"/>'
    } else if (s.stepType === 'END') {
      svg += '<rect x="70" y="' + y + '" width="220" height="48" rx="24" fill="' + meta.fill + '" stroke="' + meta.color + '"/>'
    } else {
      svg += '<rect x="50" y="' + y + '" width="260" height="52" rx="' + (s.stepType === 'OP' ? 14 : 4) + '" fill="' + meta.fill + '" stroke="' + meta.color + '"/>'
    }
    svg += '<text x="180" y="' + (y + 20) + '" text-anchor="middle" font-size="11" fill="' + meta.color + '" font-weight="700">' + circ(i) + ' ' + meta.label + '</text>'
    svg += '<text x="180" y="' + (y + 38) + '" text-anchor="middle" font-size="12" fill="#0f172a">' + esc(title) + '</text></g>'
    var branches = s.branches || []
    branches.forEach(function (b, bi) {
      var label = b.branchLabel || ''
      var dest = b.nextStepId && index[b.nextStepId] != null ? index[b.nextStepId] : null
      var color = dest == null ? '#dc2626' : '#64748b'
      var text = dest == null ? (label + ' → 未配置') : (dest === i + 1 ? label : label + ' ↪ 转至 ' + circ(dest))
      svg += '<text x="180" y="' + (y + 74 + bi * 0) + '" text-anchor="middle" font-size="11" fill="' + color + '">' + esc(branches.length > 1 ? branches.map(function (x) {
        var d = x.nextStepId && index[x.nextStepId] != null ? index[x.nextStepId] : null
        return (x.branchLabel || '') + (d == null ? '→未配置' : '→' + circ(d))
      }).join('   ') : text) + '</text>'
    })
  })
  svg += '</svg>'
  return svg
}
