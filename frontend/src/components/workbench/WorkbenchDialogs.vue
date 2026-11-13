<template>
  <div>
    <el-drawer title="通用前置故障规则" :visible.sync="host.preOpen" size="460px" custom-class="proto-drawer">
      <div style="padding:0 16px 16px">
        <div class="note">前置先于组合执行，任一未通过即拦截。范围和执行时机可配置，此处是沙盒，不会改现网。</div>
        <button type="button" class="primary" style="width:100%" @click="host.preForm = host.freshPre()">＋ 新增前置规则</button>
        <article v-for="p in host.pres" :key="p.id" class="card">
          <div class="between">
            <b>{{ p.filterName }}</b>
            <el-switch :value="p.isEnabled === 1" @change="host.togglePre(p, $event)" />
          </div>
          <p class="mono" style="font-size:12px;overflow-wrap:anywhere;margin:8px 0">{{ p.filterExpr }}</p>
          <div class="chips">
            <span class="badge">{{ p.scopeCx }}</span>
            <span class="badge blue">{{ p.scopeLy || 'ALL' }}</span>
            <span class="badge">{{ timing(p.execTiming) }}</span>
            <span class="badge">优先级 {{ p.priority }}</span>
          </div>
          <div class="between" style="margin-top:9px">
            <span class="hint mono">{{ p.filterCode || ('PF_' + p.id) }}</span>
            <div>
              <button type="button" class="link small" @click="host.preForm = host.editPre(p)">编辑</button>
              <button type="button" class="link small danger" @click="host.removePre(p)">删除</button>
            </div>
          </div>
        </article>
      </div>
    </el-drawer>

    <el-dialog :title="host.preForm && host.preForm.id ? '编辑前置规则' : '新增前置规则'" :visible.sync="host.preFormVisible" width="520px" custom-class="proto-dialog">
      <el-form v-if="host.preForm" label-width="110px" size="small">
        <el-form-item label="规则名称"><el-input v-model="host.preForm.filterName" /></el-form-item>
        <el-form-item label="协议指标">
          <el-select v-model="host.preForm.paramCol" filterable style="width:100%">
            <el-option v-for="p in host.params" :key="p.id" :label="p.paramName + ' ' + p.paramCol" :value="p.paramCol" />
          </el-select>
        </el-form-item>
        <el-form-item label="比较符">
          <el-select v-model="host.preForm.cmpOp" style="width:100%"><el-option v-for="o in host.ops" :key="o" :label="o" :value="o" /></el-select>
        </el-form-item>
        <el-form-item label="目标值"><el-input v-model="host.preForm.cmpVal" /></el-form-item>
        <el-form-item label="适用车型"><el-input v-model="host.preForm.scopeCx" placeholder="ALL 或 HXD1C,HXD1D" /></el-form-item>
        <el-form-item label="适用来源">
          <el-select v-model="host.preForm.scopeLy" style="width:100%"><el-option v-for="x in ['ALL','TCMS','6A']" :key="x" :label="x" :value="x" /></el-select>
        </el-form-item>
        <el-form-item label="执行时机">
          <el-select v-model="host.preForm.execTiming" style="width:100%">
            <el-option label="查 HBase 前短路拦截" value="BEFORE_HBASE" />
            <el-option label="查 HBase 后拦截" value="AFTER_HBASE" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级"><el-input-number v-model="host.preForm.priority" :min="1" /></el-form-item>
      </el-form>
      <span slot="footer"><button type="button" class="primary" @click="host.savePre()">保存前置规则</button></span>
    </el-dialog>

    <el-dialog :title="host.atomDlg && host.atomDlg.id ? '编辑原子规则' : '新建原子规则'" :visible.sync="host.atomVisible" width="560px" custom-class="proto-dialog">
      <el-form v-if="host.atomDlg" label-width="120px" size="small">
        <el-form-item label="原子类型">
          <el-radio-group v-model="host.atomDlg.atomType">
            <el-radio label="PARAM">参数测点比较</el-radio>
            <el-radio label="WINDOW">关联故障时间窗</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="适用车型"><el-input v-model="host.atomDlg.scopeCx" placeholder="ALL 或车型" /></el-form-item>
        <template v-if="host.atomDlg.atomType === 'PARAM'">
          <el-form-item label="协议参数">
            <el-select v-model="host.atomDlg.paramCol" filterable style="width:100%">
              <el-option v-for="p in host.params" :key="p.paramCol + p.id" :label="p.paramName + ' ' + p.paramCol" :value="p.paramCol" />
            </el-select>
          </el-form-item>
          <el-form-item label="比较符">
            <el-select v-model="host.atomDlg.cmpOp" style="width:100%"><el-option v-for="o in host.ops" :key="o" :label="o" :value="o" /></el-select>
          </el-form-item>
          <el-form-item label="目标值"><el-input v-model="host.atomDlg.cmpVal" placeholder="缺失值写 -" /></el-form-item>
        </template>
        <template v-else>
          <el-form-item label="时间窗函数">
            <el-select v-model="host.atomDlg.winFn" style="width:100%"><el-option v-for="f in host.winFns" :key="f" :label="f" :value="f" /></el-select>
          </el-form-item>
          <el-form-item label="窗口秒数"><el-input-number v-model="host.atomDlg.winSec" :min="1" /></el-form-item>
          <el-form-item label="关联故障代码"><el-input v-model="host.atomDlg.relGzdm" placeholder="逗号分隔" /></el-form-item>
        </template>
        <el-form-item label="名称"><el-input v-model="host.atomDlg.atomName" placeholder="留空则自动生成" /></el-form-item>
      </el-form>
      <span slot="footer"><button type="button" class="primary" @click="host.saveAtom()">保存共享定义</button></span>
    </el-dialog>

    <el-dialog :title="host.groupDlg && host.groupDlg.id ? '编辑命名条件组' : '新建命名组'" :visible.sync="host.groupVisible" width="680px" custom-class="proto-dialog">
      <el-form v-if="host.groupDlg" label-width="100px" size="small">
        <el-form-item label="组名称"><el-input v-model="host.groupDlg.groupName" /></el-form-item>
        <el-form-item label="适用车型"><el-input v-model="host.groupDlg.scopeCx" /></el-form-item>
        <el-form-item label="插入原子">
          <button type="button" class="small" v-for="a in host.atoms" :key="a.id" @click="host.groupDlg.groupExpr = (host.groupDlg.groupExpr || '') + a.atomCode + ' '">{{ a.atomCode }}</button>
        </el-form-item>
        <el-form-item label="组合式"><el-input type="textarea" :rows="3" v-model="host.groupDlg.groupExpr" @input="host.previewGroup()" /></el-form-item>
        <group-preview :preview="host.groupPreview" :name="host.groupDlg.groupName" />
      </el-form>
      <span slot="footer"><button type="button" class="primary" @click="host.saveGroup()">保存命名组</button></span>
    </el-dialog>

    <el-dialog title="新增故障条目" :visible.sync="host.faultDlg" width="480px" custom-class="proto-dialog">
      <el-form label-width="90px" size="small">
        <el-form-item label="车型"><el-input v-model="host.newFault.cx" /></el-form-item>
        <el-form-item label="来源">
          <el-select v-model="host.newFault.ly"><el-option label="TCMS" value="TCMS" /><el-option label="6A" value="6A" /></el-select>
        </el-form-item>
        <el-form-item label="故障代码"><el-input v-model="host.newFault.gzdm" /></el-form-item>
        <el-form-item label="名称"><el-input v-model="host.newFault.gzmc" /></el-form-item>
        <el-form-item label="模型"><el-input v-model="host.newFault.mxmc" /></el-form-item>
        <el-form-item label="健康等级">
          <el-select v-model="host.newFault.jkdj"><el-option v-for="k in ['A','B','C','D']" :key="k" :label="k" :value="k" /></el-select>
        </el-form-item>
      </el-form>
      <span slot="footer"><button type="button" class="primary" @click="host.createFault()">引入并开始配置</button></span>
    </el-dialog>

    <el-dialog title="引用关系" :visible.sync="host.refDlg" width="480px" custom-class="proto-dialog">
      <div v-if="host.refInfo">
        <div><b>{{ host.refInfo.code }}</b> {{ host.refInfo.name }}</div>
        <div class="hint">直接故障 {{ host.refInfo.directFaults }} · 命名组 {{ host.refInfo.inGroups }} · 分支 {{ host.refInfo.inBranches }}</div>
        <div v-for="f in host.refInfo.faults" :key="f.id">
          <button type="button" class="link" @click="host.gotoFault(f)">{{ f.cx }} / {{ f.ly }} / {{ f.gzdm }} {{ f.gzmc }}</button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { timingLabel } from '../../workbench/explain'
import GroupPreview from '../GroupPreview.vue'
/**
 * 前置、原子、命名组和故障的编辑弹窗。数据仍放在工作台宿主上，这里只负责原型样式的壳。
 */
export default {
  name: 'WorkbenchDialogs',
  components: { GroupPreview: GroupPreview },
  props: { host: { type: Object, required: true } },
  methods: { timing: timingLabel }
}
</script>
