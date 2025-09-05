<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { me, logout, googleLogin, login, signup } from '../services/api'

const user = ref<any>(null)
const route = useRoute()
const router = useRouter()
const email = ref('')
const username = ref('')
const password = ref('')
const name = ref('')
const error = ref('')

async function refresh() {
  try {
    const data = await me()
    user.value = (data && (data as any).user !== undefined) ? (data as any).user : null
  // If logged in and a next route exists, redirect quickly
    if (user.value) {
      const next = route.query.next as string | undefined
      if (next) {
        setTimeout(() => router.replace(next), 350)
      }
    }
  } catch (e:any) { error.value = e.message }
}

onMounted(refresh)

async function doLogin() {
  error.value = ''
  try {
  await login({ email: email.value || undefined, username: username.value || undefined }, password.value)
    window.dispatchEvent(new CustomEvent('auth:changed', { detail: 'login' }))
    await refresh()
  } catch (e:any) { error.value = e.message }
}

async function doSignup() {
  error.value = ''
  try {
  await signup(email.value, username.value, password.value, name.value)
    window.dispatchEvent(new CustomEvent('auth:changed', { detail: 'signup' }))
    await refresh()
  } catch (e:any) { error.value = e.message }
}

async function doLogout() {
  await logout()
  user.value = null
}

</script>

<template>
  <div class="max-w-lg mx-auto p-6 space-y-6">
    <h1 class="text-2xl font-bold">تسجيل الدخول</h1>

    <div v-if="user" class="space-y-5">
      <div class="rounded-2xl border border-white/10 bg-slate-900/50 p-5">
      <div class="flex items-center gap-3">
        <img v-if="user.picture" :src="user.picture" class="w-12 h-12 rounded-full" />
        <div class="leading-tight">
          <div class="text-lg font-extrabold">مرحبًا، {{ user.name || user.username || user.email }}</div>
          <div class="text-xs text-gray-400">{{ user.email }}</div>
        </div>
      </div>
      <div class="mt-4 flex items-center justify-between text-sm text-gray-300">
        <div>تم تسجيل الدخول بنجاح.</div>
        <button class="rounded-lg px-3 py-1.5 border border-white/10 bg-slate-800/60 hover:bg-slate-700/60" @click="doLogout">خروج</button>
      </div>
      </div>
    </div>

    <div v-else class="space-y-4">
      <button class="w-full rounded-xl px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-bold" @click="googleLogin((route.query.next as string) || '/')">تسجيل دخول Google</button>
      <div class="rounded-2xl border border-white/10 bg-slate-900/50 p-5 space-y-2">
        <input v-model="name" placeholder="الاسم (اختياري)" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
        <input v-model="username" placeholder="اسم المستخدم (للدخول أو التسجيل)" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
        <input v-model="email" placeholder="البريد الإلكتروني (للتسجيل)" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
        <input v-model="password" placeholder="كلمة المرور" type="password" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
        <div class="flex gap-2">
          <button class="rounded-xl px-4 py-2 bg-slate-800/60 hover:bg-slate-700/60 border border-white/10" @click="doLogin">دخول</button>
          <button class="rounded-xl px-4 py-2 bg-slate-800/60 hover:bg-slate-700/60 border border-white/10" @click="doSignup">تسجيل</button>
        </div>
        <div class="text-xs text-gray-400">أو استخدم الصفحة الموحّدة: <router-link class="text-indigo-400" :to="{ name: 'auth', query: { ...route.query, mode: 'login' } }">تسجيل الدخول</router-link> · <router-link class="text-indigo-400" :to="{ name: 'auth', query: { ...route.query, mode: 'signup' } }">إنشاء حساب</router-link></div>
        <div class="text-xs"><button class="text-gray-300 hover:underline" @click="router.back()">رجوع</button></div>
        <div class="text-red-400 text-sm" v-if="error">{{ error }}</div>
      </div>
    </div>
  </div>
</template>


