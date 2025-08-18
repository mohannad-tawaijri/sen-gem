<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSessionStore } from '../stores/session'
import { loadQuestions } from '../services/questions'
import { nextTick } from 'vue'
import type { SeedCategory } from '../types'

const router = useRouter()
const s = useSessionStore()
const all = ref<SeedCategory[]>([])

const currentEntry = computed(() => {
  if (!s.state.current || !all.value.length) return null
  
  const cat = all.value.find(c => c.slug === s.state.current!.slug)
  if (!cat?.entries) {
    console.error(`❌ لم يتم العثور على فئة أو أسئلة: ${s.state.current!.slug}`)
    return null
  }
  
  const entry = cat.entries.find(e => e.id === s.state.current!.qid)
  if (!entry) {
    console.error(`❌ لم يتم العثور على سؤال: ${s.state.current!.qid} في فئة ${cat.name}`)
    return null
  }
  
  console.log(`✅ تم العثور على السؤال:`, entry)
  return entry
})

// Check if this is a visual identification question
const isVisualQuestion = computed(() => {
  if (!currentEntry.value) return false
  return currentEntry.value.q.includes('من هذا الشخص؟') || 
         currentEntry.value.tags?.includes('visual')
})

const timeLeft = ref(s.state.config.questionTimeSec)
const timerInterval = ref<number | null>(null)

onMounted(async () => {
  if (!s.state.current) {
    router.push({ name: 'board' })
    return
  }

  // تحميل الأسئلة أولاً
  all.value = await loadQuestions()

  await nextTick()
  startTimer()
})

function startTimer() {
  timerInterval.value = setInterval(() => {
    if (timeLeft.value > 0) {
      timeLeft.value--
    } else {
      clearInterval(timerInterval.value!)
    }
  }, 1000)
}

function revealAnswer() {
  if (timerInterval.value) {
    clearInterval(timerInterval.value)
  }
  
  if (!currentEntry.value) return
  
  // تحديث Store
  s.revealAnswer()
  
  // إعداد بيانات الإجابة
  s.currentAnswer = {
    question: currentEntry.value.q,
    answer: currentEntry.value.a,
    points: s.state.current!.difficulty,
    media: currentEntry.value.media
  }
  
  router.push({ name: 'answer' })
}

function backToBoard() {
  if (timerInterval.value) {
    clearInterval(timerInterval.value)
  }
  s.currentAnswer = null
  s.state.current = undefined
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
  // Replace missing default.png with a valid placeholder
  if (url.includes('default.png')) {
    console.log('🔧 استخدام صورة افتراضية بديلة للطلبات المفقودة')
    return 'https://via.placeholder.com/800x600?text=لا+صورة'
  }
  // For local images, ensure a single leading slash
  const cleanUrl = url.replace(/^\/+/, '')
  const finalUrl = `/${cleanUrl}`
  console.log(`🖼️ مسار الصورة المحلي: ${url} → ${finalUrl}`)
  return finalUrl
}
</script>

<template>
  <div v-if="!all.length" class="flex items-center justify-center min-h-screen">
    <div class="text-center">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
      <p>جاري تحميل السؤال...</p>
    </div>
  </div>
  
  <main v-else-if="currentEntry" class="max-w-4xl mx-auto p-6">
    <!-- Timer Header -->
    <header class="flex items-center justify-between mb-6">
      <div class="text-2xl font-bold" :class="s.state.ui?.projector ? 'text-3xl' : 'text-2xl'">{{ s.state.current?.difficulty }} نقطة</div>
      <div class="text-xl" :class="[timeLeft <= 10 ? 'text-red-500 animate-pulse' : 'text-gray-600', s.state.ui?.projector ? 'text-2xl' : 'text-xl']">
        {{ Math.floor(timeLeft / 60) }}:{{ (timeLeft % 60).toString().padStart(2, '0') }}
      </div>
      <button @click="backToBoard" class="rounded-lg border px-4 py-2" :class="s.state.ui?.projector ? 'text-lg px-6 py-3' : ''">إلغاء</button>
    </header>

    <!-- Question Display -->
    <section class="rounded-xl border p-8 mb-8">
      <h1 class="text-3xl font-bold text-center mb-6" :class="s.state.ui?.projector ? 'text-5xl' : 'text-3xl'">السؤال</h1>
      
      <div class="text-xl text-center mb-6" :class="s.state.ui?.projector ? 'text-3xl' : 'text-xl'">{{ currentEntry.q }}</div>
      
      <!-- Media for visual identification questions only -->
      <div v-if="isVisualQuestion && currentEntry.media?.length" class="space-y-4">
        <div v-for="item in currentEntry.media" :key="item.src" class="flex justify-center">
          <img v-if="item.type === 'image'" 
               :src="getImageUrl(item.src)" 
               :alt="item.alt || 'صورة السؤال'" 
               class="max-w-full rounded-lg shadow-lg"
               :class="s.state.ui?.projector ? 'max-h-96' : 'max-h-80'"
               @error="handleImageError"
               @load="console.log('✅ تم تحميل الصورة:', item.src)" />
        </div>
      </div>
    </section>

    <!-- Answer Button -->
    <section class="text-center">
      <button @click="revealAnswer" 
              class="rounded-xl bg-green-600 text-white px-8 py-4 font-semibold hover:bg-green-700 transition"
              :class="s.state.ui?.projector ? 'text-2xl px-12 py-6' : 'text-xl'">
        عرض الإجابة
      </button>
    </section>
  </main>
  
  <div v-else class="flex items-center justify-center min-h-screen">
    <div class="text-center">
      <p class="text-red-600 text-xl mb-4">خطأ في تحميل السؤال</p>
      <button @click="backToBoard" class="bg-red-500 text-white px-6 py-3 rounded-lg">العودة للوحة</button>
    </div>
  </div>
</template>
