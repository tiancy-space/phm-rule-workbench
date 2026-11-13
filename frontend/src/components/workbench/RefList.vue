<template>
  <div class="card">
    <div class="sectiontitle between">
      <span><span class="number">1</span> 已引入的原子 / 命名组 <span class="count">{{ refs.length }}</span></span>
      <button type="button" class="link small" @click="$emit('create')">＋ 顺手新建</button>
    </div>
    <div v-for="r in refs" :key="r.alias" class="atomrow">
      <div class="between">
        <div class="row" style="gap:6px">
          <span class="alias">{{ r.alias }}</span>
          <template v-if="r.refType === 'GROUP'">
            <span style="color:#7c3aed">◆</span>
            <b>{{ r.name }}</b>
            <span class="badge violet">命名组 · {{ kind(r) }}</span>
          </template>
          <b v-else>{{ phrase(r) }}</b>
        </div>
        <div>
          <button type="button" class="link small" @click="$emit('edit', r)">编辑</button>
          <button type="button" class="link small danger" @click="$emit('remove', r)">移除</button>
        </div>
      </div>
      <div class="logic">
        <template v-if="r.refType === 'GROUP'">{{ groupText(r) }}</template>
        <template v-else>{{ phrase(r) }}</template>
        <span v-if="source(r)" class="badge">{{ source(r) }}</span>
      </div>
    </div>
    <div v-if="!refs.length" class="empty">从右侧原子池引用条件，或顺手新建</div>
  </div>
</template>

<script>
import { atomSource, groupKind, groupPhrase } from '../../workbench/explain'
/**
 * 已引入条件。左边是蓝色 A 编号，名称用中文释义，第二行带数据来源标签。
 */
export default {
  name: 'RefList',
  props: {
    refs: { type: Array, default: function () { return [] } },
    atoms: { type: Array, default: function () { return [] } },
    groups: { type: Array, default: function () { return [] } },
    params: { type: Array, default: function () { return [] } }
  },
  methods: {
    atomOf: function (r) {
      return this.atoms.filter(function (a) { return a.atomCode === r.code })[0]
    },
    groupOf: function (r) {
      return this.groups.filter(function (g) { return g.groupCode === r.code })[0]
    },
    phrase: function (r) {
      var a = this.atomOf(r)
      return (a && a.atomName) || r.name || r.code
    },
    kind: function (r) { return groupKind(this.groupOf(r) || { groupExpr: '' }) },
    groupText: function (r) { return groupPhrase(this.groupOf(r) || { groupExpr: r.expr }, this.atoms) },
    source: function (r) {
      if (r.refType === 'GROUP') return ''
      return atomSource(this.atomOf(r), this.params)
    }
  }
}
</script>
