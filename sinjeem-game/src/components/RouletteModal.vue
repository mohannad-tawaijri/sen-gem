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
const router = useRouter()

const title = computed(() => `عجلة الحظ - دور ${props.team === 'A' ? 'فريق أ' : 'فريق ب'}`)

function spin() {
  if (spinning.value) return
  resultKey.value = null
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
    applyResult()
  }, 3300)
}

function applyResult() {
  if (!resultKey.value) return
  const rk = resultKey.value
  s.applyRoulette(rk as any, props.team)
  // غير المضاعفة: الرجوع مباشرةً للوحة
  if (rk !== 'double') {
    emit('close')
    router.push({ name: 'board' })
  } else {
    // للمضاعفة: فقط أغلق النافذة وابق في نفس السؤال
    emit('close')
  }
}

// أسلوب رسم مرئي أوضح باستخدام conic-gradient لجميع القطاعات
const wheelStyle = computed(() => {
  const per = 360 / segments.length
  const parts = segments.map((seg, i) => {
    const start = i * per
    const end = (i + 1) * per
    return `${seg.color} ${start}deg ${end}deg`
  })
  return {
    background: `conic-gradient(${parts.join(',')})`,
    transition: 'transform 3.3s cubic-bezier(.25,.8,.3,1)',
    transform: `rotate(${rotation.value}deg)`
  }
})
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
        <!-- العجلة المحسنة -->
        <div class="w-72 h-72 rounded-full border-4 border-white/20 shadow-inner relative" :style="wheelStyle">
          <div v-for="(seg,i) in segments" :key="seg.key"
               class="absolute top-1/2 left-1/2 font-bold text-[11px] text-black text-center w-24 -translate-x-1/2 -translate-y-1/2"
               :style="{ transform: 'rotate(' + (i*(360/segments.length) + (360/segments.length)/2) + 'deg) translate(0,-115%) rotate(-' + (i*(360/segments.length) + (360/segments.length)/2) + 'deg)' }">
            <span class="drop-shadow-[0_1px_2px_rgba(0,0,0,0.4)]">{{ seg.label }}</span>
          </div>
        </div>
      </div>

      <div class="text-center space-y-3">
        <button @click="spin" :disabled="spinning" class="btn-primary w-full py-3 text-lg disabled:opacity-50">
          {{ spinning ? 'جاري الدوران...' : 'دَوِّر العجلة' }}
        </button>
        <p v-if="resultKey" class="text-sm text-emerald-300">النتيجة: {{ segments.find(sg=>sg.key===resultKey)?.label }}</p>
        <button class="btn-secondary w-full" @click="$emit('close')">إغلاق</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* سماكة حدود السهم */
.border-l-6 { border-left-width:6px }
.border-r-6 { border-right-width:6px }
.border-b-12 { border-bottom-width:12px }
</style>
