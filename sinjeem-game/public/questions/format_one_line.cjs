const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'championsleague.json');

// Read the current file
const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

// Format each question on one line
const formattedContent = '[\n' + 
  data.map(item => '  ' + JSON.stringify(item)).join(',\n') + 
  '\n]';

// Write the formatted content back to the file
fs.writeFileSync(filePath, formattedContent, 'utf8');

console.log('File formatted successfully! Each question is now on one line.');
console.log(`Total questions: ${data.length}`);
