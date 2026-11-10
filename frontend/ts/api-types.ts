/**
 * 前后端契约里用到的核心类型。页面组件是 JavaScript，
 * 因为 Vue 2.6 配合 TypeScript 3.5 和 Element UI 2 的类型定义不完整，正式说明见 docs/组件与技术栈评估.md。
 * 本文件用 tsc --noEmit 做编译期检查，保证接口字段不被写错。
 */
export interface RefItem {
  refType: 'ATOM' | 'GROUP'
  code: string
}

export interface FaultSaveRequest {
  rev: number
  ruleMode: string
  czdj: string
  jkdj: string
  mxmc?: string
  ruleExpr?: string
  configNote?: string
  refs: RefItem[]
  skipFilterIds: number[]
}

export interface ExprPreview {
  ok: boolean
  message?: string
  pos?: number
  canonicalExpr?: string
  faultRule?: string
  refExpr?: string
  ruleDesc?: string
  condCount?: number
  windowCount?: number
  sameAsExpect?: boolean
}

export interface ApiResult<T> {
  code: number
  message: string
  data: T
}
