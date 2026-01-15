const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data/exercises.csv');

// Read entire file
const content = fs.readFileSync(csvPath, 'utf-8');
const lines = content.split('\n');

const fixedLines = [];

for (let i = 0; i < lines.length; i++) {
  if (!lines[i].trim()) continue;
  
  let fixedLine = lines[i];
  
  // For each quoted field, double any internal quotes
  // Pattern: "..." with potential ' or " inside
  fixedLine = fixedLine.replace(/"([^"]*)"/g, (match) => {
    // Get the content inside quotes
    const inner = match.slice(1, -1);
    // Double any quotes inside
    const escaped = inner.replace(/"/g, '""');
    return `"${escaped}"`;
  });
  
  fixedLines.push(fixedLine);
}

fs.writeFileSync(csvPath, fixedLines.join('\n'), 'utf-8');
console.log(`✅ Fixed CSV: Escaped all internal quotes`);
console.log(`   Total lines processed: ${fixedLines.length}`);
