const fs = require('fs');

// Read the file
const data = JSON.parse(fs.readFileSync('championsleague.json', 'utf8'));

// Group by difficulty
const grouped = {
  200: [],
  400: [],
  600: []
};

data.forEach(item => {
  if (grouped[item.difficulty]) {
    grouped[item.difficulty].push(item);
  }
});

// Sort and reassign IDs
let result = [];
let idCounter = {
  200: 1,
  400: 1,
  600: 1
};

// Add questions in order: 200, then 400, then 600
[200, 400, 600].forEach(difficulty => {
  grouped[difficulty].forEach(item => {
    item.id = `ucl-${difficulty}-${idCounter[difficulty]}`;
    idCounter[difficulty]++;
    result.push(item);
  });
});

console.log(`Total questions: ${result.length}`);
console.log(`Difficulty 200: ${grouped[200].length} questions`);
console.log(`Difficulty 400: ${grouped[400].length} questions`);
console.log(`Difficulty 600: ${grouped[600].length} questions`);

// Write back to file
fs.writeFileSync('championsleague.json', JSON.stringify(result, null, 2), 'utf8');
console.log('File reorganized successfully!');
