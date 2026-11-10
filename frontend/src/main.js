import Vue from 'vue'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import locale from 'element-ui/lib/locale/lang/zh-CN'
import App from './App.vue'
import router from './router'
import store from './store'
import i18n from './i18n'

Vue.use(ElementUI, { locale: locale, size: 'small' })
Vue.config.productionTip = false

new Vue({
  router: router,
  store: store,
  i18n: i18n,
  render: function (h) { return h(App) }
}).$mount('#app')
