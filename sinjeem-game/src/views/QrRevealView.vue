<script setup lang="ts">
import { onMounted, ref } from 'vue'

// Very small page: read hash like #s=... and show it
const secret = ref<string>('')

function readHash() {
  const h = window.location.hash
  const params = new URLSearchParams(h.replace(/^#/, ''))
  secret.value = params.get('s') || ''
}

onMounted(() => {
  readHash()
  window.addEventListener('hashchange', readHash)
})
</script>

<template>
  <main class="min-h-screen flex items-center justify-center p-6">
    <div class="max-w-md w-full card rounded-2xl p-6 text-center">
      <h1 class="heading text-2xl mb-4">ولا كلمة</h1>
      <p class="text-gray-300 mb-6">هذه هي الكلمة/العبارة الخاصة بك — اشرحها بدون كلام</p>
      <div class="text-2xl font-extrabold text-white">{{ secret }}</div>
    </div>
  </main>
  
</template>

<style scoped>
</style>
