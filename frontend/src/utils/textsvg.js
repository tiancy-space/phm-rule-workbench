/** 梯形图、流程图共用的文字宽度和转义。中文按 12px 估，英文按 6.9px。 */
export function textW (s) {
  var w = 0
  var str = String(s || '')
  for (var i = 0; i < str.length; i++) w += str.charCodeAt(i) > 255 ? 12 : 6.9
  return w
}

export function wrapText (s, max) {
  var limit = max || 250
  var toks = String(s || '').match(/[A-Za-z0-9_.'%-]+[、，）)]?|\s+|.[、，）)]?/g) || []
  var lines = []
  var cur = ''
  toks.forEach(function (t) {
    if (cur && textW(cur + t) > limit && cur.trim()) {
      lines.push(cur.trim())
      cur = t.trim() ? t : ''
    } else cur += t
  })
  if (cur.trim()) lines.push(cur.trim())
  return lines.length ? lines : ['']
}

export function esc (s) {
  return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
  })
}

export var CIRC = '①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳'

export function circ (i) {
  return CIRC[i] || ('(' + (i + 1) + ')')
}
