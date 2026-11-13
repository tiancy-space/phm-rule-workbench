<template>
  <div class="card">
    <div class="sectiontitle">
      <span class="number">2</span> 逻辑与括号拼装器
      <span class="hint" style="font-weight:400">且 优先于 或 · 支持嵌套</span>
    </div>
    <div class="toolbar">
      <button type="button" v-for="r in refs" :key="r.alias" class="small" @click="$emit('insert', r.alias)">＋ {{ r.alias }}</button>
      <button type="button" class="small" @click="$emit('insert', ' & ')">且 (&amp;)</button>
      <button type="button" class="small" @click="$emit('insert', ' | ')">或 (|)</button>
      <button type="button" class="small" @click="$emit('insert', '(')">左括号</button>
      <button type="button" class="small" @click="$emit('insert', ')')">右括号</button>
    </div>
    <textarea class="expr mono" :class="{ invalid: preview && !preview.ok && expr }" :value="expr" rows="3"
      @input="$emit('input', $event.target.value)"></textarea>
    <div class="toolbar">
      <button type="button" class="small" @click="$emit('all-and')">全且快捷生成</button>
      <button type="button" class="small" @click="$emit('all-or')">全或快捷生成</button>
      <button type="button" class="small danger" @click="$emit('input', '')">清空重写</button>
    </div>
    <div v-if="preview && preview.ok" class="validation ok">✓ 语法校验通过 · 括号匹配正确</div>
    <div v-else-if="preview && expr" class="validation error">第 {{ (preview.pos || 0) + 1 }} 字符：{{ preview.message }}</div>
    <div v-if="preview && preview.ok && preview.canonicalExpr && preview.canonicalExpr !== expr" class="hint">
      规范写法：<code>{{ preview.canonicalExpr }}</code>
      <button type="button" class="link small" @click="$emit('input', preview.canonicalExpr)">一键应用</button>
    </div>
  </div>
</template>

<script>
/** 组合式拼装。胶囊按钮插入代号，全且/全或一次生成。 */
export default {
  name: 'ExprComposer',
  props: {
    refs: { type: Array, default: function () { return [] } },
    expr: { type: String, default: '' },
    preview: { type: Object, default: null }
  }
}
</script>
