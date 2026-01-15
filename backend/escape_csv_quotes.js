const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data/exercises.csv');

// Read entire file
const content = fs.readFileSync(csvPath, 'utf-8');
const lines = content.split('\n');

const fixedLines = [];

for (let i = 0; i < lines.length; i++) {
  if (!lines[i].trim()) continue;
  if (i === 0) {
    fixedLines.push(lines[i]);
    continue;
  }
  
  // For data rows, manually parse CSV-style to handle quoted fields
  let fields = [];
  let current = '';
  let inQuotes = false;
  
  for (let j = 0; j < lines[i].length; j++) {
    const char = lines[i][j];
    
    if (char === '"' && !inQuotes) {
      inQuotes = true;
      current += char;
    } else if (char === '"' && inQuotes) {
      // Check if this is an escaped quote (next char is also quote)
      if (lines[i][j + 1] === '"') {
        current += '""'; // Double it
        j++; // Skip next quote
      } else {
        // End of quoted field
        inQuotes = false;
        current += char;
      }
    } else if (char === ',' && !inQuotes) {
      fields.push(current);
      current = '';
    } else {
      current += char;
    }
  }
  
  if (current) {
    fields.push(current);
  }
  
  // Reconstruct the line
  const reconstructed = fields.join(',');
  fixedLines.push(reconstructed);
}

fs.writeFileSync(csvPath, fixedLines.join('\n'), 'utf-8');
console.log(`✅ Fixed CSV: Normalized quote escaping`);
console.log(`   Total lines processed: ${fixedLines.length}`);
