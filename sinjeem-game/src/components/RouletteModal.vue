<script setup lang="ts">
import { computed, ref } from 'vue'
import { useSessionStore } from '../stores/session'
import type { TeamId } from '../types'
import { useRouter } from 'vue-router'

const props = defineProps<{ open: boolean, team: TeamId }>()
const emit = defineEmits<{ (e:'close'): void }>()
const s = useSessionStore()

// القطاعات (يمكن تعديل الألوان أو الأوزان لاحقًا)
// مخرجات العجلة (تم تحديث نص الربح حسب الطلب)
const segments = [
  { key: 'gain', label: 'اكسب نقاط السؤال', color: '#10b981' },
  { key: 'double', label: 'مضاعفة السؤال', color: '#6366f1' },
  { key: 'lose', label: 'اخسر نقاطك', color: '#ef4444' },
  { key: 'opponentLose', label: 'خصم من الخصم', color: '#f59e0b' },
] as const

type Key = typeof segments[number]['key']

const spinning = ref(false)
const rotation = ref(0)
const resultKey = ref<Key | null>(null)
const resultReady = ref(false) // ظهور نافذة النتيجة بعد توقف العجلة
const router = useRouter()

const title = computed(() => `عجلة الحظ - دور ${props.team === 'A' ? 'فريق أ' : 'فريق ب'}`)

function spin() {
  if (spinning.value) return
  resultKey.value = null
  resultReady.value = false
  spinning.value = true
  const fullRotations = 5 + Math.random() * 3 // 5-8 دورات
  const segAngle = 360 / segments.length
  const chosenIndex = Math.floor(Math.random() * segments.length)
  const targetAngle = 360 - (chosenIndex * segAngle + segAngle / 2)
  const finalRotation = fullRotations * 360 + targetAngle
  rotation.value = finalRotation
  setTimeout(() => {
    spinning.value = false
    resultKey.value = segments[chosenIndex].key
    // لا نطبق النتيجة فوراً؛ نعرضها أولاً مع زر "حسناً"
    resultReady.value = true
  }, 3300)
}

function confirmResult() {
  if (!resultKey.value) return
  const rk = resultKey.value
  applyOutcome(rk)
}

function applyOutcome(rk: Key) {
  s.applyRoulette(rk as any, props.team)
  if (rk === 'double') {
    // البقاء في نفس السؤال
    emit('close')
  } else {
    emit('close')
    router.push({ name: 'board' })
  }
}

// أسلوب رسم مرئي أوضح باستخدام conic-gradient لجميع القطاعات
// زاويا مساعدة
const segAngle = computed(() => 360 / segments.length)

function wedgeStyle(i: number, color: string) {
  const a = segAngle.value
  return {
    background: color,
    transform: `rotate(${i * a}deg) skewY(${90 - a}deg)`
  }
}

function labelWrapperStyle(i: number) {
  const a = segAngle.value
  const mid = i * a + a / 2
  return {
    transform: `rotate(${mid}deg) translate(-50%, -135%) rotate(-${mid}deg)`
  }
}

const wheelRotationStyle = computed(() => ({
  transition: 'transform 3.3s cubic-bezier(.25,.8,.3,1)',
  transform: `rotate(${rotation.value}deg)`
}))
</script>

<template>
  <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4">
    <div class="bg-gray-900 rounded-2xl shadow-2xl p-6 w-full max-w-md border border-white/10">
      <h3 class="text-xl font-bold mb-4 text-center">{{ title }}</h3>

      <div class="relative mx-auto w-72 h-72 mb-6 select-none">
        <!-- السهم -->
        <div class="absolute -top-4 left-1/2 -translate-x-1/2 z-20">
          <div class="w-0 h-0 border-l-6 border-r-6 border-b-12 border-l-transparent border-r-transparent border-b-yellow-400"></div>
        </div>
        <!-- عجلة بقطاعات منفصلة لتجنب تداخل النص -->
        <div class="wheel w-72 h-72 rounded-full border-4 border-white/20 shadow-inner relative" :style="wheelRotationStyle">
          <!-- الشرائح -->
          <div v-for="(seg,i) in segments" :key="'wedge-'+seg.key" class="wedge absolute top-1/2 left-1/2 origin-top-left w-1/2 h-1/2" :style="wedgeStyle(i, seg.color)"></div>
          <!-- التسميات -->
          <div v-for="(seg,i) in segments" :key="'label-'+seg.key" class="label absolute top-1/2 left-1/2 origin-center font-bold text-[11px] text-black text-center w-24 leading-snug" :style="labelWrapperStyle(i)">
            <span class="inline-block px-1 py-0.5 rounded bg-white/70/80 backdrop-blur-sm shadow text-[11px] whitespace-normal break-words">
              {{ seg.label }}
            </span>
          </div>
        </div>
      </div>

      <div class="text-center space-y-3" v-if="!resultReady">
        <button @click="spin" :disabled="spinning" class="btn-primary w-full py-3 text-lg disabled:opacity-50">
          {{ spinning ? 'جاري الدوران...' : 'دَوِّر العجلة' }}
        </button>
        <button class="btn-secondary w-full" @click="emit('close')" :disabled="spinning">إغلاق</button>
      </div>

      <!-- نافذة النتيجة بعد التوقف -->
      <div v-else class="space-y-4 text-center animate-fade-in">
        <div class="text-lg font-bold text-emerald-300">
          النتيجة:
          <span class="ml-2 text-white">{{ segments.find(sg=>sg.key===resultKey)?.label }}</span>
        </div>
        <p v-if="resultKey === 'double'" class="text-sm text-indigo-300">تم تفعيل مضاعفة السؤال — استمر بالإجابة.</p>
        <p v-else class="text-sm text-gray-300">سيتم تنفيذ التأثير والعودة للوحة.</p>
        <button class="btn-primary w-full py-3 text-lg" @click="confirmResult">حسناً</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* سماكة حدود السهم */
.border-l-6 { border-left-width:6px }
.border-r-6 { border-right-width:6px }
.border-b-12 { border-bottom-width:12px }
.animate-fade-in { animation: fade-in .35s ease }
@keyframes fade-in { from { opacity:0; transform: translateY(6px);} to { opacity:1; transform: translateY(0);} }
.wheel .wedge { box-shadow: inset 0 0 8px 0 rgba(0,0,0,.35); }
.wheel .label span { backdrop-filter: blur(2px); }
</style>

