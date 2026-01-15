const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data/exercises.csv');
const content = fs.readFileSync(csvPath, 'utf-8');
const lines = content.split('\n');

console.log('🔧 Removing duplicate body parts exercises...\n');
console.log(`Original line count: ${lines.length}`);

// Keep all lines except the duplicates (lines 81-85, which are indices 81-85 in 0-based)
// The duplicates start at line 81 and are 5 lines
const duplicateStartLine = 81; // 1-based line number
const duplicateCount = 5;

// Filter out the duplicate lines
const fixedLines = lines.filter((line, index) => {
  const lineNum = index + 1; // Convert to 1-based
  // Skip lines 81-85
  if (lineNum >= duplicateStartLine && lineNum < duplicateStartLine + duplicateCount) {
    console.log(`Removing line ${lineNum}: ${line.substring(0, 50)}...`);
    return false;
  }
  return true;
});

console.log(`\nNew line count: ${fixedLines.length}`);
console.log(`Removed: ${lines.length - fixedLines.length} lines`);

// Write to new file first
const outputPath = csvPath + '.no-duplicates';
fs.writeFileSync(outputPath, fixedLines.join('\n'), 'utf-8');
console.log(`\n✅ Saved to: ${outputPath}`);
console.log(`\n⚠️  Next step: Copy-Item "${outputPath}" "${csvPath}" -Force`);
