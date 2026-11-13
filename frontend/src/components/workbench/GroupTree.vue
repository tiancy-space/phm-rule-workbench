<template>
  <div :class="shell">
    <template v-if="node && (node.type === 'and' || node.type === 'or')">
      <div class="groupcaption">{{ node.type === 'or' ? '满足其一' : '同时满足' }}</div>
      <div v-for="(c, i) in node.children" :key="i">
        <div v-if="i" class="pillrow"><span class="pill" :class="node.type === 'or' ? 'or' : 'and'">{{ node.type === 'or' ? '或' : '且' }}</span></div>
        <group-tree :node="c" :open="open" @toggle="$emit('toggle', $event)" />
      </div>
    </template>
    <div v-else-if="node && node.type === 'named'" class="named">
      <button type="button" class="sum" @click="node.code && $emit('toggle', node.code)">
        <span class="gicon">◆</span>
        <b>{{ node.name || node.code }}</b>
        <span class="kind">（{{ childKind }}）</span>
        <span v-if="node.alias" class="alias">{{ node.alias }}</span>
        <span class="hint fold">{{ isOpen(node) ? '收起明细' : '展开明细' }}</span>
      </button>
      <group-tree v-if="isOpen(node) && node.child" :node="node.child" :open="open" @toggle="$emit('toggle', $event)" />
      <div v-else-if="isOpen(node)" class="error">命名组表达式有误</div>
    </div>
    <div v-else-if="node" class="leaf">
      <span v-if="node.alias" class="alias">{{ node.alias }}</span>
      {{ node.text || node.code }}
    </div>
  </div>
</template>

<script>
/**
 * 分组清单。编号圆圈由外层清单负责，这里画且/或树、紫色命名组和橙色「或」胶囊。
 */
export default {
  name: 'GroupTree',
  props: {
    node: { type: Object, default: null },
    open: { type: Object, default: function () { return {} } }
  },
  computed: {
    shell: function () {
      var t = this.node && this.node.type
      if (t !== 'and' && t !== 'or') return null
      return ['tree', { or: t === 'or' }]
    },
    childKind: function () {
      var c = this.node && this.node.child
      if (!c) return '单项条件'
      if (c.type === 'or') return '满足其一'
      if (c.type === 'and') return '同时满足'
      return '单项条件'
    }
  },
  methods: {
    isOpen: function (n) {
      if (!n || !n.code) return true
      return this.open[n.code] !== false
    }
  }
}
</script>

<style scoped>
/* 清单项占满 ckbody。命名组用原型的虚线紫框，不要缩成内容那么窄。 */
.tree, .named, .leaf { width: 100%; box-sizing: border-box; }
.named {
  display: block;
  border: 1px dashed #c4b5fd;
  background: #faf8ff;
  border-radius: 6px;
  padding: 4px 10px 8px;
  margin: 0;
}
.sum {
  border: 0;
  background: transparent;
  padding: 2px 0;
  width: 100%;
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: wrap;
  text-align: left;
  cursor: pointer;
  font-size: 13px;
  line-height: 1.75;
}
.gicon { color: #7c3aed; font-size: 11px; }
.sum b { color: #5b21b6; }
.kind { color: #6d28d9; font-size: 12px; }
.fold { margin-left: auto; color: #7c3aed; font-size: 12px; white-space: nowrap; }
.leaf { font-size: 12.5px; }
</style>
