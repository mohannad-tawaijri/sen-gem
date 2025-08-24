export type Points = 200 | 400 | 600;
export type TeamId = 'A' | 'B';
export type LifelineKind = 'call' | 'twoAnswers';
export type GameStatus = 'active' | 'ended';

export interface MediaItem {
  type: 'image';
  src: string;      // مثال: "/media/questions/flags/japan.png"
  alt?: string;
}

export interface SeedEntry {
  id: string;
  difficulty: Points;
  q: string;
  a: string;
  media?: MediaItem[];      // ← جديد (اختياري)
  tags?: string[];
  secret?: string;          // للـ QR: قيمة مخصصة تظهر على هاتف اللاعب (اختياري)
}

export interface SeedCategory {
  slug: string;
  name: string;
  image?: string;           // ← جديد: صورة الغلاف للفئة
  entries?: SeedEntry[];    // ← جعل entries اختيارية لدعم التحميل المرحلي
}

export interface QuestionsFile {
  version: number;
  locale: 'ar' | string;
  categories: SeedCategory[];
}

export interface TeamState {
  name: string;
  score: number;
  lifelines: { callUsed: boolean; twoAnswersUsed: boolean };
}

export interface Config {
  questionTimeSec: number;
  callAFriendSec: number;
}

export interface SelectedForBoard {
  [slug: string]: { "200": string[]; "400": string[]; "600": string[]; }
}

export interface CurrentPtr {
  slug: string;
  difficulty: Points;
  index: number;             // 0 | 1
  showing: 'question' | 'answer';
  qid: string;
}

export interface SessionState {
  version: 1 | 2;
  createdAt: string;
  config: Config;
  teams: Record<TeamId, TeamState>;
  selectedCategorySlugs: string[];
  selectedForBoard?: SelectedForBoard;
  usedIds?: Record<string, boolean>;
  current?: CurrentPtr;
  lifelineOverlay?: {
    active: boolean;
    team: TeamId;
    kind: LifelineKind;
    secondsLeft: number;
    total: number;
  };
  ui?: { projector: boolean };
  status: GameStatus;
  endedAt?: string;
}
