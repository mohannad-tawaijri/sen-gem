<script setup lang="ts">
import { onMounted, onBeforeUnmount, computed, watch } from 'vue'
import { useSessionStore } from '../stores/session'

const s = useSessionStore()
const overlay = computed(() => s.state.lifelineOverlay)

let timer: number | null = null

function startTimer() {
  if (timer) clearInterval(timer)
  timer = window.setInterval(() => s.tickOverlay(), 1000) as unknown as number
}

function stopTimer() {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
}

// مراقبة تفعيل/إلغاء تفعيل الـ overlay
watch(() => overlay.value?.active, (active) => {
  if (active) {
    startTimer()
  } else {
    stopTimer()
  }
}, { immediate: true })

onMounted(() => {
  if (overlay.value?.active) {
    startTimer()
  }
})

onBeforeUnmount(() => {
  stopTimer()
})

const pct = computed(() => {
  if (!overlay.value) return 0
  const t = overlay.value.total || 1
  return Math.round(((t - overlay.value.secondsLeft) / t) * 100)
})

function close(){ s.closeOverlay() }
</script>

<template>
  <div v-if="overlay?.active" class="fixed inset-0 bg-black/70 z-50 grid place-items-center p-6">
    <div class="rounded-2xl bg-white w-full max-w-md p-6 text-center">
      <div class="text-sm text-gray-500 mb-1">مساعدة: اتصال بصديق</div>
      <div class="text-xl font-semibold mb-2">
        {{ overlay?.team === 'A' ? 'فريق أ' : 'فريق ب' }}
      </div>

      <div class="mt-2">
        <div class="text-5xl font-mono">{{ String(overlay?.secondsLeft || 0).padStart(2,'0') }}s</div>
        <div class="mt-4 h-2 w-full bg-gray-200 rounded-full overflow-hidden">
          <div class="h-full bg-emerald-600" :style="{ width: pct + '%' }"></div>
        </div>
      </div>

      <div class="mt-6 flex justify-center">
        <button class="rounded-lg border px-4 py-2" @click="close()">إغلاق</button>
      </div>
    </div>
  </div>
</template>
