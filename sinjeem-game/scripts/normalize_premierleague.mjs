import fs from 'fs';
import path from 'path';

const root = path.resolve(process.cwd(), 'sinjeem-game');
const questionsDir = path.join(root, 'public', 'questions');
const srcPath = path.join(questionsDir, 'premierleague_no_answers.json');
const dstPath = path.join(questionsDir, 'premierleague.json');

function loadJson(p) {
  const raw = fs.readFileSync(p, 'utf8');
  return JSON.parse(raw);
}

function saveJson(p, data) {
  const content = JSON.stringify(data, null, 2);
  fs.writeFileSync(p, content + '\n', 'utf8');
}

function normalizeText(s) {
  if (typeof s !== 'string') return s;
  let t = s;
  // Standardize common Arabic terms
  // Variants of "بريمرليغ/البريمرليغ" -> "البريميرليغ"
  t = t.replace(/\bالبريمرليغ\b/g, 'البريميرليغ');
  t = t.replace(/\bبريمرليغ\b/g, 'بريميرليغ');
  // Also fix missing alif-lam where appropriate: "بريميرليغ" within sentence to "البريميرليغ" if preceded by space and not already with ال
  t = t.replace(/([^\p{L}]|^)بريميرليغ/gu, '$1البريميرليغ');
  // Normalize common team/terms typos minimal and safe
  t = t.replace(/مانشيستر/g, 'مانشستر');
  t = t.replace(/قميص\s+.*?\s+الأساسي/g, (m) => m.replace('الأساسي', 'الأساسي'));
  // Trim redundant spaces
  t = t.replace(/\s+/g, (m)=> m.length>1? m.replace(/\s{2,}/g,' '): m).trim();
  return t;
}

function pad(n) { return String(n).padStart(3, '0'); }

function run() {
  const arr = loadJson(srcPath);
  // Preserve appearance order but group by difficulty
  const groups = { '200': [], '400': [], '600': [] };
  for (const item of arr) {
    const diff = String(item.difficulty);
    if (!groups[diff]) groups[diff] = [];
    // Fix typos in question text
    const q = normalizeText(item.q);
    groups[diff].push({ ...item, q });
  }

  // Rebuild arrays with new IDs per difficulty
  const outNoAnswers = [];
  const counts = {};
  for (const diff of ['200', '400', '600']) {
    counts[diff] = 0;
    for (const it of groups[diff] || []) {
      counts[diff]++;
      const id = `premierleague-${diff}-${pad(counts[diff])}`;
      const { tags = [], q } = it;
      outNoAnswers.push({ id, difficulty: Number(diff), q, tags });
    }
  }

  // Write normalized no-answers file back
  saveJson(srcPath, outNoAnswers);

  // Create answers file: mirror entries, add placeholder answer and default image
  const defaultMedia = (alt='الدوري الإنجليزي الممتاز') => ([{ type: 'image', src: '/media/questions/premierleague/default.jfif', alt }]);
  const outWithAnswers = outNoAnswers.map(e => ({
    ...e,
    a: '—',
    media: defaultMedia(),
  }));
  saveJson(dstPath, outWithAnswers);

  // Console summary
  const total = outNoAnswers.length;
  console.log('✅ premierleague normalized');
  console.log('Counts by difficulty:', counts, 'Total:', total);
  console.log('Wrote:', srcPath);
  console.log('Wrote:', dstPath);
}

run();
