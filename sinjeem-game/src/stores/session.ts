import { ref } from 'vue'
import { defineStore } from 'pinia'
import type { Points, TeamId, SessionState, SelectedForBoard, MediaItem } from '../types'
import { loadQuestions } from '../services/questions'
import { previewQuestions } from '../services/api'

interface AnswerState {
  question: string
  answer: string
  points: Points
  media?: MediaItem[]
}

export const useSessionStore = defineStore('session', () => {
  const state = ref<SessionState>({
    version: 2,
    createdAt: new Date().toISOString(),
    config: {
      questionTimeSec: 60,
      callAFriendSec: 60
    },
    teams: {
      A: { name: 'الفريق الأول', score: 0, lifelines: { callUsed: false, twoAnswersUsed: false } },
      B: { name: 'الفريق الثاني', score: 0, lifelines: { callUsed: false, twoAnswersUsed: false } }
    },
    selectedCategorySlugs: [],
    selectedForBoard: undefined,
    usedIds: {},
    current: undefined,
  lifelineOverlay: { active: false, team: 'A', kind: 'call', secondsLeft: 0, total: 0 },
    status: 'active',
    endedAt: undefined
  })

  const currentAnswer = ref<AnswerState | null>(null)

  // تحميل الحالة من localStorage
  const loadState = () => {
    const saved = localStorage.getItem('sessionState')
    if (saved) {
      try {
        const parsed = JSON.parse(saved)
        state.value = { ...state.value, ...parsed }
      } catch (err) {
        console.error('فشل في تحميل الحالة:', err)
      }
    }
  }

  // حفظ الحالة في localStorage
  const saveState = () => {
    localStorage.setItem('sessionState', JSON.stringify(state.value))
  }

  const setTeamName = (teamId: TeamId, name: string) => {
    state.value.teams[teamId].name = name
    saveState()
  }

  const setScore = (teamId: TeamId, score: number) => {
    state.value.teams[teamId].score = score
    saveState()
  }

  const addScore = (teamId: TeamId, points: number) => {
    state.value.teams[teamId].score += points
    saveState()
  }

  const setConfig = (config: Partial<typeof state.value.config>) => {
    state.value.config = { ...state.value.config, ...config }
    saveState()
  }

  const setSelectedSlugs = (slugs: string[]) => {
    state.value.selectedCategorySlugs = slugs
    saveState()
  }

  const softReset = () => {
    state.value.teams.A.score = 0
    state.value.teams.B.score = 0
    state.value.usedIds = {}
    state.value.current = undefined
    state.value.selectedForBoard = undefined
    saveState()
  }

  const hardReset = () => {
    state.value = {
      version: 2,
      createdAt: new Date().toISOString(),
      config: {
        questionTimeSec: 60,
        callAFriendSec: 60
      },
      teams: {
        A: { name: 'الفريق الأول', score: 0, lifelines: { callUsed: false, twoAnswersUsed: false } },
        B: { name: 'الفريق الثاني', score: 0, lifelines: { callUsed: false, twoAnswersUsed: false } }
      },
      selectedCategorySlugs: [],
      selectedForBoard: undefined,
      usedIds: {},
      current: undefined,
  lifelineOverlay: { active: false, team: 'A', kind: 'call', secondsLeft: 0, total: 0 },
      status: 'active',
      endedAt: undefined
    }
    saveState()
  }

  const endGame = () => {
    state.value.status = 'ended'
    state.value.endedAt = new Date().toISOString()
    saveState()
  }

  const resumeGame = () => {
    state.value.status = 'active'
    state.value.endedAt = undefined
    saveState()
  }

  // اختيار سؤالين لكل مستوى (200/400/600) لكل فئة مختارة
  const initBoardPicks = async () => {
    if (state.value.selectedForBoard) return
    const all = await loadQuestions()
    const bySlug = new Map(all.map(c => [c.slug, c]))

    const picks: SelectedForBoard = {}
    for (const slug of state.value.selectedCategorySlugs) {
      const cat = bySlug.get(slug)
      if (!cat?.entries) {
        console.warn(`فئة ${slug} غير متوفرة أو لا تحتوي على أسئلة`)
        continue
      }
      
    async function pickN(diff: Points, n = 2) {
        const result: string[] = []
        // حاول جلب أسئلة غير مشاهدة من الخادم (لمنع التكرار للمستخدم المسجّل)
        try {
      const res = await previewQuestions({ category: slug, difficulty: diff, limit: n })
      const ids = (res?.questions || []).map((q: any) => q.id as string)
      ids.forEach((id: string) => { if (id && !result.includes(id)) result.push(id) })
        } catch (e) {
          console.warn('nextQuestion فشل أو غير متاح، سيتم استخدام اختيار محلي:', e)
        }

        // اكمل بالاختيار المحلي عند الحاجة
        const arr = (cat?.entries || []).filter(e => e.difficulty === diff).map(e => e.id)
        console.log(`🔍 فئة ${slug} - مستوى ${diff}: عثر على ${arr.length} أسئلة`, arr)
        const pool = arr.filter(id => !result.includes(id))
        shuffleArray(pool)
        while (result.length < n && pool.length) {
          const id = pool.pop()!
          result.push(id)
        }
        // إذا ما زال ناقصًا، اسمح بالتكرار داخل اللوح مثل السابق
        while (result.length < n && arr.length > 0) {
          result.push(arr[Math.floor(Math.random() * arr.length)])
        }

        console.log(`✅ فئة ${slug} - مستوى ${diff}: اختار ${result.length} أسئلة`, result)
        return result
      }
      picks[slug] = { "200": await pickN(200), "400": await pickN(400), "600": await pickN(600) }
    }
    console.log('🎯 selectedForBoard:', picks)
    state.value.selectedForBoard = picks
    state.value.usedIds = state.value.usedIds ?? {}
    saveState()
  }

  function shuffleArray<T>(array: T[]): void {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      ;[array[i], array[j]] = [array[j], array[i]]
    }
  }

  const openCell = (slug: string, difficulty: Points, index: number) => {
    if (!state.value.selectedForBoard) return
    const diffKey = String(difficulty) as '200'|'400'|'600'
    const availableQuestions = state.value.selectedForBoard[slug]?.[diffKey] || []
    
    // تأكد من أن الـ index صحيح (0 أو 1 فقط)
    const safeIndex = Math.min(index, availableQuestions.length - 1)
    const qid = availableQuestions[safeIndex]
    
    if (!qid) {
      console.error(`❌ لم يتم العثور على سؤال: ${slug}, ${difficulty}, index ${index} (safe: ${safeIndex})`)
      return
    }
    
    console.log(`✅ فتح سؤال: ${qid} من ${slug}, ${difficulty}, index ${safeIndex}`)
    state.value.current = { slug, difficulty, index: safeIndex, showing: 'question', qid }
    saveState()
  }

  const revealAnswer = () => {
    if (!state.value.current) return
    state.value.current.showing = 'answer'
    saveState()
  }

  const award = (to?: TeamId) => {
    if (!state.value.current) return
    if (to) state.value.teams[to].score += state.value.current.difficulty
    // علّم السؤال كمستخدم
    state.value.usedIds![state.value.current.qid] = true
    currentAnswer.value = null
    state.value.current = undefined
    saveState()
  }

  const cellUsed = (slug: string, difficulty: Points, index: number): boolean => {
    const id = state.value.selectedForBoard?.[slug]?.[String(difficulty) as '200'|'400'|'600']?.[index]
    return !!(id && state.value.usedIds?.[id])
  }

  function canUseLifeline(team: 'A'|'B', kind: 'call'|'twoAnswers') {
    const ll = state.value.teams[team].lifelines;
    return kind === 'call' ? !ll.callUsed : !ll.twoAnswersUsed;
  }

  function useTwoAnswers(team: 'A'|'B') {
    if (!canUseLifeline(team, 'twoAnswers')) return;
    state.value.teams[team].lifelines.twoAnswersUsed = true;
    saveState();
  }

  function startCallAFriend(team: 'A'|'B') {
    if (!canUseLifeline(team, 'call')) return;
    state.value.teams[team].lifelines.callUsed = true;
    const secs = Math.max(5, state.value.config.callAFriendSec || 60);
    state.value.lifelineOverlay = {
      active: true, team, kind: 'call', secondsLeft: secs, total: secs
    };
    saveState();
  }

  function tickOverlay() {
    if (!state.value.lifelineOverlay?.active) return;
    state.value.lifelineOverlay.secondsLeft = Math.max(0, state.value.lifelineOverlay.secondsLeft - 1);
    if (state.value.lifelineOverlay.secondsLeft === 0) {
      closeOverlay();
    }
    saveState();
  }

  function closeOverlay() {
    if (state.value.lifelineOverlay) {
      state.value.lifelineOverlay.active = false;
    }
    saveState();
  }

  

  // تحميل الحالة عند إنشاء المخزن
  loadState()

  return {
    state, setTeamName, setScore, addScore, setConfig,
    setSelectedSlugs, softReset, hardReset,
    initBoardPicks, openCell, revealAnswer, award, cellUsed,
    currentAnswer,
    canUseLifeline, useTwoAnswers, startCallAFriend, tickOverlay, closeOverlay,
    endGame, resumeGame
  }
})
