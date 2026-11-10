<template>
  <div class="page" @keydown="onKey">
    <header class="top">
      <div class="brand">
        <div>
          <b>{{ $t('appTitle') }}</b>
          <span class="tag mode">正式系统</span>
        </div>
        <div class="muted">规则按车型 + 来源 + 故障代码维护，表达式在服务端解析</div>
      </div>
      <div class="actions">
        <el-button @click="preOpen = true">{{ $t('pre') }}（{{ enabledPre }} 条生效）</el-button>
        <el-button @click="openFlow()">▤ {{ $t('flow') }}</el-button>
        <el-button @click="library = true">{{ $t('library') }}</el-button>
      </div>
      <div class="stats" v-if="stats">
        <span>故障底账 <b>{{ stats.faults }}</b></span>
        <span>组合判定 <b>{{ stats.conditional }}</b></span>
        <span>直接报出 <b>{{ stats.direct }}</b></span>
        <span>停用 <b>{{ stats.disabled }}</b></span>
        <span>共享原子 <b>{{ stats.atoms }}</b></span>
        <span>命名组 <b>{{ stats.groups }}</b></span>
        <span>处置流程 <b>{{ stats.flows }}</b></span>
        <span>生效前置 <b>{{ stats.enabledPres }}</b></span>
      </div>
    </header>
    <div class="cols">
      <aside class="panel col left scroll">
        <div class="colhead">
          <b>01 / 故障底账</b>
          <span class="muted">{{ filtered.length }} / {{ faults.length }}</span>
          <el-button type="text" @click="faultDlg = true">＋ 新增条目</el-button>
        </div>
        <el-select v-model="filters.cx" clearable placeholder="全部车型" style="width:100%;margin-bottom:6px">
          <el-option v-for="c in cxOptions" :key="c" :label="c" :value="c" />
        </el-select>
        <el-select v-model="filters.mode" clearable placeholder="全部判定模式" style="width:100%;margin-bottom:6px">
          <el-option v-for="m in modeOptions" :key="m.value" :label="m.label" :value="m.value" />
        </el-select>
        <el-radio-group v-model="filters.ly" size="mini" style="margin-bottom:6px">
          <el-radio-button label="">全部</el-radio-button>
          <el-radio-button label="TCMS">TCMS</el-radio-button>
          <el-radio-button label="6A">6A</el-radio-button>
        </el-radio-group>
        <div class="seg">
          <button :class="{on:!filters.cz}" @click="filters.cz=''">全部</button>
          <button :class="{on:filters.cz==='CHECK'}" @click="filters.cz='CHECK'">排查 {{ countCz('CHECK') }}</button>
          <button :class="{on:filters.cz==='WATCH'}" @click="filters.cz='WATCH'">关注 {{ countCz('WATCH') }}</button>
          <button :class="{on:filters.cz==='NONE'}" @click="filters.cz='NONE'">无需干预 {{ countCz('NONE') }}</button>
        </div>
        <el-input v-model="filters.q" placeholder="搜索代码 / 名称 / 模型" clearable style="margin:6px 0" />
        <div v-for="f in filtered" :key="f.id" class="fcard" :class="{active: draft && draft.id===f.id}" @click="pick(f)">
          <div class="row">
            <b>{{ f.gzdm }}</b>
            <span class="tag" :class="'cz-'+f.czdj">{{ czLabel(f.czdj) }}</span>
            <span class="muted">{{ f.cx }} · {{ f.ly }}</span>
          </div>
          <div>{{ f.gzmc }}</div>
          <div class="muted">{{ f.mxmc || '—' }} · 健康 {{ f.jkdj }}</div>
          <div class="muted">{{ modeLabel(f.ruleMode) }}<template v-if="f.ruleMode==='CONDITIONAL'"> · {{ f.refCount }} 个条件</template></div>
          <div>
            <span v-if="f.flowId" class="tag mode">▤ {{ f.flowStatus==='PUBLISHED' ? ('处置流程 v'+f.pubVerNo) : '处置流程 草稿' }}</span>
            <span v-if="f.skipCount" class="tag">前置豁免 {{ f.skipCount }} 项</span>
          </div>
        </div>
      </aside>
      <main class="panel col mid scroll" v-if="draft">
        <div class="path muted">故障底账 / {{ draft.cx }} / {{ draft.ly }} / {{ draft.gzdm }}</div>
        <h2>{{ draft.cx }} · {{ draft.ly }} · {{ draft.gzdm }} {{ draft.gzmc }}</h2>
        <div class="grid">
          <label>判定模式
            <el-select v-model="draft.ruleMode" style="width:100%">
              <el-option v-for="m in modeOptions" :key="m.value" :label="m.label" :value="m.value" />
            </el-select>
          </label>
          <label>所属模型名称 <el-input v-model="draft.mxmc" /></label>
          <label>健康等级
            <el-select v-model="draft.jkdj" style="width:100%">
              <el-option v-for="k in ['A','B','C','D']" :key="k" :label="k" :value="k" />
            </el-select>
          </label>
        </div>
        <div class="czbox">
          <label>故障处置等级
            <el-select v-model="draft.czdj">
              <el-option label="排查" value="CHECK" />
              <el-option label="关注" value="WATCH" />
              <el-option label="无需干预" value="NONE" />
            </el-select>
          </label>
          <div>
            <span class="tag" :class="'cz-'+draft.czdj">{{ czLabel(draft.czdj) }}</span>
            {{ czDesc(draft.czdj) }}
            <span v-if="dirty" class="tag">保存后生效</span>
            <div class="muted">处置流程：
              <template v-if="draft.czdj==='NONE'">无需干预类故障不配处置流程</template>
              <template v-else-if="draft.flowId">
                <span class="ok">● 已配置 · {{ draft.flowStatus==='PUBLISHED' ? ('已发布 v'+draft.pubVerNo) : '草稿' }} · {{ draft.stepCount }} 步</span>
                <el-button type="text" @click="openFlow(draft.id)">查看 / 编辑处置流程</el-button>
              </template>
              <template v-else>
                <span>○ 未配置处置流程</span>
                <el-button type="text" @click="openFlow(draft.id)">＋ 配置处置流程</el-button>
              </template>
            </div>
          </div>
        </div>
        <template v-if="draft.ruleMode==='DIRECT' || draft.ruleMode==='DISABLED'">
          <div class="ck">
            <h2>{{ modeLabel(draft.ruleMode) }}</h2>
            <p>{{ draft.ruleMode==='DIRECT' ? '不执行故障组合条件，前置过滤通过后直接报出。' : '此故障已停止输出，不进入后续判定与报出流程。' }}</p>
            <span class="muted">已有组合草稿会保留，切换回条件组合即可继续编辑。</span>
          </div>
        </template>
        <template v-else>
        <h3>1 已引入的原子 / 命名组</h3>
        <div v-for="r in draft.refs" :key="r.alias" class="refrow">
          <b>{{ r.alias }}</b>
          <span v-if="r.refType==='GROUP'" class="tag" style="color:#6d28d9">◆</span>
          {{ r.code }} {{ r.name }}
          <span class="mono muted">{{ r.expr }}</span>
          <el-button type="text" @click="editRef(r)">编辑</el-button>
          <el-button type="text" @click="removeRef(r)">移除</el-button>
        </div>
        <el-button size="mini" @click="atomDlg = freshAtom()">＋ 顺手新建</el-button>
        <h3>2 逻辑与括号拼装器</h3>
        <div class="tokens">
          <el-button v-for="r in draft.refs" :key="r.alias" size="mini" @click="insert(r.alias)">＋ {{ r.alias }}</el-button>
          <el-button size="mini" @click="insert(' & ')">且 (&)</el-button>
          <el-button size="mini" @click="insert(' | ')">或 (|)</el-button>
          <el-button size="mini" @click="insert('(')">(</el-button>
          <el-button size="mini" @click="insert(')')">)</el-button>
          <el-button size="mini" @click="allAnd">全且</el-button>
          <el-button size="mini" @click="allOr">全或</el-button>
          <el-button size="mini" @click="draft.ruleExpr=''">清空</el-button>
        </div>
        <el-input type="textarea" :rows="3" v-model="draft.ruleExpr" class="mono" />
        <div v-if="preview && preview.ok" class="ok">✓ 语法校验通过</div>
        <div v-else-if="preview && draft.ruleExpr" class="bad">第 {{ (preview.pos||0)+1 }} 字符：{{ preview.message }}</div>
        <div v-if="preview && preview.ok && preview.canonicalExpr && preview.canonicalExpr!==draft.ruleExpr" class="muted">
          规范写法：<code>{{ preview.canonicalExpr }}</code>
          <el-button type="text" @click="draft.ruleExpr=preview.canonicalExpr">一键应用</el-button>
        </div>
        <div class="vizhead">
          <span class="muted">可视化逻辑结构</span>
          <div class="row">
            <el-button v-if="viz==='ladder'" size="mini" @click="bigOpen=true">展开大图</el-button>
            <el-button size="mini" @click="setNamed(true)">展开命名组</el-button>
            <el-button size="mini" @click="setNamed(false)">折叠命名组</el-button>
            <el-radio-group v-model="viz" size="mini">
              <el-radio-button label="list">分组清单</el-radio-button>
              <el-radio-button label="ladder">梯形图</el-radio-button>
            </el-radio-group>
          </div>
        </div>
        <div v-if="viz==='list'" class="ck">
          <div v-for="(line,i) in descLines" :key="i">{{ line }}</div>
          <div v-if="!descLines.length" class="muted">写好组合式后这里显示中文结构</div>
        </div>
        <div v-else class="ladderbox" v-html="ladderHtml" @click="onLadder"></div>
        <p v-if="viz==='ladder'" class="muted">左右为母线；串联触点＝同时满足（且），上下并联支路＝满足其一（或）；◆ 命名条件组点击可折叠 / 展开。</p>
        <el-tabs v-model="tab">
          <el-tab-pane label="中文判定逻辑释义" name="cn">
            <div v-if="draft.inheritedFilters && draft.inheritedFilters.length" class="muted">继承前置：</div>
            <div v-for="p in draft.inheritedFilters" :key="p.id">{{ p.filterName }} · <span class="mono">{{ p.filterExpr }}</span></div>
            <pre class="pre">{{ preview && preview.ruleDesc }}</pre>
          </el-tab-pane>
          <el-tab-pane label="零 JSON 规则表达式预览" name="json">
            <div class="muted">入库表达式（引擎执行）</div>
            <pre class="pre">{{ preview && preview.faultRule }}</pre>
            <div class="muted">引用式 · 仅供阅读</div>
            <pre class="pre">{{ preview && preview.refExpr }}</pre>
            <div class="muted">判定模式 {{ modeLabel(draft.ruleMode) }} · 豁免 {{ (draft.skips||[]).length }} 项</div>
            <div class="muted">零 JSON 反解析校验</div>
            <el-input type="textarea" :rows="3" v-model="checkText" @input="runCheck" />
            <div v-if="checkResult && checkResult.ok" class="ok">✓ 反解析通过 · {{ checkResult.condCount }} 个条件 · 参数 {{ (checkResult.fields||[]).join('、') || '无' }} · 时间窗 {{ checkResult.windowCount || 0 }} 个
              <template v-if="checkResult.sameAsExpect"> · 与当前组合生成结果逐字一致</template>
            </div>
            <div v-else-if="checkResult && checkText" class="bad">第 {{ (checkResult.pos||0)+1 }} 字符：{{ checkResult.message }}</div>
          </el-tab-pane>
          <el-tab-pane label="模拟测点试算验证" name="sim">
            <el-button size="mini" @click="fill(true)">填充命中样例</el-button>
            <el-button size="mini" @click="fill(false)">填充未命中样例</el-button>
            <el-button size="mini" type="primary" @click="runSim">执行模拟试算</el-button>
            <div class="grid" style="margin-top:8px">
              <label v-for="field in simFields" :key="field">{{ field }}
                <el-input v-model="simValues[field]" />
              </label>
            </div>
            <div v-for="w in simWindows" :key="w">
              <el-checkbox v-model="simWindowsState[w]">出现过 {{ w }}</el-checkbox>
            </div>
            <div v-if="simResult" :class="simResult.hit ? 'ok' : 'bad'">{{ simResult.summary }}</div>
            <div v-for="row in (simResult && simResult.rows) || []" :key="row.kind+row.code+row.text">
              <span :class="row.ok ? 'ok' : 'bad'">{{ row.ok ? '通过' : '未通过' }}</span>
              {{ row.code }} {{ row.text }}
            </div>
          </el-tab-pane>
        </el-tabs>
        </template>
        <h3>◈ 通用前置规则 · 继承 {{ (draft.inheritedFilters||[]).length }} 项
          <el-button type="text" @click="skipOpen=!skipOpen">{{ skipOpen ? '收起' : '管理单条豁免' }}</el-button>
        </h3>
        <div v-if="skipOpen">
          <el-checkbox-group v-model="draft.skipFilterIds">
            <div v-for="p in pres" :key="p.id">
              <el-checkbox :label="p.id">{{ p.filterName }} <span class="mono">{{ p.filterExpr }}</span>
                <span v-if="draft.skipFilterIds.indexOf(p.id)>=0">（豁免）</span>
              </el-checkbox>
            </div>
          </el-checkbox-group>
        </div>
        <div class="savebar">
          <span :class="dirty ? 'bad' : 'ok'">{{ dirty ? '● 未保存修改' : '✓ 已保存' }}</span>
          <div>
            <el-button @click="reset">{{ $t('reset') }}</el-button>
            <el-button type="primary" @click="save">{{ $t('save') }}</el-button>
          </div>
        </div>
      </main>
      <main v-else class="panel col mid"><div class="muted" style="padding:24px">选择左侧故障开始维护</div></main>
      <aside class="panel col right scroll">
        <div class="colhead"><b>03 / 共享原子规则池</b></div>
        <el-radio-group v-model="poolKind" size="mini">
          <el-radio-button label="atom">原子条件</el-radio-button>
          <el-radio-button label="group">命名条件组</el-radio-button>
        </el-radio-group>
        <div style="margin:6px 0">
          <el-select v-model="poolScope" size="mini" style="width:180px">
            <el-option label="适配当前车型" value="FIT" />
            <el-option label="全库全部车型" value="ALL" />
          </el-select>
          <el-button size="mini" type="primary" @click="poolKind==='atom' ? (atomDlg=freshAtom()) : (groupDlg=freshGroup())">＋ 新建</el-button>
        </div>
        <el-input v-model="poolQ" placeholder="搜索" size="mini" clearable />
        <template v-if="poolKind==='atom'">
          <div v-for="a in poolAtoms" :key="a.id" class="pcard">
            <div><b>{{ a.atomCode }}</b> <span class="muted">{{ a.scopeCx }} · {{ a.atomType==='WINDOW'?'时间窗':'参数比较' }}</span></div>
            <div>{{ a.atomName }}</div>
            <div class="mono muted">{{ a.atomExpr }}</div>
            <el-button type="text" :disabled="used(a.atomCode)" @click="useAtom(a)">{{ used(a.atomCode) ? '✓ 已引用' : '＋ 引用到当前故障' }}</el-button>
            <el-button type="text" @click="atomDlg=editAtom(a)">编辑</el-button>
            <el-button type="text" @click="showRef('atom', a.id)">引用</el-button>
          </div>
        </template>
        <template v-else>
          <div v-for="g in poolGroups" :key="g.id" class="pcard">
            <div><b>{{ g.groupCode }}</b> {{ g.groupName }}</div>
            <div class="mono muted">{{ g.groupExpr }}</div>
            <div class="mono">{{ g.expandExpr }}</div>
            <el-button type="text" :disabled="used(g.groupCode)" @click="useGroup(g)">{{ used(g.groupCode) ? '✓ 已引用' : '＋ 引用到当前故障' }}</el-button>
            <el-button type="text" @click="groupDlg=editGroup(g)">编辑</el-button>
            <el-button type="text" @click="showRef('group', g.id)">引用</el-button>
          </div>
        </template>
      </aside>
    </div>

    <el-drawer title="通用前置故障规则" :visible.sync="preOpen" size="460px">
      <div style="padding:0 16px 16px">
        <el-button size="mini" type="primary" @click="preForm=freshPre()">＋ 新增前置规则</el-button>
        <div v-for="p in pres" :key="p.id" class="pcard">
          <div class="row">
            <b>{{ p.filterName }}</b>
            <el-switch :value="p.isEnabled===1" @change="togglePre(p, $event)" />
          </div>
          <div class="mono">{{ p.filterExpr }}</div>
          <div class="muted">{{ p.scopeCx }} / {{ p.scopeLy }} · {{ p.execTiming }} · 优先级 {{ p.priority }}</div>
          <el-button type="text" @click="preForm=editPre(p)">编辑</el-button>
          <el-button type="text" @click="removePre(p)">删除</el-button>
        </div>
      </div>
    </el-drawer>

    <el-dialog :title="preForm && preForm.id ? '编辑前置规则' : '新增前置规则'" :visible.sync="preFormVisible" width="520px" v-if="preForm">
      <el-form label-width="110px" size="small">
        <el-form-item label="规则名称"><el-input v-model="preForm.filterName" /></el-form-item>
        <el-form-item label="协议指标">
          <el-select v-model="preForm.paramCol" filterable style="width:100%">
            <el-option v-for="p in params" :key="p.id" :label="p.paramName+' '+p.paramCol" :value="p.paramCol" />
          </el-select>
        </el-form-item>
        <el-form-item label="比较符">
          <el-select v-model="preForm.cmpOp" style="width:100%"><el-option v-for="o in ops" :key="o" :label="o" :value="o" /></el-select>
        </el-form-item>
        <el-form-item label="目标值"><el-input v-model="preForm.cmpVal" /></el-form-item>
        <el-form-item label="适用车型"><el-input v-model="preForm.scopeCx" placeholder="ALL 或 HXD1C,HXD1D" /></el-form-item>
        <el-form-item label="适用来源">
          <el-select v-model="preForm.scopeLy" style="width:100%"><el-option v-for="x in ['ALL','TCMS','6A']" :key="x" :label="x" :value="x" /></el-select>
        </el-form-item>
        <el-form-item label="执行时机">
          <el-select v-model="preForm.execTiming" style="width:100%">
            <el-option label="查 HBase 前短路拦截" value="BEFORE_HBASE" />
            <el-option label="查 HBase 后拦截" value="AFTER_HBASE" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级"><el-input-number v-model="preForm.priority" :min="1" /></el-form-item>
      </el-form>
      <span slot="footer"><el-button type="primary" @click="savePre">保存前置规则</el-button></span>
    </el-dialog>

    <el-dialog :title="atomDlg && atomDlg.id ? '编辑原子规则' : '新建原子规则'" :visible.sync="atomVisible" width="560px">
      <el-form v-if="atomDlg" label-width="120px" size="small">
        <el-form-item label="原子类型">
          <el-radio-group v-model="atomDlg.atomType">
            <el-radio label="PARAM">参数测点比较</el-radio>
            <el-radio label="WINDOW">关联故障时间窗</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="适用车型"><el-input v-model="atomDlg.scopeCx" placeholder="ALL 或车型" /></el-form-item>
        <template v-if="atomDlg.atomType==='PARAM'">
          <el-form-item label="协议参数">
            <el-select v-model="atomDlg.paramCol" filterable style="width:100%">
              <el-option v-for="p in params" :key="p.paramCol+p.id" :label="p.paramName+' '+p.paramCol" :value="p.paramCol" />
            </el-select>
          </el-form-item>
          <el-form-item label="比较符">
            <el-select v-model="atomDlg.cmpOp" style="width:100%"><el-option v-for="o in ops" :key="o" :label="o" :value="o" /></el-select>
          </el-form-item>
          <el-form-item label="目标值"><el-input v-model="atomDlg.cmpVal" placeholder="缺失值写 -" /></el-form-item>
        </template>
        <template v-else>
          <el-form-item label="时间窗函数">
            <el-select v-model="atomDlg.winFn" style="width:100%">
              <el-option v-for="f in winFns" :key="f" :label="f" :value="f" />
            </el-select>
          </el-form-item>
          <el-form-item label="窗口秒数"><el-input-number v-model="atomDlg.winSec" :min="1" /></el-form-item>
          <el-form-item label="关联故障代码"><el-input v-model="atomDlg.relGzdm" placeholder="逗号分隔" /></el-form-item>
        </template>
        <el-form-item label="名称"><el-input v-model="atomDlg.atomName" placeholder="留空则自动生成" /></el-form-item>
      </el-form>
      <span slot="footer"><el-button type="primary" @click="saveAtom">保存共享定义</el-button></span>
    </el-dialog>

    <el-dialog :title="groupDlg && groupDlg.id ? '编辑命名条件组' : '新建命名组'" :visible.sync="groupVisible" width="640px">
      <el-form v-if="groupDlg" label-width="100px" size="small">
        <el-form-item label="组名称"><el-input v-model="groupDlg.groupName" /></el-form-item>
        <el-form-item label="适用车型"><el-input v-model="groupDlg.scopeCx" /></el-form-item>
        <el-form-item label="插入原子">
          <el-button v-for="a in atoms" :key="a.id" size="mini" @click="groupDlg.groupExpr=(groupDlg.groupExpr||'')+a.atomCode+' '">{{ a.atomCode }}</el-button>
        </el-form-item>
        <el-form-item label="组合式"><el-input type="textarea" :rows="3" v-model="groupDlg.groupExpr" @input="previewGroup" /></el-form-item>
        <div v-if="groupPreview && groupPreview.ok" class="ok">✓ {{ groupPreview.canonicalExpr }}</div>
        <pre v-if="groupPreview" class="pre">{{ groupPreview.faultRule }}</pre>
        <div class="muted">{{ groupPreview && groupPreview.ruleDesc }}</div>
        <div v-if="groupPreview && !groupPreview.ok" class="bad">{{ groupPreview.message }}</div>
      </el-form>
      <span slot="footer"><el-button type="primary" @click="saveGroup">保存命名组</el-button></span>
    </el-dialog>

    <el-dialog title="新增故障条目" :visible.sync="faultDlg" width="480px">
      <el-form label-width="90px" size="small">
        <el-form-item label="车型"><el-input v-model="newFault.cx" /></el-form-item>
        <el-form-item label="来源">
          <el-select v-model="newFault.ly"><el-option label="TCMS" value="TCMS" /><el-option label="6A" value="6A" /></el-select>
        </el-form-item>
        <el-form-item label="故障代码"><el-input v-model="newFault.gzdm" /></el-form-item>
        <el-form-item label="名称"><el-input v-model="newFault.gzmc" /></el-form-item>
        <el-form-item label="模型"><el-input v-model="newFault.mxmc" /></el-form-item>
        <el-form-item label="健康等级">
          <el-select v-model="newFault.jkdj"><el-option v-for="k in ['A','B','C','D']" :key="k" :label="k" :value="k" /></el-select>
        </el-form-item>
      </el-form>
      <span slot="footer"><el-button type="primary" @click="createFault">引入并开始配置</el-button></span>
    </el-dialog>

    <el-dialog title="原子规则库" :visible.sync="library" width="720px">
      <el-table :data="atoms" size="mini" height="360">
        <el-table-column prop="atomCode" label="编号" width="80" />
        <el-table-column prop="atomName" label="名称" />
        <el-table-column prop="atomExpr" label="表达式" />
        <el-table-column label="操作" width="80">
          <template slot-scope="s"><el-button type="text" @click="removeAtom(s.row)">删除</el-button></template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog title="引用关系" :visible.sync="refDlg" width="480px">
      <div v-if="refInfo">
        <div>{{ refInfo.code }} {{ refInfo.name }}</div>
        <div class="muted">直接故障 {{ refInfo.directFaults }} · 命名组 {{ refInfo.inGroups }} · 分支 {{ refInfo.inBranches }}</div>
        <div v-for="f in refInfo.faults" :key="f.id">
          <el-button type="text" @click="gotoFault(f)">{{ f.cx }} / {{ f.ly }} / {{ f.gzdm }} {{ f.gzmc }}</el-button>
        </div>
      </div>
    </el-dialog>

    <flow-board v-if="$store.state.flowOpen" @close="reloadAfterFlow" />
    <big-canvas :visible="bigOpen" :title="'故障 ' + (draft && draft.gzdm) + ' 梯形图'"
      :subtitle="draft ? (draft.cx + ' / ' + draft.ly + ' / ' + draft.gzmc) : ''"
      :svg="ladderHtml" legend="串联＝且，并联＝或，◆ 为命名组"
      hint="滚轮缩放 · 拖动平移 · 点击命名组折叠 · + - F 0 · Esc 关闭"
      :file-base="'故障' + (draft && draft.gzdm) + '_梯形图'"
      :caption="draft ? (draft.cx + ' / ' + draft.gzdm + ' ' + draft.gzmc) : ''"
      @close="bigOpen=false" @toggle="toggleNamed" />
  </div>
</template>

<script>
import http from '../api/http'
import { ladderSvg, checklistLines } from '../utils/ladder'
import FlowBoard from '../components/FlowBoard.vue'
import BigCanvas from '../components/BigCanvas.vue'

var MODES = [
  { value: 'CONDITIONAL', label: '条件组合判定' },
  { value: 'DIRECT', label: '直接报出' },
  { value: 'DISABLED', label: '停用过滤' },
  { value: 'PENDING', label: '待配置规则' }
]
var OPS = ['==', '!=', '>', '>=', '<', '<=', 'IN', 'NOT IN', '=~']
var WINS = ['allNotExists', 'anyExists', 'allExists', 'anyNotExists']

export default {
  name: 'Workbench',
  components: { FlowBoard: FlowBoard, BigCanvas: BigCanvas },
  data: function () {
    return {
      stats: null, faults: [], atoms: [], groups: [], params: [], pres: [],
      filters: { cx: '', mode: '', ly: '', cz: '', q: '' },
      draft: null, saved: '', preview: null, timer: null,
      viz: 'list', tab: 'cn', skipOpen: false, namedOpen: {}, bigOpen: false,
      checkText: '', checkResult: null,
      simValues: {}, simWindowsState: {}, simResult: null,
      poolKind: 'atom', poolScope: 'FIT', poolQ: '',
      preOpen: false, preForm: null,
      atomDlg: null, groupDlg: null, groupPreview: null,
      faultDlg: false, newFault: { cx: 'HXD1C', ly: 'TCMS', gzdm: '', gzmc: '', mxmc: '', jkdj: 'D' },
      library: false, refDlg: false, refInfo: null,
      modeOptions: MODES, ops: OPS, winFns: WINS
    }
  },
  computed: {
    cxOptions: function () {
      var s = {}
      this.faults.forEach(function (f) { s[f.cx] = 1 })
      return Object.keys(s)
    },
    filtered: function () {
      var f = this.filters
      var q = (f.q || '').toLowerCase()
      return this.faults.filter(function (row) {
        if (f.cx && row.cx !== f.cx) return false
        if (f.mode && row.ruleMode !== f.mode) return false
        if (f.ly && row.ly !== f.ly) return false
        if (f.cz && row.czdj !== f.cz) return false
        if (q && (row.gzdm + row.gzmc + (row.mxmc || '')).toLowerCase().indexOf(q) < 0) return false
        return true
      })
    },
    dirty: function () {
      return this.draft && JSON.stringify(this.snapshot()) !== this.saved
    },
    enabledPre: function () {
      return this.pres.filter(function (p) { return p.isEnabled === 1 }).length
    },
    descLines: function () {
      return checklistLines(this.preview && this.preview.ruleDesc)
    },
    ladderHtml: function () {
      return this.preview && this.preview.display ? ladderSvg(this.preview.display, this.namedOpen, this.draft && this.draft.gzdm) : ''
    },
    poolAtoms: function () {
      var q = (this.poolQ || '').toLowerCase()
      var cx = this.draft ? this.draft.cx : ''
      var fit = this.poolScope === 'FIT'
      return this.atoms.filter(function (a) {
        if (fit && cx && a.scopeCx !== 'ALL' && a.scopeCx.split(',').map(function (s) { return s.trim() }).indexOf(cx) < 0) return false
        if (!q) return true
        return (a.atomCode + a.atomName + (a.atomExpr || '')).toLowerCase().indexOf(q) >= 0
      })
    },
    poolGroups: function () {
      var q = (this.poolQ || '').toLowerCase()
      return this.groups.filter(function (g) {
        return !q || (g.groupCode + g.groupName).toLowerCase().indexOf(q) >= 0
      })
    },
    simFields: function () {
      var text = (this.preview && this.preview.faultRule) || ''
      ;(this.draft && this.draft.inheritedFilters || []).forEach(function (p) { text += ' ' + (p.filterExpr || '') })
      var known = {}
      this.params.forEach(function (p) { known[p.paramCol] = 1 })
      var set = {}
      var re = /(^|[^A-Za-z0-9_])([A-Z][A-Z0-9_]*)(?![A-Za-z0-9_])/g
      var m
      while ((m = re.exec(text))) {
        if (known[m[2]]) set[m[2]] = 1
      }
      return Object.keys(set)
    },
    simWindows: function () {
      var out = []
      var self = this
      ;(this.draft && this.draft.refs || []).forEach(function (r) {
        if (r.refType !== 'ATOM') return
        var atom = self.atoms.filter(function (a) { return a.atomCode === r.code })[0]
        if (atom && atom.atomType === 'WINDOW') {
          String(atom.relGzdm || '').split(',').forEach(function (c) {
            if (c.trim()) out.push(atom.atomCode + ':' + c.trim())
          })
        }
      })
      return out
    },
    preFormVisible: {
      get: function () { return !!this.preForm },
      set: function (v) { if (!v) this.preForm = null }
    },
    atomVisible: {
      get: function () { return !!this.atomDlg },
      set: function (v) { if (!v) this.atomDlg = null }
    },
    groupVisible: {
      get: function () { return !!this.groupDlg },
      set: function (v) { if (!v) this.groupDlg = null }
    }
  },
  watch: {
    'draft.ruleExpr': function () { this.queuePreview() },
    'draft.refs': { deep: true, handler: function () { this.queuePreview() } }
  },
  mounted: function () {
    this.boot()
  },
  methods: {
    boot: function () {
      var self = this
      return Promise.all([
        http.get('/api/stats'), http.get('/api/faults'), http.get('/api/atoms'),
        http.get('/api/groups'), http.get('/api/params', { params: { pageSize: 500 } }), http.get('/api/pre-filters')
      ]).then(function (all) {
        self.stats = all[0]
        self.faults = all[1]
        self.atoms = all[2]
        self.groups = all[3]
        self.params = all[4].records || []
        self.pres = all[5]
        if (!self.draft && self.faults.length) {
          var prefer = self.faults.filter(function (f) { return f.gzdm === '1873' && f.cx === 'HXD1C' })[0] || self.faults[0]
          self.pick(prefer, true)
        }
      }).catch(this.fail)
    },
    pick: function (row, force) {
      var self = this
      if (!force && this.dirty) {
        this.$confirm('当前故障有未保存修改，切换将放弃这些修改。继续？', '未保存', { type: 'warning' }).then(function () {
          self.load(row.id)
        }).catch(function () {})
        return
      }
      this.load(row.id)
    },
    load: function (id) {
      var self = this
      http.get('/api/faults/' + id).then(function (d) {
        d.skipFilterIds = (d.skips || []).map(function (s) { return s.filterId })
        d.refs = d.refs || []
        self.draft = d
        self.saved = JSON.stringify(self.snapshot())
        self.simResult = null
        self.queuePreview()
      }).catch(this.fail)
    },
    snapshot: function () {
      var d = this.draft
      return {
        ruleMode: d.ruleMode, czdj: d.czdj, jkdj: d.jkdj, mxmc: d.mxmc || '',
        ruleExpr: d.ruleExpr || '', configNote: d.configNote || '',
        refs: (d.refs || []).map(function (r) { return r.refType + ':' + r.code }),
        skips: (d.skipFilterIds || []).slice().sort()
      }
    },
    queuePreview: function () {
      var self = this
      clearTimeout(this.timer)
      this.timer = setTimeout(function () { self.runPreview() }, 250)
    },
    runPreview: function () {
      if (!this.draft || !this.draft.ruleExpr) { this.preview = null; return }
      var self = this
      http.post('/api/expr/preview', {
        gzdm: this.draft.gzdm,
        ruleExpr: this.draft.ruleExpr,
        refs: (this.draft.refs || []).map(function (r) { return { refType: r.refType, code: r.code } })
      }).then(function (r) { self.preview = r }).catch(function (e) {
        self.preview = { ok: false, message: e.message, pos: 0 }
      })
    },
    save: function () {
      var self = this
      var d = this.draft
      http.put('/api/faults/' + d.id, {
        rev: d.rev, ruleMode: d.ruleMode, czdj: d.czdj, jkdj: d.jkdj, mxmc: d.mxmc,
        ruleExpr: d.ruleExpr, configNote: d.configNote,
        refs: (d.refs || []).map(function (r) { return { refType: r.refType, code: r.code } }),
        skipFilterIds: d.skipFilterIds || []
      }).then(function () {
        self.$message.success('故障 ' + d.gzdm + ' 规则已保存')
        return self.boot().then(function () { return self.load(d.id) })
      }).catch(this.fail)
    },
    reset: function () {
      if (this.draft) this.load(this.draft.id)
    },
    toggleNamed: function (code) {
      if (!code) return
      var next = Object.assign({}, this.namedOpen)
      next[code] = next[code] === false
      this.namedOpen = next
    },
    setNamed: function (open) {
      var next = {}
      var walk = function (n) {
        if (!n) return
        if (n.type === 'named' && n.code) next[n.code] = open
        ;(n.children || []).forEach(walk)
        walk(n.child)
      }
      if (this.preview && this.preview.display) walk(this.preview.display)
      this.namedOpen = next
    },
    onLadder: function (e) {
      var node = e.target.closest && e.target.closest('[data-code]')
      if (node) this.toggleNamed(node.getAttribute('data-code'))
    },
    insert: function (token) { this.draft.ruleExpr = (this.draft.ruleExpr || '') + token },
    allAnd: function () { this.draft.ruleExpr = (this.draft.refs || []).map(function (r) { return r.alias }).join(' & ') },
    allOr: function () { this.draft.ruleExpr = (this.draft.refs || []).map(function (r) { return r.alias }).join(' | ') },
    used: function (code) {
      return (this.draft && this.draft.refs || []).some(function (r) { return r.code === code })
    },
    useAtom: function (a) { this.pushRef('ATOM', a.atomCode, a.atomName, a.atomExpr, a.scopeCx) },
    useGroup: function (g) { this.pushRef('GROUP', g.groupCode, g.groupName, g.expandExpr, g.scopeCx) },
    pushRef: function (type, code, name, expr, scope) {
      if (!this.draft || this.used(code)) return
      var n = this.draft.refs.length + 1
      this.draft.refs.push({ alias: 'A' + n, seqNo: n, refType: type, code: code, name: name, expr: expr, scopeCx: scope })
    },
    removeRef: function (r) {
      this.draft.refs = this.draft.refs.filter(function (x) { return x !== r })
      this.draft.refs.forEach(function (x, i) { x.seqNo = i + 1; x.alias = 'A' + (i + 1) })
    },
    editRef: function (r) {
      if (r.refType === 'GROUP') {
        var g = this.groups.filter(function (x) { return x.groupCode === r.code })[0]
        if (g) this.groupDlg = this.editGroup(g)
      } else {
        var a = this.atoms.filter(function (x) { return x.atomCode === r.code })[0]
        if (a) this.atomDlg = this.editAtom(a)
      }
    },
    runCheck: function () {
      var self = this
      http.post('/api/expr/check', { text: this.checkText, expect: this.preview && this.preview.faultRule }).then(function (r) {
        self.checkResult = r
      }).catch(function (e) { self.checkResult = { ok: false, message: e.message, pos: 0 } })
    },
    runSim: function () {
      var self = this
      http.post('/api/faults/' + this.draft.id + '/simulate', { values: this.simValues, windows: this.simWindowsState }).then(function (r) {
        self.simResult = r
      }).catch(this.fail)
    },
    fill: function (want) {
      var self = this
      http.post('/api/faults/' + this.draft.id + '/sim-sample?wantHit=' + want, {}).then(function (r) {
        self.simValues = Object.assign({}, r.values || {})
        self.simWindowsState = Object.assign({}, r.windows || {})
        self.simResult = r
      }).catch(this.fail)
    },
    freshAtom: function () {
      return { atomType: 'PARAM', scopeCx: 'ALL', paramCol: '', cmpOp: '>=', cmpVal: '', winFn: 'allNotExists', winSec: 10, relGzdm: '', atomName: '' }
    },
    editAtom: function (a) {
      return { id: a.id, rev: a.rev, atomType: a.atomType, scopeCx: a.scopeCx, paramCol: a.paramCol, cmpOp: a.cmpOp, cmpVal: a.cmpVal, winFn: a.winFn, winSec: a.winSec, relGzdm: a.relGzdm, atomName: a.atomName }
    },
    saveAtom: function () {
      var self = this
      var req = this.atomDlg
      var call = req.id ? http.put('/api/atoms/' + req.id, req) : http.post('/api/atoms', req)
      call.then(function (a) {
        self.$message.success(req.id ? '共享原子已更新，所有引用方同步生效' : '已保存 ' + a.atomCode)
        self.atomDlg = null
        if (!req.id && self.draft) self.pushRef('ATOM', a.atomCode, a.atomName, a.atomExpr, a.scopeCx)
        return self.boot()
      }).catch(this.fail)
    },
    removeAtom: function (row) {
      var self = this
      http.delete('/api/atoms/' + row.id).then(function () { return self.boot() }).catch(this.fail)
    },
    freshGroup: function () { return { groupName: '', scopeCx: 'ALL', groupExpr: '' } },
    editGroup: function (g) { return { id: g.id, rev: g.rev, groupName: g.groupName, scopeCx: g.scopeCx, groupExpr: g.groupExpr } },
    previewGroup: function () {
      var self = this
      http.post('/api/groups/preview', { groupExpr: this.groupDlg.groupExpr }).then(function (r) { self.groupPreview = r }).catch(function (e) {
        self.groupPreview = { ok: false, message: e.message }
      })
    },
    saveGroup: function () {
      var self = this
      var req = this.groupDlg
      var call = req.id ? http.put('/api/groups/' + req.id, req) : http.post('/api/groups', req)
      call.then(function () {
        self.$message.success('命名组已保存')
        self.groupDlg = null
        return self.boot()
      }).catch(this.fail)
    },
    freshPre: function () {
      return { filterName: '', paramCol: '', cmpOp: '==', cmpVal: '', scopeCx: 'ALL', scopeLy: 'ALL', execTiming: 'BEFORE_HBASE', priority: 100 }
    },
    editPre: function (p) {
      return { id: p.id, rev: p.rev, filterName: p.filterName, paramCol: p.paramCol, cmpOp: p.cmpOp, cmpVal: p.cmpVal, scopeCx: p.scopeCx, scopeLy: p.scopeLy, execTiming: p.execTiming, priority: p.priority }
    },
    savePre: function () {
      var self = this
      var req = this.preForm
      var call = req.id ? http.put('/api/pre-filters/' + req.id, req) : http.post('/api/pre-filters', req)
      call.then(function () { self.preForm = null; return self.boot() }).catch(this.fail)
    },
    togglePre: function (p, on) {
      var self = this
      http.put('/api/pre-filters/' + p.id + '/enabled', { rev: p.rev, enabled: on }).then(function () { return self.boot() }).catch(this.fail)
    },
    removePre: function (p) {
      var self = this
      this.$confirm('删除前置规则「' + p.filterName + '」？', '确认').then(function () {
        return http.delete('/api/pre-filters/' + p.id).then(function () { return self.boot() })
      }).catch(function () {})
    },
    createFault: function () {
      var self = this
      http.post('/api/faults', this.newFault).then(function (d) {
        self.faultDlg = false
        self.newFault.gzdm = ''
        self.newFault.gzmc = ''
        return self.boot().then(function () { self.load(d.id) })
      }).catch(this.fail)
    },
    showRef: function (kind, id) {
      var self = this
      http.get('/api/' + (kind === 'atom' ? 'atoms' : 'groups') + '/' + id + '/references').then(function (r) {
        self.refInfo = r
        self.refDlg = true
      }).catch(this.fail)
    },
    gotoFault: function (f) {
      this.refDlg = false
      var row = this.faults.filter(function (x) { return x.id === f.id })[0]
      if (row) this.pick(row)
    },
    openFlow: function (id) {
      this.$store.commit('openFlow', id || (this.draft && this.draft.id))
    },
    reloadAfterFlow: function () {
      this.$store.commit('closeFlow')
      var id = this.draft && this.draft.id
      var self = this
      this.boot().then(function () { if (id) self.load(id) })
    },
    onKey: function (e) {
      if ((e.ctrlKey || e.metaKey) && e.key === 's') { e.preventDefault(); this.save() }
    },
    countCz: function (cz) { return this.faults.filter(function (f) { return f.czdj === cz }).length },
    czLabel: function (v) { return { CHECK: '排查', WATCH: '关注', NONE: '无需干预' }[v] || v },
    czDesc: function (v) { return { CHECK: '需按处置流程处置', WATCH: '司机留意、地面关注', NONE: '仅记录，不配处置流程' }[v] || '' },
    modeLabel: function (v) {
      var m = MODES.filter(function (x) { return x.value === v })[0]
      return m ? m.label : v
    },
    fail: function (e) { this.$message.error(e.message || '操作失败') }
  }
}
</script>

<style scoped>
.page { height:100%; display:flex; flex-direction:column; }
.top { background:#fff; border-bottom:1px solid var(--line); padding:10px 16px; }
.brand { display:flex; justify-content:space-between; align-items:center; }
.actions { margin:8px 0; display:flex; gap:8px; }
.stats { display:flex; gap:14px; color:#475569; }
.cols { flex:1; display:grid; grid-template-columns: 300px 1fr 320px; gap:10px; padding:10px; min-height:0; }
.col { padding:10px; min-height:0; }
.colhead { display:flex; justify-content:space-between; align-items:center; margin-bottom:6px; }
.fcard, .pcard, .refrow { border:1px solid var(--line); border-radius:8px; padding:8px; margin:6px 0; background:#fff; }
.fcard { cursor:pointer; }
.fcard.active { border-color:#2563eb; background:#eff6ff; }
.row { display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
.seg { display:flex; gap:4px; flex-wrap:wrap; }
.seg button { border:1px solid #cbd5e1; background:#fff; border-radius:6px; padding:3px 6px; }
.seg button.on { background:#2563eb; color:#fff; border-color:#2563eb; }
.grid { display:grid; grid-template-columns:1fr 1fr 1fr; gap:8px; }
.czbox { display:flex; gap:12px; padding:8px; background:#f8fafc; border-radius:8px; margin:8px 0; }
.tokens { display:flex; flex-wrap:wrap; gap:4px; margin-bottom:6px; }
.vizhead { display:flex; justify-content:space-between; margin-top:8px; }
.ck, .ladderbox, .pre { background:#f8fafc; border-radius:8px; padding:8px; white-space:pre-wrap; }
.savebar { position:sticky; bottom:0; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:8px 0; border-top:1px solid var(--line); }
h2 { margin:4px 0; font-size:16px; }
h3 { margin:12px 0 6px; font-size:13px; }
</style>
