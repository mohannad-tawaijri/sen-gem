import type { SeedCategory, SeedEntry, MediaItem } from '../types'

let cachedCategories: SeedCategory[] | null = null

export async function loadQuestions(): Promise<SeedCategory[]> {
  // تحميل قائمة الفئات أولاً
  const catRes = await fetch('/questions/categories.json', { cache: 'no-store' })
  if (!catRes.ok) throw new Error('فشل تحميل قائمة الفئات')
  const cats = (await catRes.json()) as Array<{ slug: string; name: string; image: string }>

  // لكل فئة، تحميل ملف الأسئلة الخاص بها
  const categoriesWithEntries = await Promise.all(
    cats.map(async cat => {
      const res = await fetch(`/questions/${cat.slug}.json`, { cache: 'no-store' })
      if (!res.ok) throw new Error(`فشل تحميل أسئلة الفئة ${cat.slug}`)
      const entries = (await res.json()) as SeedEntry[]
      entries.forEach(checkEntry)
      return {
        slug: cat.slug,
        name: cat.name,
        image: cat.image,
        entries: shuffleArray(entries)
      }
    })
  )
  cachedCategories = categoriesWithEntries
  return categoriesWithEntries
}

// دالة خلط المصفوفة (Fisher-Yates shuffle)
function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}

export function getCategories(): SeedCategory[] {
  return cachedCategories || []
}

function checkEntry(e: SeedEntry) {
  if (!e.id || !e.q || !e.a) throw new Error(`سؤال غير صالح: ${e?.id}`)
  if (e.media) {
    e.media.forEach((m: MediaItem) => {
      if (m.type !== 'image' || !m.src) throw new Error(`وسيط غير صالح في ${e.id}`)
    })
  }
}
