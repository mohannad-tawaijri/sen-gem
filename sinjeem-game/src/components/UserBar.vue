<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch } from 'vue'
import { me, logout } from '../services/api'
import { useRouter, useRoute } from 'vue-router'
const user = ref<any>(null)
const router = useRouter()
const route = useRoute()
async function refresh(){
  try {
    const data = await me();
    user.value = (data && (data as any).user !== undefined) ? (data as any).user : null
  } catch { user.value = null }
}
onMounted(() => {
  refresh()
  window.addEventListener('auth:changed', refresh)
})
onUnmounted(() => {
  window.removeEventListener('auth:changed', refresh)
})
watch(() => route.fullPath, refresh)
async function doLogout(){
  await logout();
  user.value = null;
  const q: any = { ...route.query, _r: Date.now().toString() };
  router.replace({ path: route.fullPath, query: q })
  window.dispatchEvent(new CustomEvent('auth:changed', { detail: 'logout' }))
}
</script>

<template>
  <div class="w-full px-4 py-3 flex items-center justify-between bg-slate-900/50 backdrop-blur border-b border-white/5">
    <div class="font-extrabold tracking-tight">سين جيم</div>
    <div>
      <template v-if="user">
  <span class="mr-3 text-sm text-gray-200">مرحبًا، <span class="font-semibold">{{ user.name || user.username || user.email }}</span></span>
  <button class="ml-3 rounded-lg px-3 py-1.5 text-sm border border-white/10 bg-slate-800/60 hover:bg-slate-700/60" @click="doLogout">خروج</button>
      </template>
      <template v-else>
  <button class="rounded-lg px-3 py-1.5 text-sm border border-white/10 bg-slate-800/60 hover:bg-slate-700/60" @click="router.push({ name: 'auth', query: { next: route.fullPath, mode: 'login' } })">دخول</button>
      </template>
    </div>
  </div>
  
</template>
