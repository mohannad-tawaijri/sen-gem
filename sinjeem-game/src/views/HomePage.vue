<template>
  <div class="min-h-screen flex items-center justify-center p-6">
    <div class="rounded-3xl card p-8 max-w-md w-full text-center">
      <div class="mb-8">
        <h1 class="heading text-4xl mb-2">سين جيم</h1>
        <h2 class="text-2xl font-semibold text-indigo-200 mb-4">مسابقة الأسئلة</h2>
        <p class="text-gray-300">اختبر معلوماتك واستمتع بحل الأسئلة المتنوعة!</p>
      </div>

      <div class="space-y-4">
  <button @click="startGame" class="btn-cta w-full py-4">
          🎮 ابدأ اللعبة
        </button>
        <button class="btn-secondary w-full">
          📊 أفضل النتائج
        </button>
        <button class="btn-secondary w-full">
          ⚙️ الإعدادات
        </button>
      </div>

      <div class="mt-8 text-sm text-gray-400">
        <p>النسخة 1.0.0</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()

const startGame = () => {
  router.push('/setup')
}
</script>
