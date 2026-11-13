<template>
  <div class="savebar">
    <span :class="dirty ? 'dirty' : 'ok'">{{ dirty ? '● 未保存修改' : '✓ 已保存' }}</span>
    <div class="row">
      <button type="button" @click="$emit('reset')">重置修改</button>
      <button type="button" class="primary" @click="$emit('save')">保存当前故障规则</button>
    </div>
  </div>
</template>

<script>
/** 工作区底部固定条。Ctrl+S 由外层页面接到保存。 */
export default {
  name: 'SaveBar',
  props: { dirty: { type: Boolean, default: false } }
}
</script>
