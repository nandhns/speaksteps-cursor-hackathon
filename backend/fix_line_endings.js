const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data/exercises.csv');

// Read entire file
let content = fs.readFileSync(csvPath, 'utf-8');

// Normalize line endings to LF only
content = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n');

fs.writeFileSync(csvPath, content, 'utf-8');
console.log(`✅ Fixed CSV: Normalized line endings to LF`);
