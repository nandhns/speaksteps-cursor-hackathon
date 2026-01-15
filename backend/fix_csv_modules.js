const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data/exercises.csv');

// Read entire file and convert line by line
const content = fs.readFileSync(csvPath, 'utf-8');
const lines = content.split('\n');
const headers = lines[0];

// Convert module names in all data rows
const fixedLines = [headers];
for (let i = 1; i < lines.length; i++) {
  let line = lines[i];
  if (!line.trim()) continue; // Skip empty lines
  
  // Replace Malay module names with English at the start of data (after exercise_id,)
  line = line.replace(/^([^,]+),penulisan,/, '$1,writing,');
  line = line.replace(/^([^,]+),kefahaman,/, '$1,comprehension,');
  fixedLines.push(line);
}

fs.writeFileSync(csvPath, fixedLines.join('\n'), 'utf-8');
console.log(`✅ Fixed CSV: Converted Malay module names to English`);
console.log(`   Total lines processed: ${fixedLines.length - 1}`);
