<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { signup, googleLogin } from '../services/api'

const router = useRouter()
const route = useRoute()
const name = ref('')
const username = ref('')
const email = ref('')
const password = ref('')
const error = ref('')

async function doSignup() {
  error.value = ''
  try {
    await signup(email.value, username.value, password.value, name.value)
    const next = (route.query.next as string) || '/'
    router.replace(next)
  } catch (e: any) { error.value = e.message || 'فشل التسجيل' }
}
</script>

<template>
  <div class="max-w-md mx-auto p-6 space-y-4">
    <div class="flex items-center gap-2 text-sm">
      <button class="text-gray-300 hover:underline" @click="$router.back()">رجوع</button>
    </div>
    <h1 class="text-2xl font-bold">إنشاء حساب</h1>
  <button class="w-full rounded-xl px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-bold" @click="googleLogin((route.query.next as string) || '/')">Google</button>
    <div class="rounded-2xl border border-white/10 bg-slate-900/50 p-5 space-y-2">
      <input v-model="name" placeholder="الاسم" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <input v-model="username" placeholder="اسم المستخدم" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <input v-model="email" placeholder="البريد الإلكتروني" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <input v-model="password" type="password" placeholder="كلمة المرور" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <button class="w-full rounded-xl px-4 py-2 bg-slate-800/60 hover:bg-slate-700/60 border border-white/10" @click="doSignup">تسجيل</button>
      <div class="text-xs text-gray-400">لديك حساب؟ <router-link class="text-indigo-400" :to="{ name: 'login', query: route.query }">تسجيل الدخول</router-link></div>
      <div class="text-red-400 text-sm" v-if="error">{{ error }}</div>
    </div>
  </div>
</template>
