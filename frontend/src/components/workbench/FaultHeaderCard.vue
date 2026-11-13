<template>
  <div class="card" v-if="draft">
    <div class="between">
      <div>
        <span class="badge">{{ draft.cx }}</span>
        <span class="badge blue">{{ draft.ly }}</span>
        <b class="detailcode">{{ draft.gzdm }}</b>
      </div>
      <label class="field" style="margin:0;min-width:160px">
        <select v-model="draft.ruleMode">
          <option v-for="m in modes" :key="m.value" :value="m.value">{{ m.label }}</option>
        </select>
      </label>
    </div>
    <div class="detailtitle">{{ draft.gzmc }}</div>
    <div class="sub">故障底账 / {{ draft.cx }} / {{ draft.ly }} / {{ draft.gzdm }}</div>
    <div class="editfields">
      <label class="field">所属模型名称
        <input v-model="draft.mxmc" />
      </label>
      <label class="field">健康等级
        <select v-model="draft.jkdj">
          <option v-for="k in ['A','B','C','D']" :key="k" :value="k">{{ k }}</option>
        </select>
      </label>
    </div>
    <div class="czrow">
      <label class="field" style="margin:0">故障处置等级
        <select v-model="draft.czdj">
          <option value="CHECK">排查</option>
          <option value="WATCH">关注</option>
          <option value="NONE">无需干预</option>
        </select>
      </label>
      <div class="czdesc">
        <span class="cztag" :class="'cz-' + (draft.czdj || '').toLowerCase()">{{ czLabel(draft.czdj) }}</span>
        {{ czDesc(draft.czdj) }}
        <span class="hint">固定配置，不随规则条件变化；独立于健康等级</span>
        <span v-if="dirty" class="badge amber">保存后生效</span>
        <div class="flowentry">
          <template v-if="draft.czdj === 'NONE'">无需干预类故障不配处置流程</template>
          <template v-else-if="draft.flowId">
            <span class="flowstate ok">● 已配置 · {{ draft.flowStatus === 'PUBLISHED' ? ('已发布 v' + draft.pubVerNo) : '草稿' }} · {{ draft.stepCount }} 步</span>
            <button type="button" class="link small" @click="$emit('flow', draft.id)">查看 / 编辑处置流程</button>
          </template>
          <template v-else>
            <span class="flowstate">○ 未配置处置流程</span>
            <button type="button" class="link small" @click="$emit('flow', draft.id)">＋ 配置处置流程</button>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/** 故障判定工作区顶部：代码、模式、模型、健康等级和处置等级。 */
export default {
  name: 'FaultHeaderCard',
  props: {
    draft: { type: Object, required: true },
    modes: { type: Array, default: function () { return [] } },
    dirty: { type: Boolean, default: false }
  },
  methods: {
    czLabel: function (v) { return { CHECK: '排查', WATCH: '关注', NONE: '无需干预' }[v] || v },
    czDesc: function (v) { return { CHECK: '需按处置流程处置', WATCH: '司机留意、地面关注', NONE: '仅记录，不配处置流程' }[v] || '' }
  }
}
</script>
