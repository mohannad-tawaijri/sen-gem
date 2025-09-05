<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { login, signup, googleLogin, me, stats, resetSeen } from '../services/api'
import { loadQuestions } from '../services/questions'

const router = useRouter()
const route = useRoute()

const mode = ref<'signup' | 'login'>(route.query.mode === 'login' ? 'login' : 'signup')
watch(() => route.query.mode, (m) => { mode.value = m === 'login' ? 'login' : 'signup' })

// Shared
const error = ref('')
const nextTarget = ref<string>((route.query.next as string) || '')
const user = ref<any>(null)
// Filters & stats
const categories = ref<Array<{ slug: string; name: string }>>([])
const selectedCategory = ref<string>('') // '' means all
const remaining = ref<number | null>(null)
const total = ref<number | null>(null)

// Login state
const identifier = ref('') // email or username
const password = ref('')

// Signup state
const name = ref('')
const username = ref('')
const email = ref('')

async function doLogin() {
  error.value = ''
  try {
    const payload: any = {}
    if (identifier.value.includes('@')) payload.email = identifier.value
    else payload.username = identifier.value
  await login(payload, password.value)
  window.dispatchEvent(new CustomEvent('auth:changed', { detail: 'login' }))
    router.replace(nextTarget.value || '/')
  } catch (e: any) { error.value = e.message || 'فشل الدخول' }
}

async function doSignup() {
  error.value = ''
  try {
  await signup(email.value, username.value, password.value, name.value)
  window.dispatchEvent(new CustomEvent('auth:changed', { detail: 'signup' }))
    router.replace(nextTarget.value || '/')
  } catch (e: any) { error.value = e.message || 'فشل التسجيل' }
}

// If already logged in, skip this page
onMounted(async () => {
  try {
    const data = await me();
    if (data?.user) {
      user.value = data.user
      // Only redirect if an explicit 'next' exists
      if (nextTarget.value) router.replace(nextTarget.value)
      // Load categories for filters
      try {
        const cats = await loadQuestions()
        categories.value = cats.map(c => ({ slug: c.slug, name: c.name }))
        await refreshStats()
      } catch {}
    } else {
      user.value = null
    }
  } catch { user.value = null }
})

// Handle possible external logout (UserBar) by reloading user when URL changes
watch(() => route.fullPath, async () => {
  try {
    const data = await me();
    user.value = data?.user || null
    if (user.value) {
      await refreshStats()
    } else {
      remaining.value = null
    }
  } catch {
    user.value = null
    remaining.value = null
  }
})

watch(selectedCategory, async () => {
  await refreshStats()
})

async function refreshStats() {
  if (!user.value) { remaining.value = null; return }
  try {
  const s = await stats({ category: selectedCategory.value || undefined })
  remaining.value = s.remaining
  total.value = s.total
  } catch { remaining.value = null }
}

function goBack() {
  // Clearer back: if history available, go back; otherwise go home
  if (window.history.length > 1) router.back()
  else router.replace('/')
}

function switchTo(m: 'signup' | 'login') {
  router.replace({ path: '/auth', query: { ...route.query, mode: m, next: nextTarget.value } })
}
</script>

<template>
  <div class="max-w-md mx-auto p-6 space-y-4">
    <div class="flex items-center gap-3" v-if="!user">
      <button class="inline-flex items-center gap-2 rounded-full px-3 py-1.5 border border-white/20 bg-slate-900/60 hover:bg-slate-800/60 text-sm" @click="goBack">
        <span class="text-lg">←</span>
        <span>رجوع</span>
      </button>
    </div>

    <h1 class="text-2xl font-bold" v-if="mode==='signup'">إنشاء حساب</h1>
    <h1 class="text-2xl font-bold" v-else>تسجيل الدخول</h1>

  <!-- Google (only when not logged-in) -->
  <button v-if="!user" class="w-full rounded-xl px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-bold" @click="googleLogin(nextTarget)">Google</button>

    <!-- Logged-in card -->
    <div v-if="user" class="rounded-2xl border border-white/10 bg-slate-900/50 p-5 space-y-4">
      <div class="flex items-center gap-3">
        <img v-if="user.picture" :src="user.picture" class="w-10 h-10 rounded-full" />
        <div class="text-sm">
          <div class="font-semibold">مرحبًا، {{ user.name || user.username || user.email }}</div>
          <div class="text-gray-400 text-xs">{{ user.email }}</div>
        </div>
      </div>
      <div class="grid gap-3">
        <div class="flex flex-col gap-2">
          <label class="text-sm text-gray-300">الفئة</label>
          <select v-model="selectedCategory" class="w-full rounded-xl bg-slate-900/60 px-4 py-2 border border-white/10">
            <option value="">الكل</option>
            <option v-for="c in categories" :key="c.slug" :value="c.slug">{{ c.name }}</option>
          </select>
        </div>
        <div class="flex items-center gap-2">
          <button class="rounded-xl px-4 py-2 bg-slate-800/60 hover:bg-slate-700/60 border border-white/10" @click="resetSeen({ category: selectedCategory || undefined }).then(refreshStats)">تصفير</button>
          <button class="rounded-xl px-4 py-2 bg-slate-800/60 hover:bg-slate-700/60 border border-white/10" @click="router.replace('/')">الصفحة الرئيسية</button>
        </div>
        <div class="text-sm text-gray-300">
          باقي
          <span class="font-semibold">{{ remaining ?? '—' }}</span>
          من
          <span class="font-semibold">{{ total ?? '—' }}</span>
        </div>
      </div>
    </div>

    <!-- Signup form (default) -->
    <div v-else-if="mode==='signup'" class="rounded-2xl border border-white/10 bg-slate-900/50 p-5 space-y-2">
      <input v-model="name" placeholder="الاسم" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <input v-model="username" placeholder="اسم المستخدم" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <input v-model="email" placeholder="البريد الإلكتروني" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <input v-model="password" type="password" placeholder="كلمة المرور" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <button class="w-full rounded-xl px-4 py-2 bg-slate-800/60 hover:bg-slate-700/60 border border-white/10" @click="doSignup">تسجيل</button>
      <div class="text-xs text-gray-400">لديك حساب؟ <a class="text-indigo-400 hover:underline" href="#" @click.prevent="switchTo('login')">تسجيل الدخول</a></div>
      <div class="text-red-400 text-sm" v-if="error">{{ error }}</div>
    </div>

    <!-- Login form -->
  <div v-else class="rounded-2xl border border-white/10 bg-slate-900/50 p-5 space-y-2">
      <input v-model="identifier" placeholder="الإيميل أو اسم المستخدم" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <input v-model="password" type="password" placeholder="كلمة المرور" class="w-full rounded-xl bg-slate-900/60 px-4 py-2" />
      <button class="w-full rounded-xl px-4 py-2 bg-slate-800/60 hover:bg-slate-700/60 border border-white/10" @click="doLogin">دخول</button>
      <div class="text-xs text-gray-400">ليس لديك حساب؟ <a class="text-indigo-400 hover:underline" href="#" @click.prevent="switchTo('signup')">إنشاء حساب</a></div>
      <div class="text-red-400 text-sm" v-if="error">{{ error }}</div>
    </div>
  </div>
</template>
