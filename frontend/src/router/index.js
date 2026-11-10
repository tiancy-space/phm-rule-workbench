import Vue from 'vue'
import VueRouter from 'vue-router'
import Workbench from '../views/Workbench.vue'

Vue.use(VueRouter)

/**
 * 使用 hash 模式，静态托管不需要服务端回退到 index.html。
 */
export default new VueRouter({
  mode: 'hash',
  routes: [
    { path: '/', name: 'workbench', component: Workbench }
  ]
})
