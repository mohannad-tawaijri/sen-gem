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

      // ضمان وجود صورة افتراضية عند غياب أي وسائط (سواء media أو mediaQuestion/mediaAnswer)
      const normalized = entries.map(e => {
        const hasAnyMedia = (
          Array.isArray((e as any).media) && (e as any).media.length > 0
        ) || (
          Array.isArray((e as any).mediaQuestion) && (e as any).mediaQuestion.length > 0
        ) || (
          Array.isArray((e as any).mediaAnswer) && (e as any).mediaAnswer.length > 0
        )

        return hasAnyMedia
          ? e
          : {
              ...e,
              media: [
                {
                  type: 'image',
                  src: `/media/questions/${cat.slug}/default.jfif`,
                  alt: cat.name
                } as unknown as MediaItem
              ]
            }
      })

      return {
        slug: cat.slug,
        name: cat.name,
        image: cat.image,
        entries: shuffleArray(normalized)
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
  if (!e.id) throw new Error(`سؤال غير صالح: ${e?.id}`)

  const hasQText = typeof e.q === 'string' && e.q.trim().length > 0
  const hasQMedia = (Array.isArray((e as any).mediaQuestion) && (e as any).mediaQuestion.length > 0) ||
                    (Array.isArray((e as any).media) && (e as any).media.length > 0)
  if (!hasQText && !hasQMedia) throw new Error(`سؤال غير صالح: ${e?.id}`)

  const hasAText = typeof e.a === 'string' && e.a.trim().length > 0
  const hasAMedia = (Array.isArray((e as any).mediaAnswer) && (e as any).mediaAnswer.length > 0) ||
                    (Array.isArray((e as any).media) && (e as any).media.length > 0)
  if (!hasAText && !hasAMedia) throw new Error(`سؤال غير صالح: ${e?.id}`)

  const validateMediaArray = (arr?: MediaItem[]) => {
    if (!arr) return
    arr.forEach((m: MediaItem) => {
      if (m.type !== 'image' || !m.src) throw new Error(`وسيط غير صالح في ${e.id}`)
    })
  }

  validateMediaArray((e as any).media)
  validateMediaArray((e as any).mediaQuestion)
  validateMediaArray((e as any).mediaAnswer)
}
