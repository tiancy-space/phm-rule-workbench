<template>
  <div v-if="visible" class="overlay" @click.self="$emit('close')">
    <div class="modal wide">
      <div class="modalhead">
        <h2>共享原子规则库 · 全量视图</h2>
        <button type="button" class="close" @click="$emit('close')">×</button>
      </div>
      <div class="modalbody">
        <div class="between">
          <div class="hint">{{ rows.length }} 条共享定义 · 修改同步所有引用方</div>
          <button type="button" class="primary small" @click="$emit('create')">＋ 新建原子规则</button>
        </div>
        <input :value="q" class="full" style="margin-top:12px" placeholder="搜索全部原子名称 / 编码 / 参数" @input="$emit('q', $event.target.value)" />
        <div class="librarygrid">
          <article v-for="a in rows" :key="a.id" class="poolcard">
            <div class="between">
              <span class="mono hint">{{ a.atomCode }}</span>
              <span class="row" style="gap:4px">
                <span class="badge">{{ a.scopeCx === 'ALL' ? 'ALL 通用' : a.scopeCx }}</span>
                <span class="badge">{{ a.atomType === 'WINDOW' ? '时间窗关联' : '参数比较' }}</span>
              </span>
            </div>
            <div class="title">{{ a.atomName }}</div>
            <div class="raw mono">{{ a.atomExpr }}</div>
            <button type="button" class="link small" @click="$emit('refs', 'atom', a.id)">{{ usageText('atom', a.id) }}</button>
            <div class="poolfoot">
              <button type="button" class="small" :class="{ primary: !aliasOf(a.atomCode) }" :disabled="!!aliasOf(a.atomCode)" @click="$emit('use', a)">
                {{ aliasOf(a.atomCode) ? ('✓ 已引用为 ' + aliasOf(a.atomCode)) : '＋ 引用到当前故障' }}
              </button>
              <span>
                <button type="button" class="link small" @click="$emit('edit', a)">编辑</button>
                <button type="button" class="link small danger" @click="$emit('remove', a)">删除</button>
              </span>
            </div>
          </article>
        </div>
        <h3 style="margin:18px 0 8px">命名条件组 · {{ groups.length }}</h3>
        <div class="librarygrid">
          <article v-for="g in groups" :key="g.id" class="poolcard">
            <div class="between">
              <span class="mono hint">{{ g.groupCode }}</span>
              <span class="badge violet">命名条件组</span>
            </div>
            <div class="title">◆ {{ g.groupName }}</div>
            <div class="raw mono">{{ g.groupExpr }}</div>
            <button type="button" class="link small" @click="$emit('refs', 'group', g.id)">{{ usageText('group', g.id) }}</button>
          </article>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/** 原子库全量视图：两列卡片，带引用统计。命名组跟在原子后面，和原型同一张弹层。 */
export default {
  name: 'AtomLibraryModal',
  props: {
    visible: { type: Boolean, default: false },
    rows: { type: Array, default: function () { return [] } },
    groups: { type: Array, default: function () { return [] } },
    q: { type: String, default: '' },
    refs: { type: Array, default: function () { return [] } },
    usageText: { type: Function, required: true }
  },
  methods: {
    /** 当前故障里这个原子的局部代号，没有就是还没引用。 */
    aliasOf: function (code) {
      var hit = (this.refs || []).filter(function (r) { return r.code === code })[0]
      return hit ? hit.alias : ''
    }
  }
}
</script>

<style scoped>
.full { width: 100%; margin-bottom: 12px; }
</style>
