import fs from 'fs';
import path from 'path';
const p = path.resolve(process.cwd(), 'sinjeem-game/public/questions/premierleague.json');
const data = JSON.parse(fs.readFileSync(p, 'utf8'));
const missing = data.filter(x => x.a === '—').map(x => ({ id: x.id, q: x.q }));
console.log(JSON.stringify(missing, null, 2));