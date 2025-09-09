const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'proverbs.json');

const raw = fs.readFileSync(filePath, 'utf8');
const data = JSON.parse(raw);

// Group by difficulty
const byDiff = { 200: [], 400: [], 600: [] };
for (const item of data) {
  if (byDiff[item.difficulty]) byDiff[item.difficulty].push(item);
}

function reassign(items, difficulty, prefix) {
  let i = 1;
  return items.map(obj => ({ ...obj, id: `${prefix}-${difficulty}-${i++}` }));
}

const prefix = 'pv';
const ordered = [
  ...reassign(byDiff[200], 200, prefix),
  ...reassign(byDiff[400], 400, prefix),
  ...reassign(byDiff[600], 600, prefix),
];

const formatted = '[\n' + ordered.map(x => '  ' + JSON.stringify(x)).join(',\n') + '\n]';
fs.writeFileSync(filePath, formatted, 'utf8');

console.log('Done.');
console.log(`Counts -> 200: ${byDiff[200].length}, 400: ${byDiff[400].length}, 600: ${byDiff[600].length}`);
console.log(`Total: ${ordered.length}`);
