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

// دوال رسم القطاعات باستخدام SVG
function getWedgePath(index: number): string {
  const angle = segAngle.value
  const startAngle = index * angle - 90 // نبدأ من الأعلى
  const endAngle = startAngle + angle
  
  const startRad = (startAngle * Math.PI) / 180
  const endRad = (endAngle * Math.PI) / 180
  
  const radius = 180
  const cx = 200
  const cy = 200
  
  const x1 = cx + radius * Math.cos(startRad)
  const y1 = cy + radius * Math.sin(startRad)
  const x2 = cx + radius * Math.cos(endRad)
  const y2 = cy + radius * Math.sin(endRad)
  
  const largeArc = angle > 180 ? 1 : 0
  
  return `M ${cx} ${cy} L ${x1} ${y1} A ${radius} ${radius} 0 ${largeArc} 1 ${x2} ${y2} Z`
}

function getTextX(index: number): number {
  const angle = segAngle.value
  const midAngle = (index * angle + angle / 2 - 90) * Math.PI / 180
  return 200 + 120 * Math.cos(midAngle)
}

function getTextY(index: number): number {
  const angle = segAngle.value
  const midAngle = (index * angle + angle / 2 - 90) * Math.PI / 180
  return 200 + 120 * Math.sin(midAngle)
}

function getTextTransform(index: number): string {
  const angle = segAngle.value
  const midAngle = index * angle + angle / 2
  return `rotate(${midAngle}, ${getTextX(index)}, ${getTextY(index)})`
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

      <div class="relative mx-auto w-80 h-80 mb-6 select-none">
        <!-- السهم -->
        <div class="absolute -top-6 left-1/2 -translate-x-1/2 z-20">
          <div class="w-0 h-0 border-l-12 border-r-12 border-b-20 border-l-transparent border-r-transparent border-b-yellow-400 drop-shadow-lg"></div>
        </div>
        
        <!-- عجلة باستخدام SVG لوضوح أفضل -->
        <svg class="wheel-svg w-full h-full" :style="wheelRotationStyle" viewBox="0 0 400 400">
          <defs>
            <filter id="shadow">
              <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.3"/>
            </filter>
          </defs>
          
          <!-- رسم القطاعات -->
          <g v-for="(seg, i) in segments" :key="'seg-'+i">
            <!-- القطاع -->
            <path 
              :d="getWedgePath(i)" 
              :fill="seg.color"
              stroke="rgba(255,255,255,0.2)" 
              stroke-width="2"
              filter="url(#shadow)"
            />
            
            <!-- النص -->
            <text
              :x="getTextX(i)"
              :y="getTextY(i)"
              :transform="getTextTransform(i)"
              text-anchor="middle"
              class="wheel-text"
              fill="white"
              font-size="16"
              font-weight="bold"
            >
              <tspan 
                v-for="(line, idx) in seg.label.split(' ')" 
                :key="idx"
                :x="getTextX(i)" 
                :dy="idx === 0 ? 0 : 18"
              >
                {{ line }}
              </tspan>
            </text>
          </g>
          
          <!-- دائرة في المنتصف -->
          <circle cx="200" cy="200" r="25" fill="#1f2937" stroke="rgba(255,255,255,0.3)" stroke-width="3"/>
        </svg>
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
          <span class="ml-2 text-white">{{ segments.find((sg: any)=>sg.key===resultKey)?.label }}</span>
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
.border-l-12 { border-left-width: 12px; }
.border-r-12 { border-right-width: 12px; }
.border-b-20 { border-bottom-width: 20px; }

.animate-fade-in { 
  animation: fade-in .35s ease;
}

@keyframes fade-in { 
  from { opacity: 0; transform: translateY(6px); } 
  to { opacity: 1; transform: translateY(0); }
}

.wheel-svg {
  filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.3));
}

.wheel-text {
  paint-order: stroke fill;
  stroke: rgba(0, 0, 0, 0.5);
  stroke-width: 1px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}
</style>

