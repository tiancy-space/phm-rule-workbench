<template>
  <header class="top">
    <div class="topline">
      <div class="brand">
        <div class="logo">机</div>
        <div>
          <h1>机车 PHM 故障规则管理工作台</h1>
          <div class="sub">规则按车型 + 来源 + 故障代码维护，表达式在服务端解析</div>
        </div>
      </div>
      <div class="actions">
        <button type="button" @click="$emit('pre')">通用前置故障规则（{{ enabledPre }} 条生效）</button>
        <button type="button" @click="$emit('flow')">▤ 处置流程管理</button>
        <button type="button" @click="$emit('library')">原子规则库全量视图</button>
      </div>
    </div>
    <div class="between">
      <div class="stats" v-if="stats">
        <span class="stat">故障底账 <b>{{ stats.faults }}</b></span>
        <span class="stat">组合判定 <b>{{ stats.conditional }}</b></span>
        <span class="stat">直接报出 <b>{{ stats.direct }}</b></span>
        <span class="stat">停用 <b>{{ stats.disabled }}</b></span>
        <span class="stat">共享原子 <b>{{ stats.atoms }}</b></span>
        <span class="stat">命名组 <b>{{ stats.groups }}</b></span>
        <span class="stat">处置流程 <b>{{ stats.flows }}</b></span>
        <span class="stat">生效前置 <b>{{ stats.enabledPres }}</b></span>
      </div>
      <span class="live"><i class="dot"></i> 离线沙盒 · 不连接生产</span>
    </div>
  </header>
</template>

<script>
/** 顶栏：标志、操作和加粗统计。统计项之间用竖线分开。 */
export default {
  name: 'TopBar',
  props: {
    stats: { type: Object, default: null },
    enabledPre: { type: Number, default: 0 }
  }
}
</script>
