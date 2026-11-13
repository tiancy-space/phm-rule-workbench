<template>
  <div class="shell" tabindex="0" @keydown="onKey">
    <top-bar :stats="stats" :enabled-pre="enabledPre" @pre="preOpen = true" @flow="openFlow()" @library="library = true" />
    <div class="workspace">
      <fault-list-panel :rows="filtered" :total="faults.length" :faults="faults" :filters="filters"
        :cx-options="cxOptions" :modes="modeOptions" :current-id="draft && draft.id"
        @filter="filters = $event" @pick="pick" @create="faultDlg = true" />
      <section class="panel" v-if="draft">
        <div class="centerbody">
          <fault-header-card :draft="draft" :modes="modeOptions" :dirty="dirty" @flow="openFlow" />
          <template v-if="draft.ruleMode === 'DIRECT' || draft.ruleMode === 'DISABLED'">
            <div class="modecard">
              <div class="modeicon">{{ draft.ruleMode === 'DIRECT' ? '➤' : '⊘' }}</div>
              <h2>{{ draft.ruleMode === 'DIRECT' ? '直接报出' : '停用过滤' }}</h2>
              <p>{{ draft.ruleMode === 'DIRECT' ? '不执行故障组合条件，前置过滤通过后直接报出。' : '此故障已停止输出，不进入后续判定与报出流程。' }}</p>
              <span class="hint">已有组合草稿会保留，切换回条件组合即可继续编辑。</span>
            </div>
          </template>
          <template v-else>
            <pre-bar :pres="applicablePres" :skip-ids="draft.skipFilterIds || []" :inherited="liveInherited.length" @toggle="toggleSkip" />
            <ref-list :refs="draft.refs" :atoms="atoms" :groups="groups" :params="params"
              @edit="editRef" @remove="removeRef" @create="atomDlg = freshAtom()" />
            <expr-composer :refs="draft.refs" :expr="draft.ruleExpr || ''" :preview="preview"
              @insert="insert" @input="draft.ruleExpr = $event" @all-and="allAnd" @all-or="allOr" />
            <rule-tabs :viz="viz" :tab="tab" :display="preview && preview.display" :gzdm="draft.gzdm"
              :named-open="namedOpen" :ladder-html="ladderHtml" :preview="preview" :inherited="liveInherited"
              :check-text="checkText" :check-result="checkResult"
              @viz="viz = $event" @tab="tab = $event" @named="setNamed" @toggle="toggleNamed" @big="bigOpen = true"
              @check-input="checkText = $event; runCheck()">
              <div slot="sim">
                <div class="hint">试算真实执行组合式和已继承前置。空值或「缺失 / 无效」按未命中处理。</div>
                <div class="toolbar">
                  <button type="button" class="small" @click="fill(true)">填充命中样例</button>
                  <button type="button" class="small" @click="fill(false)">填充未命中样例</button>
                  <button type="button" class="small primary" @click="runSim">执行模拟试算</button>
                </div>
                <div v-for="p in simParams" :key="p.code" class="simrow">
                  <div><b>{{ p.name }}</b> <span class="hint">{{ p.unit }}</span><div class="hint mono">{{ p.code }} · {{ p.source }}</div></div>
                  <select v-if="p.enums.length" v-model="simValues[p.code]">
                    <option value="">缺失 / 无效</option>
                    <option v-for="e in p.enums" :key="e.value" :value="e.value">{{ e.value }}:{{ e.label }}</option>
                  </select>
                  <input v-else v-model="simValues[p.code]" :placeholder="p.unit || '模拟值'" />
                </div>
                <label v-for="w in simWindows" :key="w.key" class="hint" style="display:block;margin-top:6px">
                  <b>{{ w.fn }}</b> · 同车 {{ w.sec }} 秒内
                  <input type="checkbox" v-model="simWindowsState[w.key]" /> 出现过关联故障 {{ w.code }}
                </label>
                <div v-if="simResult" class="result" :class="simResult.hit ? 'pass' : 'fail'">
                  <b>{{ simResult.hit ? ('✓ 命中 · 报出故障 ' + draft.gzdm) : '⊘ 未命中 · 不报出故障' }}</b>
                  <div class="hint">前置 {{ simResult.preOk }}/{{ simResult.preTotal }} 通过 · 组合判定 {{ simResult.comboPassed ? '成立' : '不成立' }}</div>
                  <table>
                    <thead><tr><th>判定依据</th><th>结果</th></tr></thead>
                    <tbody>
                      <tr v-for="row in simResult.rows" :key="row.kind + row.code + row.text">
                        <td>{{ row.text }}</td>
                        <td :class="row.ok ? 'ok' : 'error'">{{ row.ok ? '通过' : '未通过' }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </rule-tabs>
          </template>
        </div>
        <save-bar :dirty="dirty" @reset="reset" @save="save" />
      </section>
      <section v-else class="panel"><div class="empty">选择左侧故障开始维护</div></section>
      <atom-pool-panel :kind="poolKind" :scope="poolScope" :type="poolType" :q="poolQ"
        :atoms="atoms" :groups="groups" :atom-rows="poolAtoms" :group-rows="poolGroups" :used-codes="usedCodes"
        :usage-text="usageText"
        @kind="poolKind = $event" @scope="poolScope = $event" @type="poolType = $event" @q="poolQ = $event"
        @create="poolKind === 'atom' ? (atomDlg = freshAtom()) : (groupDlg = freshGroup())"
        @use-atom="useAtom" @use-group="useGroup" @edit-atom="atomDlg = editAtom($event)" @edit-group="groupDlg = editGroup($event)"
        @refs="showRef" />
    </div>
    <footer class="pagefoot">
      <span>数据来源：参数元数据、原子规则与故障底账。零 JSON 表达式只在服务端解析。</span>
      <span>本地保存 · Ctrl + S</span>
    </footer>
    <atom-library-modal :visible="library" :rows="libraryRows" :groups="libraryGroups" :q="libraryQ"
      :usage-text="usageText" @close="library = false" @q="libraryQ = $event"
      @create="atomDlg = freshAtom()" @remove="removeAtom" @refs="showRef" />
    <workbench-dialogs :host="this" />
    <flow-board v-if="$store.state.flowOpen" @close="reloadAfterFlow" />
    <big-canvas :visible="bigOpen" :title="'故障 ' + (draft && draft.gzdm) + ' 梯形图'"
      :subtitle="draft ? (draft.cx + ' / ' + draft.ly + ' / ' + draft.gzmc) : ''"
      :svg="ladderHtml" legend="串联＝且，并联＝或，◆ 为命名组"
      hint="滚轮缩放 · 拖动平移 · 点击命名组折叠 · + - F 0 · Esc 关闭"
      :file-base="'故障' + (draft && draft.gzdm) + '_梯形图'"
      :caption="draft ? (draft.cx + ' / ' + draft.gzdm + ' ' + draft.gzmc) : ''"
      @close="bigOpen = false" @toggle="toggleNamed" />
  </div>
</template>

<script>
import workbenchMixin from '../workbench/mixin'
import TopBar from '../components/workbench/TopBar.vue'
import FaultListPanel from '../components/workbench/FaultListPanel.vue'
import AtomPoolPanel from '../components/workbench/AtomPoolPanel.vue'
import FaultHeaderCard from '../components/workbench/FaultHeaderCard.vue'
import PreBar from '../components/workbench/PreBar.vue'
import RefList from '../components/workbench/RefList.vue'
import ExprComposer from '../components/workbench/ExprComposer.vue'
import RuleTabs from '../components/workbench/RuleTabs.vue'
import SaveBar from '../components/workbench/SaveBar.vue'
import AtomLibraryModal from '../components/workbench/AtomLibraryModal.vue'
import WorkbenchDialogs from '../components/workbench/WorkbenchDialogs.vue'
import FlowBoard from '../components/FlowBoard.vue'
import BigCanvas from '../components/BigCanvas.vue'

/** 三栏容器。业务在 mixin，各栏只负责原型上的那一块版面。 */
export default {
  name: 'Workbench',
  mixins: [workbenchMixin],
  components: {
    TopBar: TopBar, FaultListPanel: FaultListPanel, AtomPoolPanel: AtomPoolPanel,
    FaultHeaderCard: FaultHeaderCard, PreBar: PreBar, RefList: RefList, ExprComposer: ExprComposer,
    RuleTabs: RuleTabs, SaveBar: SaveBar, AtomLibraryModal: AtomLibraryModal, WorkbenchDialogs: WorkbenchDialogs,
    FlowBoard: FlowBoard, BigCanvas: BigCanvas
  }
}
</script>

<style scoped>
.shell { height: 100%; display: flex; flex-direction: column; outline: none; }
.shell:focus { outline: none; }
.workspace { flex: 1; height: auto !important; min-height: 0; }
</style>
