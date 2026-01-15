const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data/exercises.csv');

// Read file line by line
const content = fs.readFileSync(csvPath, 'utf-8');
const lines = content.split('\n');

console.log('🔧 Fixing CSV structure for both writing and comprehension exercises...\n');

// Keep header as is
const fixedLines = [lines[0]];
let writingFixed = 0;
let comprehensionFixed = 0;

// Process data rows
for (let i = 1; i < lines.length; i++) {
  const line = lines[i].trim();
  if (!line) continue;
  
  // Split by comma, handling quoted fields
  const fields = [];
  let current = '';
  let inQuotes = false;
  
  for (let j = 0; j < line.length; j++) {
    const char = line[j];
    
    if (char === '"') {
      inQuotes = !inQuotes;
      current += char;
    } else if (char === ',' && !inQuotes) {
      fields.push(current);
      current = '';
    } else {
      current += char;
    }
  }
  if (current) fields.push(current);
  
  const module = fields[1]; // module is at index 1
  
  if (module === 'comprehension') {
    // Comprehension exercise - need to restructure
    // Current positions:
    // 8: stimulus_type = "Pilih gambar: KUCING"
    // 9: stimulus_value = "images/kucing.png" (correct answer image)
    // 10: option_1 = "images/anjing.png"
    // 11: option_2 = "images/ikan.png"
    // 12: option_3 = "images/ayam.png"
    // 13: option_4 = "1" (index)
    // 14: correct_answer = "Haiwan ini mengeong dan suka bermain." (question text)
    
    // New structure should be:
    // 8: stimulus_type = "audio" or "text"
    // 9: stimulus_value = "Haiwan ini mengeong dan suka bermain." (question text)
    // 10: option_1 = "images/kucing.png" (correct answer image)
    // 11: option_2 = "images/anjing.png"
    // 12: option_3 = "images/ikan.png"
    // 13: option_4 = "images/ayam.png"
    // 14: correct_answer = "images/kucing.png" or "0"
    
    const correctImagePath = fields[9] || ''; // Current stimulus_value
    const questionText = fields[14] || ''; // Current correct_answer
    const option1Wrong = fields[10] || ''; // Current option_1
    const option2Wrong = fields[11] || ''; // Current option_2
    const option3Wrong = fields[12] || ''; // Current option_3
    
    // Restructure
    fields[8] = 'audio'; // stimulus_type
    fields[9] = questionText; // stimulus_value (the question)
    fields[10] = correctImagePath; // option_1 (correct answer)
    fields[11] = option1Wrong; // option_2
    fields[12] = option2Wrong; // option_3
    fields[13] = option3Wrong; // option_4
    fields[14] = correctImagePath; // correct_answer (image path)
    
    // Keep cues as they are (fields 15-21)
    fields.length = 22; // Ensure proper length
    comprehensionFixed++;
  }
  
  // Writing exercises are already fixed, just ensure proper length
  if (module === 'writing') {
    fields.length = 22;
    writingFixed++;
  }
  
  // Rejoin the line
  const fixedLine = fields.join(',');
  fixedLines.push(fixedLine);
}

// Write to new file
const outputPath = csvPath + '.comprehension-fixed';
fs.writeFileSync(outputPath, fixedLines.join('\n'), 'utf-8');
console.log(`✅ Fixed ${fixedLines.length - 1} data rows`);
console.log(`   - Writing exercises: ${writingFixed}`);
console.log(`   - Comprehension exercises: ${comprehensionFixed}`);
console.log(`   Output: ${outputPath}`);
console.log(`\n⚠️  Next step: Review the fixed file, then run:`);
console.log(`   Copy-Item "${outputPath}" "${csvPath}" -Force`);
