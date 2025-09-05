import fs from 'fs';
import path from 'path';

const file = path.resolve(process.cwd(), 'sinjeem-game/public/questions/premierleague.json');
const data = JSON.parse(fs.readFileSync(file, 'utf8'));

const map = new Map([
  ['premierleague-200-015', 'إيرلينغ هالاند (36 هدفًا، 2022–23)'],
  ['premierleague-200-021', 'إدين هازارد'],
  ['premierleague-200-037', '2004–05'],
  ['premierleague-400-015', 'أندريه أرشافين'],
  ['premierleague-400-017', '2003'],
  ['premierleague-400-021', '3'],
  ['premierleague-400-027', 'آندي كول'],
  ['premierleague-600-002', '13 مايو 2012'],
]);

let updated = 0;
for (const e of data) {
  const v = map.get(e.id);
  if (v) {
    e.a = v;
    updated++;
  }
}

fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n', 'utf8');
console.log(`Updated ${updated} answers by ID.`);