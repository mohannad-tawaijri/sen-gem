<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSessionStore } from '../stores/session'
import { loadQuestions } from '../services/questions'
import type { SeedCategory, Points } from '../types'
import LifelineBar from '../components/LifelineBar.vue'
import TimerOverlay from '../components/TimerOverlay.vue'

const router = useRouter()
const s = useSessionStore()
const POINTS: Points[] = [200, 200, 400, 400, 600, 600]

const all = ref<SeedCategory[]>([])
const bySlug = computed(() => new Map<string, SeedCategory>(all.value.map(c => [c.slug, c])))
const selectedCats = computed(() =>
  s.state.selectedCategorySlugs.map(slug => bySlug.value.get(slug)!).filter(Boolean)
)

onMounted(async () => {
  if (s.state.selectedCategorySlugs.length === 0) {
    router.push({ name: 'setup' })
    return
  }
  
  // Check if game is ended, redirect to results
  if (s.state.status === 'ended') {
    router.push({ name: 'results' })
    return
  }
  
  // تحميل الأسئلة أولاً
  all.value = await loadQuestions()
  
  await s.initBoardPicks()
  // Preload صور الفئات
  selectedCats.value.forEach(c => {
    if (c?.image) {
      const link = document.createElement('link')
      link.rel = 'preload'
      link.as = 'image'
      link.href = c.image
      document.head.appendChild(link)
    }
  })
})

function backToSetup() { router.push({ name: 'setup' }) }

function endGame() {
  if (confirm('هل أنت متأكد من إنهاء المباراة؟ يمكنك استئنافها لاحقاً من صفحة النتائج.')) {
    s.endGame()
    router.push({ name: 'results' })
  }
}

function onCellClick(slug: string, pts: Points, idx: number) {
  // حساب الفهرس الصحيح بناءً على صف الشبكة
  let correctIndex: number
  if (idx === 0 || idx === 1) {
    // صفوف 200 نقطة
    correctIndex = idx
  } else if (idx === 2 || idx === 3) {
    // صفوف 400 نقطة 
    correctIndex = idx - 2
  } else {
    // صفوف 600 نقطة
    correctIndex = idx - 4
  }
  
  if (s.cellUsed(slug, pts, correctIndex)) return
  s.openCell(slug, pts, correctIndex)
  router.push({ name: 'question' })
}

function isDisabled(slug: string, pts: Points, idx: number) {
  // حساب الفهرس الصحيح بناءً على صف الشبكة
  let correctIndex: number
  if (idx === 0 || idx === 1) {
    // صفوف 200 نقطة
    correctIndex = idx
  } else if (idx === 2 || idx === 3) {
    // صفوف 400 نقطة 
    correctIndex = idx - 2
  } else {
    // صفوف 600 نقطة
    correctIndex = idx - 4
  }
  
  return s.cellUsed(slug, pts, correctIndex)
}

function handleImageError(event: Event) {
  const target = event.target as HTMLImageElement
  if (target) {
    target.style.display = 'none'
  }
}
</script>

<template>
  <main class="max-w-[1200px] mx-auto p-6">
    <header class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">لوحة الأسئلة</h1>
      <div class="flex items-center gap-2">
        <!-- End Game Button -->
        <button v-if="!s.state.ui?.projector"
                class="rounded-lg border border-red-500 text-red-500 hover:bg-red-500 hover:text-white px-4 py-2 font-semibold transition-colors"
                @click="endGame">
          إنهاء اللعبة
        </button>
        <button class="rounded-lg border px-3 py-2"
                @click="s.toggleProjector()">
          {{ s.state.ui?.projector ? 'خروج من وضع العرض' : 'وضع العرض' }}
        </button>
        <button v-if="!s.state.ui?.projector"
                class="rounded-lg border px-4 py-2"
                @click="backToSetup()">رجوع للإعداد</button>
      </div>
    </header>

    <!-- النقاط -->
    <LifelineBar v-if="!s.state.ui?.projector" />
    
    <section class="grid grid-cols-2 gap-4 mb-6">
      <div class="rounded-xl border p-4 text-center">
        <div class="text-sm text-gray-500 mb-1">فريق أ</div>
        <div class="text-xl font-bold">{{ s.state.teams.A.name }}</div>
        <div class="text-2xl mt-1">{{ s.state.teams.A.score }}</div>
      </div>
      <div class="rounded-xl border p-4 text-center">
        <div class="text-sm text-gray-500 mb-1">فريق ب</div>
        <div class="text-xl font-bold">{{ s.state.teams.B.name }}</div>
        <div class="text-2xl mt-1">{{ s.state.teams.B.score }}</div>
      </div>
    </section>

    <!-- الشبكة -->
    <section class="overflow-x-auto">
      <div class="grid grid-cols-6 gap-3 min-w-[900px]" 
           :class="s.state.ui?.projector ? 'transform scale-105' : ''">
        <!-- رؤوس الأعمدة (الفئات) -->
        <div v-for="cat in selectedCats" :key="cat.slug"
             class="rounded-md overflow-hidden bg-gray-900 text-white text-center">
          <div class="aspect-[16/9] bg-black/20 flex items-center justify-center">
            <img v-if="cat.image" 
                 :src="cat.image" 
                 :alt="cat.name" 
                 class="h-full w-full object-cover"
                 @error="handleImageError" />
            <div v-else class="text-gray-400 text-xs">{{ cat.name }}</div>
          </div>
          <div class="p-2 font-semibold" :class="s.state.ui?.projector ? 'text-lg' : 'text-sm'">{{ cat.name }}</div>
        </div>

        <!-- صفوف النقاط (200,200,400,400,600,600) -->
        <template v-for="rowIdx in 6" :key="rowIdx">
          <button
            v-for="cat in selectedCats"
            :key="cat.slug + '-' + rowIdx"
            type="button"
            class="rounded-md font-semibold transition-all duration-300"
            :class="[
              isDisabled(cat.slug, POINTS[rowIdx-1], rowIdx-1) 
                ? 'bg-gray-400 text-gray-600 opacity-40 saturate-50 cursor-not-allowed' 
                : 'bg-blue-600 text-white hover:bg-blue-700 hover:scale-105',
              s.state.ui?.projector ? 'text-2xl py-8' : 'text-xl py-6'
            ]"
            :disabled="isDisabled(cat.slug, POINTS[rowIdx-1], rowIdx-1)"
            @click="onCellClick(cat.slug, POINTS[rowIdx-1], rowIdx-1)"
          >
            <span v-if="isDisabled(cat.slug, POINTS[rowIdx-1], rowIdx-1)" class="opacity-60">
              ✓ {{ POINTS[rowIdx-1] }}
            </span>
            <span v-else>
              {{ POINTS[rowIdx-1] }}
            </span>
          </button>
        </template>
      </div>
    </section>

    <TimerOverlay />
  </main>
</template>
