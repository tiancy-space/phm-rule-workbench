<template>
  <div class="prebar">
    <div class="between">
      <b>◈ 通用前置规则 · 继承 {{ inherited }} 项</b>
      <button type="button" class="link small" @click="open = !open">{{ open ? '收起' : '管理单条豁免' }}</button>
    </div>
    <div class="chips" style="margin-top:8px">
      <button type="button" v-for="p in pres" :key="p.id" class="prechip" :class="{ skip: skipped(p.id) }"
        :title="p.filterExpr" @click="$emit('toggle', p.id)">
        {{ p.filterName }}<template v-if="skipped(p.id)">（豁免）</template>
      </button>
      <span v-if="!pres.length" class="hint">暂无适用前置规则</span>
    </div>
    <div v-if="open" class="note" style="margin-top:10px">
      勾选表示此故障跳过该规则，保存后生效。
      <label v-for="p in pres" :key="'x'+p.id" style="display:block;margin-top:6px">
        <input type="checkbox" :checked="skipped(p.id)" @change="$emit('toggle', p.id)" />
        豁免 {{ p.filterName }} <code>{{ p.filterExpr }}</code>
      </label>
    </div>
  </div>
</template>

<script>
/** 引用区上方的前置芯片。点芯片或勾选都是切换豁免。 */
export default {
  name: 'PreBar',
  props: {
    pres: { type: Array, default: function () { return [] } },
    skipIds: { type: Array, default: function () { return [] } },
    inherited: { type: Number, default: 0 }
  },
  data: function () { return { open: false } },
  methods: {
    skipped: function (id) { return this.skipIds.indexOf(id) >= 0 }
  }
}
</script>
