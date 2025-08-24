<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import QRCode from 'qrcode'

const props = defineProps<{ text: string; size?: number; margin?: number }>()
const canvasRef = ref<HTMLCanvasElement | null>(null)

async function render() {
  if (!canvasRef.value) return
  try {
    await QRCode.toCanvas(canvasRef.value, props.text || '', {
      width: props.size ?? 256,
      margin: props.margin ?? 2,
      errorCorrectionLevel: 'H'
    })
  } catch (e) {
    console.error('فشل إنشاء QR:', e)
  }
}

onMounted(render)
watch(() => props.text, render)
</script>

<template>
  <canvas ref="canvasRef" class="rounded-lg shadow" />
</template>

<style scoped>
</style>
