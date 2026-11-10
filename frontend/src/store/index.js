import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

/**
 * 工作台和处置流程共用的少量界面状态。业务数据仍以接口为准，不在这里做第二份底账。
 */
export default new Vuex.Store({
  state: {
    flowOpen: false,
    flowFaultId: null
  },
  mutations: {
    openFlow: function (state, faultId) {
      state.flowFaultId = faultId || null
      state.flowOpen = true
    },
    closeFlow: function (state) {
      state.flowOpen = false
    }
  }
})
