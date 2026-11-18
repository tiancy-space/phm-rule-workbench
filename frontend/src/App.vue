<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default { name: 'App' }
</script>

<style>
/* 高度交给原型样式。这里只保证根节点铺满视口。 */
html, body, #app { height: 100%; }
</style>
