import fs from 'fs';
import path from 'path';

const root = '/home/mohannad/Videos/sen-gem/sinjeem-game/public/questions';
const currentPath = path.join(root, 'football.json');
const backupPath = path.join(root, 'football.json.bak');
const outBackupPath = path.join(root, 'football.json.with_answers.backup');

const readJSON = (p) => JSON.parse(fs.readFileSync(p, 'utf8'));

const exist = fs.existsSync(currentPath) && fs.existsSync(backupPath);
if (!exist) {
  console.error('Missing files. Expected football.json and football.json.bak');
  process.exit(1);
}

const cur = readJSON(currentPath);
const bak = readJSON(backupPath);

const bakById = new Map(bak.map(o => [o.id, o]));

let filled = 0;
let total = 0;
let mismatches = [];

const merged = cur.map(o => {
  total++;
  const prev = bakById.get(o.id);
  if (prev && prev.q && prev.a && prev.q.trim() === o.q.trim()) {
    filled++;
    return { ...o, a: prev.a };
  } else if (prev && prev.a && !prev.q) {
    // very unlikely; safeguard
    return { ...o, a: prev.a };
  } else if (prev && prev.a) {
    mismatches.push({ id: o.id, prevQ: prev.q, curQ: o.q });
    return { ...o, a: '' };
  }
  return { ...o, a: '' };
});

// backup current
fs.writeFileSync(outBackupPath, fs.readFileSync(currentPath));
// write merged sorted by id for stability
merged.sort((a,b)=> a.id.localeCompare(b.id));
fs.writeFileSync(currentPath, JSON.stringify(merged, null, 2));

const byDiff = merged.reduce((m,o)=>{m[o.difficulty]=(m[o.difficulty]||0)+1;return m;},{});
console.log(JSON.stringify({ total, filled, remaining: total-filled, byDiff, mismatchesCount: mismatches.length }, null, 2));
if (mismatches.length) {
  // print only first few to avoid noise
  console.log('First mismatches:', mismatches.slice(0, 10));
}
