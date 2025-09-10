<script setup lang="ts">
import { computed, onMounted, onBeforeUnmount, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSessionStore } from '../stores/session'
import { loadQuestions } from '../services/questions'
import { nextTick } from 'vue'
import type { SeedCategory } from '../types'
import QrCode from '../components/QrCode.vue'
import LifelineBar from '../components/LifelineBar.vue'
import TimerOverlay from '../components/TimerOverlay.vue'
import RouletteModal from '../components/RouletteModal.vue'
import { markSeen } from '../services/api'

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

// (legacy heuristic removed; now we show media if it exists)

const isNoWords = computed(() => s.state.current?.slug === 'noWords')

// Show media for any question that has mediaQuestion or media (except noWords which uses QR)
const showQuestionMedia = computed(() => {
  if (!currentEntry.value) return false
  if (isNoWords.value) return false
  return !!(currentEntry.value.mediaQuestion?.length || currentEntry.value.media?.length)
})

const qrUrl = computed(() => {
  if (!currentEntry.value) return ''
  const secret = currentEntry.value.secret || currentEntry.value.a
  // Prefer a configured public origin if provided (for cases where the host PC is localhost)
  const publicOrigin = (import.meta as any)?.env?.VITE_PUBLIC_ORIGIN as string | undefined
  const base = publicOrigin || window.location.origin
  // We use Vue hash router, so route must live under #/reveal and we pass the secret as a query param
  return `${base}/#/reveal?s=${encodeURIComponent(secret)}`
})

// Timer: count up from 0 and keep running until leaving/revealing
const elapsed = ref(0)
const timerInterval = ref<ReturnType<typeof setInterval> | null>(null)
// حالة عجلة الحظ أثناء السؤال
const rouletteOpen = ref(false)
function openRoulette(){ if (!s.state.current) return; rouletteOpen.value = true }
function closeRoulette(){ rouletteOpen.value = false }

onMounted(async () => {
  if (!s.state.current) {
    router.push({ name: 'board' })
    return
  }

  // تحميل الأسئلة أولاً
  all.value = await loadQuestions()

  await nextTick()
  startTimer()

  // Mark question as seen to update remaining count
  try {
    const id = s.state.current!.qid
    await markSeen(id)
  } catch (e) {
    console.warn('تعذر تسجيل السؤال كمشاهد:', e)
  }
})

function startTimer() {
  if (timerInterval.value) clearInterval(timerInterval.value)
  timerInterval.value = setInterval(() => {
  if (!s.paused) elapsed.value++
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
    // استخدم mediaAnswer إن وُجدت وإلا فـ media العامة
    media: currentEntry.value.mediaAnswer?.length ? currentEntry.value.mediaAnswer : currentEntry.value.media
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

onBeforeUnmount(() => {
  if (timerInterval.value) clearInterval(timerInterval.value)
})

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
  // For local images, normalize leading patterns like "./" or multiple slashes
  let cleanUrl = url.trim()
  cleanUrl = cleanUrl.replace(/^(\.\/)+/, '') // remove leading ./ occurrences
  cleanUrl = cleanUrl.replace(/^\/+/, '') // then remove any leading slashes
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
      <div class="heading text-2xl">{{ s.state.current?.difficulty }} نقطة</div>
      <div class="text-xl font-mono px-3 py-1 rounded-lg glass flex items-center gap-3 select-none">
        <button @click="s.paused ? s.resumeTimer() : s.pauseTimer()" class="w-9 h-9 rounded-full flex items-center justify-center bg-white/10 hover:bg-white/20 transition" :title="s.paused ? 'استئناف' : 'إيقاف'">
          <svg v-if="!s.paused" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="w-5 h-5" fill="currentColor"><path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z"/></svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="w-5 h-5" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
        </button>
        <span>{{ Math.floor(elapsed / 60) }}:{{ (elapsed % 60).toString().padStart(2, '0') }}</span>
      </div>
      <div class="flex items-center gap-2">
        <button @click="openRoulette" class="btn-secondary">عجلة الحظ</button>
        <button @click="backToBoard" class="btn-secondary">إلغاء</button>
      </div>
    </header>

    <!-- Lifelines visible during the question -->
  <LifelineBar />

  <!-- Question Display -->
    <section class="rounded-xl card p-8 mb-8">
      <h1 class="heading text-center mb-6 text-3xl">السؤال</h1>
      
      <div class="text-xl text-center mb-6">{{ currentEntry.q }}</div>

      <!-- No Words QR Mode -->
      <div v-if="isNoWords" class="flex flex-col items-center gap-4">
        <p class="text-center text-gray-300 text-base">
          اطلب من أحد المتسابقين مسح رمز QR بهاتفه. ستظهر له الكلمة/العبارة ويجب عليه تمثيلها بدون كلام.
        </p>
        <QrCode :text="qrUrl" :size="260" />
  <!-- <a :href="qrUrl" target="_blank" class="text-blue-600 underline break-all">{{ qrUrl }}</a> -->
      </div>
      
    <!-- Media: show whenever the question has media (excluding noWords QR mode) -->
  <div v-if="showQuestionMedia" class="space-y-4">
        <div v-for="item in (currentEntry.mediaQuestion?.length ? currentEntry.mediaQuestion : currentEntry.media)" :key="item.src" class="flex justify-center">
    <img v-if="item.type === 'image'" 
               :src="getImageUrl(item.src)" 
               :alt="item.alt || 'صورة السؤال'" 
      class="max-w-full rounded-lg shadow-2xl max-h-80"
               @error="handleImageError"
               @load="console.log('✅ تم تحميل الصورة:', item.src)" />
        </div>
      </div>
    </section>

    <!-- Answer Button -->
    <section class="text-center">
      <button @click="revealAnswer" 
              class="btn-primary text-xl">
        عرض الإجابة
      </button>
    </section>

  <!-- Overlay for lifeline timers -->
  <TimerOverlay />
  <RouletteModal :open="rouletteOpen" :team="s.state.currentTurn || 'A'" @close="closeRoulette" />
  </main>
  
  <div v-else class="flex items-center justify-center min-h-screen">
    <div class="text-center">
      <p class="text-red-600 text-xl mb-4">خطأ في تحميل السؤال</p>
      <button @click="backToBoard" class="bg-red-500 text-white px-6 py-3 rounded-lg">العودة للوحة</button>
    </div>
  </div>
</template>
