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
 * 把前置规则说成人话：信号用中文名，相等用「为 / 不为」，集合用「属于 / 不属于」。
 * 黑名单超过 6 个时只列前 6 个，后面写「等 N 个」。枚举值换成字典里的中文。
 */
export function conditionPhrase (row, params) {
  var col = (row && row.paramCol) || ''
  var op = (row && row.cmpOp) || ''
  var raw = row && row.cmpVal != null ? String(row.cmpVal) : ''
  var param = (params || []).filter(function (x) { return x.paramCol === col })[0]
  var name = (param && param.paramName) || col || '条件'
  var enums = []
  String((param && param.enumDict) || '').split(';').forEach(function (part) {
    var i = part.indexOf(':')
    if (i > 0) enums.push([part.slice(0, i).trim(), part.slice(i + 1).trim()])
  })
  function meaning (code) {
    var hit = enums.filter(function (e) { return e[0] === code })[0]
    return hit ? hit[1] : code
  }
  var value = raw.trim().replace(/^\(/, '').replace(/\)$/, '')
  if (value.charAt(0) === "'" && value.charAt(value.length - 1) === "'" && value.indexOf(',') < 0) {
    value = value.slice(1, -1)
  }
  if (value === '-' && op === '==') return name + ' 未取到（缺失）'
  if (value === '-' && op === '!=') return name + ' 已取到'
  if (op === 'IN' || op === 'NOT IN') {
    var items = value.split(/[,，]/).map(function (s) {
      return s.trim().replace(/^'+|'+$/g, '')
    }).filter(Boolean).map(meaning)
    var list = items.length > 6 ? items.slice(0, 6).join('、') + ' 等 ' + items.length + ' 个' : items.join('、')
    return name + (op === 'IN' ? ' 属于 ' : ' 不属于 ') + list
  }
  if (op === '=~') return name + ' 匹配正则 ' + value
  var named = meaning(value)
  if (named !== value && (op === '==' || op === '!=')) {
    return name + (op === '==' ? ' 为 ' : ' 不为 ') + named
  }
  var sym = { '==': '=', '!=': '≠', '>': '>', '>=': '≥', '<': '<', '<=': '≤' }[op] || op
  var unit = param && param.unit ? ' ' + param.unit : ''
  return name + ' ' + sym + ' ' + value + unit
}

/**
 * 中文释义整段：前置过滤和组合判定放在同一个文本框里，中间空一行。
 * 编号只写一次，不再在框外另列一条。
 */
export function cnExplain (filters, params, ruleDesc) {
  var lines = (filters || []).map(function (p, i) {
    return (i + 1) + '. ' + (p.filterName || '前置') + '：' + conditionPhrase(p, params)
  })
  var head = '前置过滤（均须通过，任一不通过即拦截）\n' + (lines.length ? lines.join('\n') : '无适用过滤条件')
  var body = String(ruleDesc || '').trim()
  return body ? head + '\n\n' + body : head
}

export function timingLabel (v) {
  return { BEFORE_HBASE: '查 HBase 前短路拦截', AFTER_HBASE: '查 HBase 后拦截' }[v] || v || ''
}
