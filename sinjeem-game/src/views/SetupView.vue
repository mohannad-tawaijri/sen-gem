<template>
  <div class="min-h-screen p-4">
    <div class="max-w-4xl mx-auto">
      <div class="card rounded-2xl p-6">
        <h1 class="heading text-3xl text-center mb-8">إعداد اللعبة</h1>
        
        <!-- إعدادات الفرق -->
        <div class="mb-8 grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">اسم الفريق الأول</label>
            <input 
              v-model="teamAName" 
              type="text" 
              class="w-full rounded-lg px-3 py-2 bg-white/5 border border-white/15 text-white placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="الفريق الأول"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">اسم الفريق الثاني</label>
            <input 
              v-model="teamBName" 
              type="text" 
              class="w-full rounded-lg px-3 py-2 bg-white/5 border border-white/15 text-white placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="الفريق الثاني"
            />
          </div>
        </div>

        <!-- وضع العرض -->
        
        
        <div v-if="loading" class="text-center py-8">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mx-auto"></div>
          <p class="mt-4 text-gray-300">جاري تحميل الفئات...</p>
        </div>

        <div v-else-if="error" class="text-center py-8">
          <p class="text-red-400 mb-4">{{ error }}</p>
          <button @click="loadCategoriesData" class="btn-danger">
            إعادة المحاولة
          </button>
        </div>

        <div v-else>
          <div class="mb-8">
            <h2 class="text-xl font-semibold mb-4 text-gray-200">اختر الفئات</h2>
            <CategoryPicker 
              :categories="categories" 
              v-model="selectedCategories" 
              :limit="6"
            />
          </div>

          <div class="flex justify-between">
            <button 
              @click="$router.push('/')"
              class="btn-secondary"
            >
              ← العودة
            </button>
            
            <div class="text-right">
              <button 
                @click="startGame"
                :disabled="selectedCategories.length !== 6"
                class="btn-cta disabled:opacity-50 disabled:cursor-not-allowed"
              >
                بدء اللعبة →
              </button>
              <div v-if="selectedCategories.length !== 6" class="text-sm text-red-400 mt-2">
                يجب اختيار 6 فئات بالضبط لبدء اللعبة
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import CategoryPicker from '../components/CategoryPicker.vue'
import { loadQuestions } from '../services/questions'
import { useSessionStore } from '../stores/session'
import type { SeedCategory } from '../types'

const router = useRouter()
const sessionStore = useSessionStore()
const categories = ref<SeedCategory[]>([])
const loading = ref(true)
const error = ref('')

const selectedCategories = computed({
  get: () => sessionStore.state.selectedCategorySlugs,
  set: (value: string[]) => sessionStore.setSelectedSlugs(value)
})

const teamAName = computed({
  get: () => sessionStore.state.teams.A.name,
  set: (value: string) => sessionStore.setTeamName('A', value)
})

const teamBName = computed({
  get: () => sessionStore.state.teams.B.name,
  set: (value: string) => sessionStore.setTeamName('B', value)
})

const loadCategoriesData = async () => {
  try {
    loading.value = true
    error.value = ''
    categories.value = await loadQuestions()
  } catch (err: any) {
    error.value = err.message || 'حدث خطأ في تحميل البيانات'
  } finally {
    loading.value = false
  }
}

const startGame = () => {
  if (selectedCategories.value.length !== 6) return
  router.push('/board')
}

onMounted(() => {
  loadCategoriesData()
})
</script>
