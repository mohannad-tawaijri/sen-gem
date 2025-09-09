<script setup lang="ts">
import { computed } from 'vue'
import { useSessionStore } from '../stores/session'
import type { TeamId } from '../types'

const props = defineProps<{ open: boolean, team: TeamId }>()
const emit = defineEmits<{ (e:'close'): void }>()
const s = useSessionStore()

const options = [
  { key: 'gain', label: 'اربح نقاط السؤال' },
  { key: 'lose', label: 'اخسر نقاط السؤال' },
  { key: 'opponentLose', label: 'خصم المنافس نقاط السؤال' },
  { key: 'double', label: 'السؤال مُضاعف' },
] as const

type Key = typeof options[number]['key']

function choose(k: Key) {
  s.applyRoulette(k as any, props.team)
  if (k !== 'double') {
    emit('close')
  }
}

const title = computed(() => `عجلة الحظ - دور ${props.team === 'A' ? 'فريق أ' : 'فريق ب'}`)
</script>

<template>
  <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
    <div class="bg-gray-900 rounded-2xl shadow-2xl p-6 w-[420px] border border-white/10">
      <h3 class="text-xl font-bold mb-4">{{ title }}</h3>
      <div class="space-y-3">
        <button v-for="opt in options" :key="opt.key"
                class="w-full px-4 py-3 rounded-lg bg-white/10 hover:bg-white/15 text-white text-center"
                @click="choose(opt.key)">
          {{ opt.label }}
        </button>
      </div>
      <div class="mt-6 flex justify-end">
        <button class="btn-secondary" @click="$emit('close')">إغلاق</button>
      </div>
    </div>
  </div>
</template>
