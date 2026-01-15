const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data/exercises.csv');

// Read file line by line
const content = fs.readFileSync(csvPath, 'utf-8');
const lines = content.split('\n');

console.log('🔧 Fixing CSV column alignment...\n');

// Keep header as is
const fixedLines = [lines[0]];

// Process data rows (starting from line 1, which is index 1)
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
  
  // Check if this is a writing exercise (empty options)
  // Fields: 0=id, 1=module, 2=title, 3=desc, 4=category, 5=difficulty, 6=question_id, 7=question_type, 8=stimulus_type, 9=stimulus_value
  // 10=option_1, 11=option_2, 12=option_3, 13=option_4, 14=correct_answer, 15=cue_functional, 16=cue_rhyming, 17=cue_written_initial, 18=cue_spelling, 19=cue_sentence_completion, 20=cue_phonemic, 21=cue_modeling
  
  const isWriting = fields[1] === 'writing';
  const hasEmptyOptions = !fields[10] && !fields[11] && !fields[12] && !fields[13];
  
  if (isWriting && hasEmptyOptions) {
    // Writing exercise - need to shift cue columns
    // Current state: correct_answer(14) and cue_functional(15) are empty
    // cue_rhyming(16) has the correct answer
    // cue_written_initial(17) has the functional cue
    // etc.
    
    // Shift: move field 16 → 14, 17 → 15, 18 → 16, etc.
    const correctAnswer = fields[16] || '';  // Was in cue_rhyming
    const cueFunctional = fields[17] || '';  // Was in cue_written_initial
    const cueRhyming = fields[18] || '';     // Was in cue_spelling
    const cueWrittenInitial = fields[19] || ''; // Was in cue_sentence_completion
    const cueSpelling = fields[20] || '';     // Was in cue_phonemic
    const cueSentenceCompletion = fields[21] || ''; // Was in cue_modeling
    const cuePhonemic = fields[22] || '';     // Would be beyond current array
    const cueModeling = fields[23] || '';     // Would be beyond current array
    
    // Rebuild the row with correct positions
    fields[14] = correctAnswer;
    fields[15] = cueFunctional;
    fields[16] = cueRhyming;
    fields[17] = cueWrittenInitial;
    fields[18] = cueSpelling;
    fields[19] = cueSentenceCompletion;
    fields[20] = cuePhonemic;
    fields[21] = cueModeling;
    
    // Trim to expected length
    fields.length = 22;
  }
  
  // Rejoin the line
  const fixedLine = fields.join(',');
  fixedLines.push(fixedLine);
}

// Write back
const outputPath = csvPath + '.fixed';
fs.writeFileSync(outputPath, fixedLines.join('\n'), 'utf-8');
console.log(`✅ Fixed ${fixedLines.length - 1} data rows`);
console.log(`   Total lines: ${fixedLines.length}`);
console.log(`   Output: ${outputPath}`);
console.log(`\n⚠️  Next step: Close the CSV file in the editor, then run:`);
console.log(`   Copy-Item "${outputPath}" "${csvPath}" -Force`);
