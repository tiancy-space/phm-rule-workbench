<template>
  <div>
    <div class="vizhead">
      <span class="hint">可视化逻辑结构</span>
      <div class="viztools">
        <button v-if="viz === 'ladder'" type="button" class="small" @click="$emit('big')">展开大图</button>
        <button type="button" class="link small" @click="$emit('named', true)">展开命名组</button>
        <button type="button" class="link small" @click="$emit('named', false)">折叠命名组</button>
        <div class="seg vizseg">
          <button type="button" :class="{ active: viz === 'list' }" @click="$emit('viz', 'list')">分组清单</button>
          <button type="button" :class="{ active: viz === 'ladder' }" @click="$emit('viz', 'ladder')">梯形图</button>
        </div>
      </div>
    </div>
    <div v-if="viz === 'list'" class="checklist" style="margin-top:8px">
      <div v-if="display" class="ckhead">{{ head }}</div>
      <template v-for="(item, i) in tops">
        <div v-if="i && display && display.type === 'or'" class="pillrow top" :key="'or' + i"><span class="pill or">或</span></div>
        <div class="ckitem" :key="'ck' + i">
          <span class="cknum">{{ circ(i) }}</span>
          <div class="ckbody">
            <group-tree :node="item" :open="namedOpen" @toggle="$emit('toggle', $event)" />
          </div>
        </div>
      </template>
      <div v-if="!display" class="empty">写好组合式后这里显示中文结构</div>
    </div>
    <div v-else class="card" style="margin-top:8px;overflow:auto" v-html="ladderHtml" @click="onLadder"></div>
    <div class="tabs" style="margin-top:12px">
      <button type="button" :class="{ active: tab === 'cn' }" @click="$emit('tab', 'cn')">中文判定逻辑释义</button>
      <button type="button" :class="{ active: tab === 'json' }" @click="$emit('tab', 'json')">零 JSON 规则表达式预览</button>
      <button type="button" :class="{ active: tab === 'sim' }" @click="$emit('tab', 'sim')">模拟测点试算验证</button>
    </div>
    <div v-show="tab === 'cn'">
      <pre class="preview explain">{{ cnBlock }}</pre>
    </div>
    <div v-show="tab === 'json'">
      <div class="hint">入库表达式（引擎执行）</div>
      <pre class="preview">{{ preview && preview.faultRule }}</pre>
      <div class="hint">引用式 · 仅供阅读</div>
      <pre class="preview">{{ preview && preview.refExpr }}</pre>
      <div class="hint">零 JSON 反解析校验</div>
      <textarea class="expr" rows="3" :value="checkText" @input="$emit('check-input', $event.target.value)"></textarea>
      <div v-if="checkResult && checkResult.ok" class="ok">✓ 反解析通过 · {{ checkResult.condCount }} 个条件
        <template v-if="checkResult.sameAsExpect"> · 与当前组合生成结果逐字一致</template>
      </div>
      <div v-else-if="checkResult && checkText" class="error">第 {{ (checkResult.pos || 0) + 1 }} 字符：{{ checkResult.message }}</div>
    </div>
    <div v-show="tab === 'sim'">
      <slot name="sim"></slot>
    </div>
  </div>
</template>

<script>
import GroupTree from './GroupTree.vue'
import { cnExplain } from '../../workbench/explain'
/** 分组清单、梯形图，以及释义 / 表达式 / 试算三个页签。 */
export default {
  name: 'RuleTabs',
  components: { GroupTree: GroupTree },
  props: {
    viz: { type: String, default: 'list' },
    tab: { type: String, default: 'cn' },
    display: { type: Object, default: null },
    gzdm: { type: String, default: '' },
    namedOpen: { type: Object, default: function () { return {} } },
    ladderHtml: { type: String, default: '' },
    preview: { type: Object, default: null },
    inherited: { type: Array, default: function () { return [] } },
    params: { type: Array, default: function () { return [] } },
    checkText: { type: String, default: '' },
    checkResult: { type: Object, default: null }
  },
  computed: {
    tops: function () {
      var n = this.display
      if (!n) return []
      if (n.type === 'and' || n.type === 'or') return n.children || []
      return [n]
    },
    topCount: function () { return this.tops.length },
    head: function () {
      if (!this.display) return ''
      if (this.display.type === 'or') return '满足以下任一项，即报出故障 ' + this.gzdm + '：'
      return '报出故障 ' + this.gzdm + '，需同时满足以下 ' + this.topCount + ' 项：'
    },
    /** 前置过滤和组合判定合成一段，样式上就是一个灰底等宽框。 */
    cnBlock: function () {
      return cnExplain(this.inherited, this.params, this.preview && this.preview.ruleDesc)
    }
  },
  methods: {
    /** 和原型清单一样用圆圈数字，不用普通阿拉伯数字。 */
    circ: function (i) {
      var s = '①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳'
      return s[i] || (i + 1)
    },
    onLadder: function (e) {
      var node = e.target.closest && e.target.closest('[data-code]')
      if (node) this.$emit('toggle', node.getAttribute('data-code'))
    }
  }
}
</script>

<style scoped>
/* 分段按钮不许把「分组清单」折成两行，整组跟着原型保持单行。 */
.viztools { display: flex; align-items: center; gap: 8px; flex-wrap: nowrap; margin-left: auto; }
.viztools .link,
.viztools .small,
.vizseg,
.vizseg button { white-space: nowrap; }
.vizseg { flex: none; min-width: 168px; }
.vizseg button { flex: 1 0 auto; }
.ckbody { flex: 1; min-width: 0; }
</style>
