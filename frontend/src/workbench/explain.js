/**
 * 引用行和分组清单用的中文说法。不改后端：原子直接用 atomName，命名组用成员原子名称替换组合式里的编号。
 */

/** 把 (R001 & R002) | R003 换成「名称 且 名称 或 名称」。 */
export function groupPhrase (group, atoms) {
  var expr = (group && group.groupExpr) || ''
  var text = expr.replace(/R\d+/g, function (code) {
    var hit = (atoms || []).filter(function (a) { return a.atomCode === code })[0]
    return hit ? hit.atomName : code
  })
  return text.replace(/&/g, '且').replace(/\|/g, '或').replace(/\s+/g, ' ').trim()
}

/** 组合式里有「或」就是满足其一，否则同时满足。 */
export function groupKind (group) {
  return ((group && group.groupExpr) || '').indexOf('|') >= 0 ? '满足其一' : '同时满足'
}

/** 参数原子显示数据来源，时间窗显示「时间窗」。 */
export function atomSource (atom, params) {
  if (!atom) return ''
  if (atom.atomType === 'WINDOW') return '时间窗'
  var p = (params || []).filter(function (x) { return x.paramCol === atom.paramCol })[0]
  return (p && p.dataSource) || ''
}

/**
 * 前置黑名单很长时只展示前几个编码。
 * 例如 CC NOT IN ('8100','8200',...) → 8100、8200…等 26 个
 */
export function shortCodes (expr) {
  var text = String(expr || '')
  var codes = text.match(/'[^']+'/g) || []
  codes = codes.map(function (s) { return s.slice(1, -1) })
  if (codes.length <= 4) return text
  return codes.slice(0, 4).join('、') + '…等 ' + codes.length + ' 个'
}

export function timingLabel (v) {
  return { BEFORE_HBASE: '查 HBase 前短路拦截', AFTER_HBASE: '查 HBase 后拦截' }[v] || v || ''
}
