<template>
  <div class="min-h-screen">
    <!-- Header -->
    <header class="p-6 text-center border-b border-white/20">
      <h1 class="heading text-3xl md:text-5xl mb-2">نتائج المباراة</h1>
      <p class="text-xl text-blue-200">{{ endedAt ? formatDate(endedAt) : '' }}</p>
    </header>

    <!-- Results Content -->
    <div class="container mx-auto px-6 py-8">
      <!-- Winner Announcement -->
      <div class="text-center mb-8">
  <div v-if="winner" class="bg-gradient-to-r from-yellow-400 to-yellow-600 text-black p-6 rounded-xl shadow-2xl inline-block">
          <h2 class="text-4xl font-bold mb-2">🎉 الفائز 🎉</h2>
          <p class="text-3xl font-semibold">{{ teams[winner].name }}</p>
          <p class="text-xl mt-2">بنتيجة {{ teams[winner].score }} نقطة</p>
        </div>
  <div v-else class="bg-gradient-to-r from-gray-400 to-gray-600 text-white p-6 rounded-xl shadow-2xl inline-block">
          <h2 class="text-4xl font-bold mb-2">🤝 تعادل 🤝</h2>
          <p class="text-2xl">كلا الفريقين حقق {{ teams.A.score }} نقطة</p>
        </div>
      </div>

      <!-- Teams Scores -->
  <div class="grid md:grid-cols-2 gap-6 mb-8">
        <!-- Team A -->
        <div class="bg-white/10 backdrop-blur-sm rounded-xl p-6">
          <div class="text-center">
            <h3 class="text-2xl font-bold mb-4 text-blue-300">{{ teams.A.name }}</h3>
            <div class="text-6xl font-bold mb-4 text-blue-400">{{ teams.A.score }}</div>
            <div class="text-sm text-gray-300">
              <p>خط نجدة: {{ teams.A.lifelines.callUsed ? 'مُستخدم' : 'غير مُستخدم' }}</p>
              <p>إجابتان: {{ teams.A.lifelines.twoAnswersUsed ? 'مُستخدم' : 'غير مُستخدم' }}</p>
            </div>
          </div>
        </div>

        <!-- Team B -->
        <div class="bg-white/10 backdrop-blur-sm rounded-xl p-6">
          <div class="text-center">
            <h3 class="text-2xl font-bold mb-4 text-green-300">{{ teams.B.name }}</h3>
            <div class="text-6xl font-bold mb-4 text-green-400">{{ teams.B.score }}</div>
            <div class="text-sm text-gray-300">
              <p>خط نجدة: {{ teams.B.lifelines.callUsed ? 'مُستخدم' : 'غير مُستخدم' }}</p>
              <p>إجابتان: {{ teams.B.lifelines.twoAnswersUsed ? 'مُستخدم' : 'غير مُستخدم' }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Game Statistics -->
  <div class="bg-white/10 backdrop-blur-sm rounded-xl p-6 mb-8">
        <h3 class="text-2xl font-bold mb-4 text-center">إحصائيات المباراة</h3>
        <div class="grid md:grid-cols-3 gap-4 text-center">
          <div>
            <div class="text-3xl font-bold text-yellow-400">{{ totalQuestionsAnswered }}</div>
            <p class="text-sm text-gray-300">الأسئلة المُجابة</p>
          </div>
          <div>
            <div class="text-3xl font-bold text-blue-400">{{ selectedCategorySlugs.length }}</div>
            <p class="text-sm text-gray-300">الفئات المُختارة</p>
          </div>
          <div>
            <div class="text-3xl font-bold text-green-400">{{ totalLifelinesUsed }}</div>
            <p class="text-sm text-gray-300">خطوط النجدة المُستخدمة</p>
          </div>
        </div>
      </div>

      <!-- Categories Used -->
      <div class="bg-white/10 backdrop-blur-sm rounded-xl p-6 mb-8" v-if="selectedCategorySlugs.length > 0">
        <h3 class="text-2xl font-bold mb-4 text-center">الفئات المُختارة</h3>
        <div class="flex flex-wrap justify-center gap-3">
          <span 
            v-for="slug in selectedCategorySlugs" 
            :key="slug"
            class="bg-purple-600 px-4 py-2 rounded-full text-sm font-medium"
          >
            {{ getCategoryName(slug) }}
          </span>
        </div>
      </div>

      <!-- Action Buttons -->
  <div class="flex flex-col md:flex-row gap-4 justify-center">
        <button 
          @click="resumeGame"
          class="bg-green-600 hover:bg-green-700 px-8 py-3 rounded-xl font-bold text-lg transition-colors"
        >
          استئناف المباراة
        </button>
        <button 
          @click="goToSetup"
          class="bg-purple-600 hover:bg-purple-700 px-8 py-3 rounded-xl font-bold text-lg transition-colors"
        >
          إعداد جديد
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useSessionStore } from '../stores/session'
import { getCategories, loadQuestions } from '../services/questions'

const router = useRouter()
const sessionStore = useSessionStore()

// Load categories on mount
onMounted(async () => {
  try {
    await loadQuestions()
  } catch (error) {
    console.error('Error loading questions for results:', error)
  }
})

// Computed properties
const teams = computed(() => sessionStore.state.teams)
const selectedCategorySlugs = computed(() => sessionStore.state.selectedCategorySlugs)
const usedIds = computed(() => sessionStore.state.usedIds)
const endedAt = computed(() => sessionStore.state.endedAt)

// Winner calculation
const winner = computed(() => {
  const scoreA = teams.value.A.score
  const scoreB = teams.value.B.score
  if (scoreA > scoreB) return 'A'
  if (scoreB > scoreA) return 'B'
  return null // tie
})

// Statistics
const totalQuestionsAnswered = computed(() => {
  const used = usedIds.value
  if (!used) return 0
  return Object.keys(used).reduce((total, category) => {
    return total + Object.keys(used[category] || {}).length
  }, 0)
})

const totalLifelinesUsed = computed(() => {
  let count = 0
  if (teams.value.A.lifelines.callUsed) count++
  if (teams.value.A.lifelines.twoAnswersUsed) count++
  if (teams.value.B.lifelines.callUsed) count++
  if (teams.value.B.lifelines.twoAnswersUsed) count++
  return count
})

// Helper functions
const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('ar-EG', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getCategoryName = (slug: string) => {
  const categories = getCategories()
  const category = categories.find((c: any) => c.slug === slug)
  return category?.name || slug
}

// Actions
const resumeGame = () => {
  sessionStore.resumeGame()
  router.push('/board')
}

const goToSetup = () => {
  sessionStore.hardReset()
  router.push('/setup')
}
</script>
