module.exports = {
  publicPath: './',
  productionSourceMap: false,
  lintOnSave: false,
  devServer: {
    host: '0.0.0.0',
    port: Number(process.env.PORT) || 8081,
    proxy: {
      '/api': {
        target: process.env.VUE_APP_API_BASE || 'http://127.0.0.1:8080',
        changeOrigin: true
      }
    }
  }
}
