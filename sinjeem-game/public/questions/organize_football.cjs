const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'football.json');

// Read the current file
const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

// Group questions by difficulty
const questionsByDifficulty = {
  200: [],
  400: [],
  600: []
};

data.forEach(item => {
  if (questionsByDifficulty[item.difficulty]) {
    questionsByDifficulty[item.difficulty].push(item);
  }
});

// Reassign IDs sequentially for each difficulty level
const reorganizedQuestions = [];

// Add difficulty 200 questions
questionsByDifficulty[200].forEach((item, index) => {
  item.id = `fb-200-${index + 1}`;
  reorganizedQuestions.push(item);
});

// Add difficulty 400 questions
questionsByDifficulty[400].forEach((item, index) => {
  item.id = `fb-400-${index + 1}`;
  reorganizedQuestions.push(item);
});

// Add difficulty 600 questions
questionsByDifficulty[600].forEach((item, index) => {
  item.id = `fb-600-${index + 1}`;
  reorganizedQuestions.push(item);
});

// Format each question on one line
const formattedContent = '[\n' + 
  reorganizedQuestions.map(item => '  ' + JSON.stringify(item)).join(',\n') + 
  '\n]';

// Write the formatted content back to the file
fs.writeFileSync(filePath, formattedContent, 'utf8');

console.log('File organized and formatted successfully!');
console.log(`Total questions: ${reorganizedQuestions.length}`);
console.log(`Difficulty 200: ${questionsByDifficulty[200].length} questions`);
console.log(`Difficulty 400: ${questionsByDifficulty[400].length} questions`);
console.log(`Difficulty 600: ${questionsByDifficulty[600].length} questions`);
