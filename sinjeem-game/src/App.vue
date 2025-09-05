<script setup lang="ts">
// App.vue يدير التطبيق الرئيسي
import UserBar from './components/UserBar.vue'
</script>

<template>
  <div id="app" dir="rtl" class="min-h-screen bg-gradient-to-br from-slate-950 via-indigo-950 to-slate-900 text-slate-100">
    <!-- Decorative radial glows -->
    <div class="fixed inset-0 -z-10 pointer-events-none">
      <div class="absolute -top-24 -right-24 h-[28rem] w-[28rem] rounded-full bg-indigo-500/10 blur-3xl"></div>
      <div class="absolute -bottom-32 -left-20 h-[32rem] w-[32rem] rounded-full bg-fuchsia-500/10 blur-3xl"></div>
      <div class="absolute inset-0 [background-image:radial-gradient(60rem_30rem_at_50%_-20%,rgba(99,102,241,0.08),transparent)]"></div>
    </div>
    <UserBar />
    <router-view />
  </div>
  
</template>

<style scoped>
#app { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
</style>
