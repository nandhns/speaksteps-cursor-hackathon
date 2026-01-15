const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data', 'exercises.csv');
const lines = fs.readFileSync(csvPath, 'utf-8').split('\n');

const output = [lines[0]]; // Keep header as-is

for (let i = 1; i < lines.length; i++) {
  const line = lines[i];
  if (!line.trim()) {
    output.push(line);
    continue;
  }
  
  // Use proper CSV parsing
  const values = [];
  let current = '';
  let inQuotes = false;
  
  for (let j = 0; j < line.length; j++) {
    const char = line[j];
    if (char === '"') {
      inQuotes = !inQuotes;
      current += char;
    } else if (char === ',' && !inQuotes) {
      values.push(current);
      current = '';
    } else {
      current += char;
    }
  }
  if (current) values.push(current);
  
  // Check if this is a comprehension exercise with missing stimulus_type
  if (values[7] === 'word_to_pic' && values.length === 21) {
    // Insert "text" as stimulus_type after question_type (position 8)
    const fixed = [
      ...values.slice(0, 8),
      'text',  // Add stimulus_type
      ...values.slice(8)
    ];
    output.push(fixed.join(','));
  } else {
    output.push(line);
  }
}

fs.writeFileSync(csvPath, output.join('\n'));
console.log('✅ CSV fixed successfully!');
console.log(`Processed ${lines.length} lines`);
