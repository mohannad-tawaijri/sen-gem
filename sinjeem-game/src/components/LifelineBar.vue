<script setup lang="ts">
import { computed, ref } from 'vue'
import { useSessionStore } from '../stores/session'
import RouletteModal from './RouletteModal.vue'

const props = defineProps<{ disabled?: boolean }>()
const s = useSessionStore()
const rouletteA = ref(false)
const rouletteB = ref(false)
const teamA = computed(() => s.state.teams.A)
const teamB = computed(() => s.state.teams.B)

function call(t:'A'|'B'){ s.startCallAFriend(t) }
function two(t:'A'|'B'){ s.useTwoAnswers(t) }
function openWheel(t:'A'|'B') { if (!s.state.current) return; if (t==='A') rouletteA.value = true; else rouletteB.value = true }
function closeWheel(t:'A'|'B') { if (t==='A') rouletteA.value = false; else rouletteB.value = false }
</script>

<template>
  <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mb-6">
    <!-- فريق أ -->
    <div class="rounded-xl border p-3">
      <div class="flex items-center justify-between mb-2">
        <div class="font-semibold flex items-center gap-2">
          <span class="inline-block size-2 rounded-full bg-blue-600"></span>
          {{ teamA.name }}
        </div>
        <div class="text-sm text-gray-500">مساعدات</div>
      </div>
    <div class="flex flex-wrap gap-2">
        <button
      class="btn-secondary text-sm disabled:opacity-50"
          :disabled="props.disabled || teamA.lifelines.callUsed"
          @click="call('A')"
        >
          📞 اتصال بصديق
          <span v-if="teamA.lifelines.callUsed" class="ml-1 text-xs text-gray-500">(مستخدمة)</span>
        </button>
        <button
      class="btn-secondary text-sm disabled:opacity-50"
          :disabled="props.disabled || teamA.lifelines.twoAnswersUsed"
          @click="two('A')"
        >
          2️⃣ إجابتان
          <span v-if="teamA.lifelines.twoAnswersUsed" class="ml-1 text-xs text-gray-500">(مستخدمة)</span>
        </button>
        <button
          class="btn-secondary text-sm disabled:opacity-50"
          :disabled="props.disabled || teamA.lifelines.rouletteUsed || !s.state.current"
          @click="openWheel('A')"
        >
          🎡 عجلة الحظ
          <span v-if="teamA.lifelines.rouletteUsed" class="ml-1 text-xs text-gray-500">(مستخدمة)</span>
        </button>
      </div>
    </div>

    <!-- فريق ب -->
    <div class="rounded-xl border p-3">
      <div class="flex items-center justify-between mb-2">
        <div class="font-semibold flex items-center gap-2">
          <span class="inline-block size-2 rounded-full bg-emerald-600"></span>
          {{ teamB.name }}
        </div>
        <div class="text-sm text-gray-500">مساعدات</div>
      </div>
    <div class="flex flex-wrap gap-2">
        <button
      class="btn-secondary text-sm disabled:opacity-50"
          :disabled="props.disabled || teamB.lifelines.callUsed"
          @click="call('B')"
        >
          📞 اتصال بصديق
          <span v-if="teamB.lifelines.callUsed" class="ml-1 text-xs text-gray-500">(مستخدمة)</span>
        </button>
        <button
      class="btn-secondary text-sm disabled:opacity-50"
          :disabled="props.disabled || teamB.lifelines.twoAnswersUsed"
          @click="two('B')"
        >
          2️⃣ إجابتان
          <span v-if="teamB.lifelines.twoAnswersUsed" class="ml-1 text-xs text-gray-500">(مستخدمة)</span>
        </button>
        <button
          class="btn-secondary text-sm disabled:opacity-50"
          :disabled="props.disabled || teamB.lifelines.rouletteUsed || !s.state.current"
          @click="openWheel('B')"
        >
          🎡 عجلة الحظ
          <span v-if="teamB.lifelines.rouletteUsed" class="ml-1 text-xs text-gray-500">(مستخدمة)</span>
        </button>
      </div>
    </div>
  </div>
  <RouletteModal :open="rouletteA" team="A" @close="closeWheel('A')" />
  <RouletteModal :open="rouletteB" team="B" @close="closeWheel('B')" />
</template>
