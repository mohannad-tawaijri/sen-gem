<script setup lang="ts">
import { computed } from 'vue'
import type { SeedCategory } from '../types'

const props = defineProps<{ categories: SeedCategory[]; modelValue: string[]; limit?: number }>()
const emit = defineEmits<{ 'update:modelValue': [string[]] }>()

const limit = computed(() => props.limit ?? 6)
const selected = computed({
  get: () => props.modelValue,
  set: (val: string[]) => emit('update:modelValue', val.slice(0, limit.value))
})

function toggle(slug: string) {
  const set = new Set(selected.value)
  if (set.has(slug)) set.delete(slug)
  else {
    if (set.size >= limit.value) return
    set.add(slug)
  }
  selected.value = Array.from(set)
}
const isOn = (slug: string) => selected.value.includes(slug)
</script>

<template>
  <div>
    <div class="mb-2 text-sm text-gray-600">
      اختر <b>{{ limit }}</b> فئات — المختار: <b>{{ selected.length }}</b> / {{ limit }}
    </div>
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
      <button
        v-for="cat in categories" :key="cat.slug" type="button"
        class="group rounded-xl border overflow-hidden text-left transition
               data-[on=true]:ring-2 data-[on=true]:ring-blue-600"
        :data-on="isOn(cat.slug)" @click="toggle(cat.slug)"
      >
        <div class="aspect-[1/1] bg-gray-100 overflow-hidden">
          <img v-if="cat.image" :src="cat.image" :alt="cat.name"
               class="h-full w-full object-cover group-hover:scale-[1.03] transition" />
          <div v-else class="flex h-full items-center justify-center text-gray-400">لا صورة</div>
        </div>
        <div class="p-2 text-sm font-medium text-center">{{ cat.name }}</div>
      </button>
    </div>
  </div>
</template>
