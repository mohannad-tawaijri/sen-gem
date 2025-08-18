<template>
  <div class="min-h-screen bg-gray-50 p-4">
    <div class="max-w-4xl mx-auto">
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h1 class="text-3xl font-bold text-center mb-8 text-gray-800">إعداد اللعبة</h1>
        
        <!-- إعدادات الفرق -->
        <div class="mb-8 grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">اسم الفريق الأول</label>
            <input 
              v-model="teamAName" 
              type="text" 
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              placeholder="الفريق الأول"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">اسم الفريق الثاني</label>
            <input 
              v-model="teamBName" 
              type="text" 
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              placeholder="الفريق الثاني"
            />
          </div>
        </div>

        <!-- وضع العرض -->
        <div class="mb-6 p-4 bg-gray-50 rounded-lg">
          <label class="flex items-center cursor-pointer">
            <input 
              type="checkbox" 
              :checked="sessionStore.state.ui?.projector" 
              @change="sessionStore.toggleProjector()"
              class="mr-2 h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded"
            />
            <span class="text-sm font-medium text-gray-700">
              📺 وضع العرض (خط أكبر وإخفاء أدوات الإدارة)
            </span>
          </label>
        </div>
        
        <div v-if="loading" class="text-center py-8">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mx-auto"></div>
          <p class="mt-4 text-gray-600">جاري تحميل الفئات...</p>
        </div>

        <div v-else-if="error" class="text-center py-8">
          <p class="text-red-600 mb-4">{{ error }}</p>
          <button @click="loadCategoriesData" class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
            إعادة المحاولة
          </button>
        </div>

        <div v-else>
          <div class="mb-8">
            <h2 class="text-xl font-semibold mb-4 text-gray-700">اختر الفئات</h2>
            <CategoryPicker 
              :categories="categories" 
              v-model="selectedCategories" 
              :limit="6"
            />
          </div>

          <div class="flex justify-between">
            <button 
              @click="$router.push('/')"
              class="bg-gray-500 text-white px-6 py-3 rounded-lg hover:bg-gray-600 transition"
            >
              ← العودة
            </button>
            
            <div class="text-right">
              <button 
                @click="startGame"
                :disabled="selectedCategories.length !== 6"
                class="bg-purple-600 text-white px-6 py-3 rounded-lg hover:bg-purple-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition"
              >
                بدء اللعبة →
              </button>
              <div v-if="selectedCategories.length !== 6" class="text-sm text-red-500 mt-2">
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
