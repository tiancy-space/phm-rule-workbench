<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default { name: 'App' }
</script>

<style>
:root { --bg:#f5f7fa; --ink:#1e293b; --muted:#64748b; --line:#e2e8f0; --blue:#2563eb; }
html, body, #app { margin:0; height:100%; background:var(--bg); color:var(--ink); font:13px/1.55 "PingFang SC","Microsoft YaHei",sans-serif; }
* { box-sizing:border-box; }
.mono { font-family: Consolas, "Liberation Mono", monospace; }
.muted { color:var(--muted); }
.tag { display:inline-block; border-radius:999px; padding:0 7px; font-size:12px; line-height:18px; border:1px solid transparent; }
.cz-CHECK { background:#fef2f2; color:#b91c1c; }
.cz-WATCH { background:#fffbeb; color:#b45309; }
.cz-NONE { background:#f1f5f9; color:#475569; }
.mode { background:#eff6ff; color:#1d4ed8; }
.ok { color:#15803d; }
.bad { color:#dc2626; }
.warn { color:#b45309; }
.panel { background:#fff; border:1px solid var(--line); border-radius:10px; }
.scroll { overflow:auto; }
</style>
