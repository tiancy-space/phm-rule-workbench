<template>
  <div v-if="visible" class="overlay" @click.self="close">
    <div class="modal" :class="{ wide: wide }" role="dialog" :aria-label="title">
      <div class="modalhead">
        <h2>{{ title }}</h2>
        <button type="button" class="close" aria-label="关闭" @click="close">×</button>
      </div>
      <div class="modalbody">
        <slot></slot>
      </div>
      <div v-if="$slots.footer" class="modalfoot">
        <slot name="footer"></slot>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * 原型弹窗壳：遮罩、标题栏、正文、底部按钮。
 * 原子、命名组、前置规则以后都套这层，里面仍可放 Element 输入控件。
 * 层级高于 Element 抽屉，避免从抽屉里打开时被盖住。
 */
export default {
  name: 'ProtoModal',
  props: {
    visible: { type: Boolean, default: false },
    title: { type: String, default: '' },
    wide: { type: Boolean, default: false }
  },
  methods: {
    close: function () { this.$emit('close') }
  }
}
</script>

<style scoped>
.overlay { z-index: 3000; }
</style>
