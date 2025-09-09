const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'premierleague.json');

const raw = fs.readFileSync(filePath, 'utf8');
const data = JSON.parse(raw);

// Normalize IDs to new prefix 'pl' with non-padded counters
function reassignIds(items, difficulty, prefix){
  let i = 1;
  return items.map(obj => ({...obj, id: `${prefix}-${difficulty}-${i++}`}));
}

const byDiff = { 200: [], 400: [], 600: [] };
for (const item of data) {
  if (byDiff[item.difficulty]) byDiff[item.difficulty].push(item);
}

const prefix = 'pl';
const out = [
  ...reassignIds(byDiff[200], 200, prefix),
  ...reassignIds(byDiff[400], 400, prefix),
  ...reassignIds(byDiff[600], 600, prefix),
];

const formatted = '[\n' + out.map(x => '  ' + JSON.stringify(x)).join(',\n') + '\n]';
fs.writeFileSync(filePath, formatted, 'utf8');

console.log('Done.');
console.log(`Counts -> 200: ${byDiff[200].length}, 400: ${byDiff[400].length}, 600: ${byDiff[600].length}`);
console.log(`Total: ${out.length}`);
