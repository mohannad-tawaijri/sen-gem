<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 flex items-center justify-center p-4">
    <div class="bg-white rounded-3xl shadow-2xl p-8 max-w-md w-full text-center transform hover:scale-105 transition-transform duration-300">
      <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-800 mb-2">سين جيم</h1>
        <h2 class="text-2xl font-semibold text-purple-600 mb-4">مسابقة الأسئلة</h2>
        <p class="text-gray-600">اختبر معلوماتك واستمتع بحل الأسئلة المتنوعة!</p>
      </div>

      <div class="space-y-4">
        <button 
          @click="startGame" 
          class="w-full bg-gradient-to-r from-purple-500 to-pink-500 text-white font-bold py-4 px-6 rounded-xl hover:from-purple-600 hover:to-pink-600 transform hover:scale-105 transition-all duration-200 shadow-lg"
        >
          🎮 ابدأ اللعبة
        </button>
        
        <button 
          class="w-full bg-gradient-to-r from-blue-500 to-cyan-500 text-white font-bold py-3 px-6 rounded-xl hover:from-blue-600 hover:to-cyan-600 transform hover:scale-105 transition-all duration-200 shadow-lg"
        >
          📊 أفضل النتائج
        </button>
        
        <button 
          class="w-full bg-gradient-to-r from-green-500 to-emerald-500 text-white font-bold py-3 px-6 rounded-xl hover:from-green-600 hover:to-emerald-600 transform hover:scale-105 transition-all duration-200 shadow-lg"
        >
          ⚙️ الإعدادات
        </button>
      </div>

      <div class="mt-8 text-sm text-gray-500">
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
