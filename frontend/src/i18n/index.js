import Vue from 'vue'
import VueI18n from 'vue-i18n'

Vue.use(VueI18n)

/**
 * 业务文案以中文为主。vue-i18n 8 已接入，目前只维护 zh，满足参考栈里的国际化组件。
 */
export default new VueI18n({
  locale: 'zh',
  messages: {
    zh: {
      appTitle: '机车 PHM 故障规则管理工作台',
      pre: '通用前置故障规则',
      flow: '处置流程管理',
      library: '原子规则库全量视图',
      save: '保存当前故障规则',
      reset: '重置修改'
    }
  }
})
