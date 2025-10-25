import { ref } from 'vue'
import { defineStore } from 'pinia'
import type { Points, TeamId, SessionState, SelectedForBoard, MediaItem, RouletteOutcome } from '../types'
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
    version: 3,
    createdAt: new Date().toISOString(),
    config: {
      questionTimeSec: 60,
      callAFriendSec: 60
    },
    teams: {
  A: { name: 'الفريق الأول', score: 0, lifelines: { callUsed: false, twoAnswersUsed: false, rouletteUsed: false } },
  B: { name: 'الفريق الثاني', score: 0, lifelines: { callUsed: false, twoAnswersUsed: false, rouletteUsed: false } }
    },
    selectedCategorySlugs: [],
    selectedForBoard: undefined,
    usedIds: {},
    current: undefined,
  currentTurn: 'A',
  currentDouble: false,
  lifelineOverlay: { active: false, team: 'A', kind: 'call', secondsLeft: 0, total: 0 },
    status: 'active',
    endedAt: undefined
  })

  const currentAnswer = ref<AnswerState | null>(null)

  // رقم الإصدار الحالي للـstate schema
  const CURRENT_VERSION = 3
  const migrationHappened = ref(false)

  // تحميل الحالة من localStorage مع migration تلقائي
  const loadState = () => {
    const saved = localStorage.getItem('sessionState')
    if (saved) {
      try {
        const parsed = JSON.parse(saved)
        
        // التحقق من إصدار البيانات
        const savedVersion = parsed.version || 1
        
        if (savedVersion < CURRENT_VERSION) {
          console.warn(`🔄 اكتشاف بيانات قديمة (v${savedVersion}). سيتم تحديثها إلى v${CURRENT_VERSION}`)
          migrationHappened.value = true
          
          // Migration: مسح selectedForBoard إذا كانت البيانات قديمة
          // هذا يجبر اللعبة على إعادة اختيار الأسئلة مع الفئات الجديدة
          if (parsed.selectedForBoard) {
            console.log('🗑️ مسح selectedForBoard القديم - سيتم إعادة بناءه مع الفئات المحدثة')
            parsed.selectedForBoard = undefined
          }
          
          // تحديث رقم الإصدار
          parsed.version = CURRENT_VERSION
          
          // حفظ البيانات المحدّثة
          localStorage.setItem('sessionState', JSON.stringify(parsed))
        }
        
        state.value = { ...state.value, ...parsed }
      } catch (err) {
        console.error('فشل في تحميل الحالة:', err)
        // في حالة الفشل، استخدم state نظيف
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
  state.value.currentTurn = 'A'
  state.value.currentDouble = false
    saveState()
  }

  const hardReset = () => {
    state.value = {
      version: 3,
      createdAt: new Date().toISOString(),
      config: {
        questionTimeSec: 60,
        callAFriendSec: 60
      },
      teams: {
  A: { name: 'الفريق الأول', score: 0, lifelines: { callUsed: false, twoAnswersUsed: false, rouletteUsed: false } },
  B: { name: 'الفريق الثاني', score: 0, lifelines: { callUsed: false, twoAnswersUsed: false, rouletteUsed: false } }
      },
      selectedCategorySlugs: [],
      selectedForBoard: undefined,
      usedIds: {},
      current: undefined,
  currentTurn: 'A',
  currentDouble: false,
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

    // تحقق من أن جميع الفئات المختارة موجودة
    const missingCategories = state.value.selectedCategorySlugs.filter(slug => !bySlug.has(slug))
    if (missingCategories.length > 0) {
      console.error(`❌ فئات مفقودة من ملفات الأسئلة:`, missingCategories)
      console.error(`💡 الحل: امسح localStorage من صفحة الإعدادات أو استخدم: localStorage.clear()`)
      alert(`⚠️ خطأ: بعض الفئات المختارة غير موجودة (${missingCategories.join(', ')})\n\nالرجاء مسح البيانات المحلية من صفحة الإعدادات.`)
      return
    }

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
    if (!state.value.selectedForBoard) {
      console.error(`❌ selectedForBoard غير موجود! يرجى إعادة تهيئة اللوحة`)
      return
    }
    
    const diffKey = String(difficulty) as '200'|'400'|'600'
    const availableQuestions = state.value.selectedForBoard[slug]?.[diffKey] || []
    
    if (availableQuestions.length === 0) {
      console.error(`❌ لا توجد أسئلة متاحة للفئة ${slug} - الصعوبة ${difficulty}`)
      console.error(`📊 selectedForBoard:`, state.value.selectedForBoard)
      console.error(`📊 selectedCategorySlugs:`, state.value.selectedCategorySlugs)
      console.error(`💡 الحل: امسح localStorage أو ابدأ لعبة جديدة`)
      return
    }
    
    // تأكد من أن الـ index صحيح (0 أو 1 فقط)
    const safeIndex = Math.min(index, availableQuestions.length - 1)
    const qid = availableQuestions[safeIndex]
    
    if (!qid) {
      console.error(`❌ لم يتم العثور على سؤال: ${slug}, ${difficulty}, index ${index} (safe: ${safeIndex})`)
      return
    }
    
    console.log(`✅ فتح سؤال: ${qid} من ${slug}, ${difficulty}, index ${safeIndex}`)
  state.value.current = { slug, difficulty, index: safeIndex, showing: 'question', qid }
  // عند فتح سؤال جديد، إلغاء الدبل السابق
  state.value.currentDouble = false
    saveState()
  }

  const revealAnswer = () => {
    if (!state.value.current) return
    state.value.current.showing = 'answer'
    saveState()
  }

  const award = (to?: TeamId) => {
    if (!state.value.current) return
    if (to) {
      const base = state.value.current.difficulty
      const pts = state.value.currentDouble ? base * 2 : base
      state.value.teams[to].score += pts
    }
    // علّم السؤال كمستخدم
    state.value.usedIds![state.value.current.qid] = true
    currentAnswer.value = null
    state.value.current = undefined
    // تبديل الدور إلى الفريق الآخر بعد إنهاء السؤال
    state.value.currentTurn = state.value.currentTurn === 'A' ? 'B' : 'A'
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

  function canUseRoulette(team: 'A'|'B') {
    return !state.value.teams[team].lifelines.rouletteUsed;
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

  // إيقاف/استئناف مؤقت (لشاشة السؤال التي تعدّ داخليًا)
  const paused = ref(false)
  function pauseTimer() { paused.value = true; saveState() }
  function resumeTimer() { paused.value = false; saveState() }

  // روليّت: تنفيذ نتيجة
  function applyRoulette(outcome: RouletteOutcome, actingTeam: TeamId) {
    if (!state.value.current) return
    const base = state.value.current.difficulty
    const other: TeamId = actingTeam === 'A' ? 'B' : 'A'
    if (outcome === 'double') {
      // تفعيل مضاعفة السؤال فقط، ولا نُغلق السؤال
      state.value.currentDouble = true
      state.value.teams[actingTeam].lifelines.rouletteUsed = true
      saveState()
      return
    }
    // تطبيق النتائج الأخرى وإنهاء السؤال مباشرة
    if (outcome === 'gain') {
      state.value.teams[actingTeam].score += base
    } else if (outcome === 'lose') {
      state.value.teams[actingTeam].score = Math.max(0, state.value.teams[actingTeam].score - base)
    } else if (outcome === 'opponentLose') {
      state.value.teams[other].score = Math.max(0, state.value.teams[other].score - base)
    }
    // إنهاء السؤال: اعتباره مستهلكًا والانتقال للدور التالي
    if (state.value.current) {
      state.value.usedIds![state.value.current.qid] = true
      state.value.current = undefined
      state.value.currentDouble = false
      state.value.currentTurn = other
    }
    state.value.teams[actingTeam].lifelines.rouletteUsed = true
    saveState()
  }

  

  // تحميل الحالة عند إنشاء المخزن
  loadState()

  return {
  state, migrationHappened, setTeamName, setScore, addScore, setConfig,
    setSelectedSlugs, softReset, hardReset,
    initBoardPicks, openCell, revealAnswer, award, cellUsed,
  currentAnswer,
    canUseLifeline, useTwoAnswers, startCallAFriend, tickOverlay, closeOverlay,
  endGame, resumeGame,
  // timer controls
  paused, pauseTimer, resumeTimer,
  // roulette
  applyRoulette, canUseRoulette
  }
})
