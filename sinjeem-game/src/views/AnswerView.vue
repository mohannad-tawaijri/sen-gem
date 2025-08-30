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
      <h1 class="heading mb-2 text-3xl">الإجابة</h1>
      <div class="text-lg text-blue-200">{{ currentAnswer.points }} نقطة</div>
    </header>

    <!-- عرض الإجابة -->
    <section class="rounded-xl card p-8 mb-8 text-center">
      <div class="text-2xl font-semibold mb-4">{{ currentAnswer.answer }}</div>
      
      <!-- الوسائط إن وجدت -->
      <div v-if="currentAnswer.media?.length" class="space-y-4">
        <div v-for="item in currentAnswer.media" :key="item.src" class="flex justify-center">
          <img v-if="item.type === 'image'" 
               :src="getImageUrl(item.src)" 
               :alt="item.alt || 'صورة الإجابة'" 
               class="max-w-full rounded-lg shadow-lg max-h-80"
               @error="handleImageError"
               @load="console.log('✅ تم تحميل صورة الإجابة:', item.src)" />
        </div>
      </div>
    </section>

    <!-- اختيار الفريق الفائز -->
  <section class="space-y-4">
      <h2 class="text-xl font-bold text-center mb-6">أي فريق أجاب بشكل صحيح؟</h2>
      
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
  <button @click="awardPoints('A')" 
    class="btn-primary p-6 text-lg">
          {{ s.state.teams.A.name }}
          <div class="text-sm opacity-90 mt-1">النقاط الحالية: {{ s.state.teams.A.score }}</div>
        </button>
        
  <button @click="noAward" 
    class="btn-secondary p-6 text-lg">
          لا أحد أجاب بشكل صحيح
        </button>
        
  <button @click="awardPoints('B')" 
    class="btn-primary p-6 text-lg">
          {{ s.state.teams.B.name }}
          <div class="text-sm opacity-90 mt-1">النقاط الحالية: {{ s.state.teams.B.score }}</div>
        </button>
      </div>
    </section>

    
  </main>
</template>
