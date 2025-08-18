<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useSessionStore } from '../stores/session'
import type { TeamId } from '../types'

const router = useRouter()
const s = useSessionStore()

const currentAnswer = computed(() => s.currentAnswer)

onMounted(() => {
  if (!s.currentAnswer) {
    router.push({ name: 'board' })
  }
})

function awardPoints(teamId: TeamId) {
  if (!s.currentAnswer) return
  s.award(teamId)
  router.push({ name: 'board' })
}

function noAward() {
  // استدعاء award بدون معامل لتعليم السؤال كمستخدم بدون إعطاء نقاط
  s.award()
  router.push({ name: 'board' })
}

function handleImageError(event: Event) {
  const target = event.target as HTMLImageElement
  if (target) {
    console.warn('⚠️ لم يتم العثور على الصورة:', target.src)
    target.style.display = 'none'
    // إخفاء الحاوي أيضاً إذا لم تكن هناك صور صالحة
    const parent = target.closest('.space-y-4')
    if (parent && parent.querySelectorAll('img:not([style*="display: none"])').length === 0) {
      (parent as HTMLElement).style.display = 'none'
    }
  }
}

function getImageUrl(url: string): string {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    console.log(`🖼️ مسار الصورة الخارجي: ${url}`)
    return url
  }
  // For local images, ensure a single leading slash
  const cleanUrl = url.replace(/^\/+/, '')
  const finalUrl = `/${cleanUrl}`
  console.log(`🖼️ مسار الصورة المحلي: ${url} → ${finalUrl}`)
  return finalUrl
}
</script>

<template>
  <main v-if="currentAnswer" class="max-w-4xl mx-auto p-6">
    <header class="text-center mb-8">
      <h1 class="text-3xl font-bold mb-2" :class="s.state.ui?.projector ? 'text-5xl' : 'text-3xl'">الإجابة</h1>
      <div class="text-lg text-gray-600" :class="s.state.ui?.projector ? 'text-2xl' : 'text-lg'">{{ currentAnswer.points }} نقطة</div>
    </header>

    <!-- عرض الإجابة -->
    <section class="rounded-xl border p-8 mb-8 text-center">
      <div class="text-2xl font-semibold mb-4" :class="s.state.ui?.projector ? 'text-4xl' : 'text-2xl'">{{ currentAnswer.answer }}</div>
      
      <!-- الوسائط إن وجدت -->
      <div v-if="currentAnswer.media?.length" class="space-y-4">
        <div v-for="item in currentAnswer.media" :key="item.src" class="flex justify-center">
          <img v-if="item.type === 'image'" 
               :src="getImageUrl(item.src)" 
               :alt="item.alt || 'صورة الإجابة'" 
               class="max-w-full rounded-lg shadow-lg"
               :class="s.state.ui?.projector ? 'max-h-96' : 'max-h-80'"
               @error="handleImageError"
               @load="console.log('✅ تم تحميل صورة الإجابة:', item.src)" />
        </div>
      </div>
    </section>

    <!-- اختيار الفريق الفائز -->
    <section class="space-y-4" v-if="!s.state.ui?.projector">
      <h2 class="text-xl font-bold text-center mb-6">أي فريق أجاب بشكل صحيح؟</h2>
      
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <button @click="awardPoints('A')" 
                class="rounded-xl bg-green-600 text-white p-6 text-lg font-semibold hover:bg-green-700 transition">
          {{ s.state.teams.A.name }}
          <div class="text-sm opacity-90 mt-1">النقاط الحالية: {{ s.state.teams.A.score }}</div>
        </button>
        
        <button @click="noAward" 
                class="rounded-xl border-2 border-gray-300 p-6 text-lg font-semibold hover:bg-gray-50 transition">
          لا أحد أجاب بشكل صحيح
        </button>
        
        <button @click="awardPoints('B')" 
                class="rounded-xl bg-blue-600 text-white p-6 text-lg font-semibold hover:bg-blue-700 transition">
          {{ s.state.teams.B.name }}
          <div class="text-sm opacity-90 mt-1">النقاط الحالية: {{ s.state.teams.B.score }}</div>
        </button>
      </div>
    </section>

    <!-- رسالة في وضع العرض -->
    <section v-else class="text-center">
      <p class="text-xl text-gray-600 mb-4">وضع العرض - استخدم أدوات الإدارة في اللوحة</p>
      <button @click="noAward" 
              class="rounded-xl bg-gray-600 text-white px-8 py-4 text-xl font-semibold hover:bg-gray-700 transition">
        العودة للوحة
      </button>
    </section>
  </main>
</template>
