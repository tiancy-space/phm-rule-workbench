import axios from 'axios'

/**
 * 后端地址在构建期由 VUE_APP_API_BASE 决定。开发时留空，走 vue.config.js 的 /api 代理。
 */
const http = axios.create({
  baseURL: process.env.VUE_APP_API_BASE || '',
  timeout: 30000
})

http.interceptors.response.use(function (res) {
  var body = res.data
  if (body && typeof body.code === 'number' && body.code !== 0) {
    var err = new Error(body.message || '请求失败')
    err.code = body.code
    return Promise.reject(err)
  }
  return body ? body.data : body
}, function (err) {
  var data = err.response && err.response.data
  var msg = data && data.message ? data.message : err.message
  var wrapped = new Error(msg || '网络错误')
  wrapped.code = data && data.code
  return Promise.reject(wrapped)
})

export default http
