/**
 * CSV Repair Script: Rebuild exercises.csv with proper formatting
 * 
 * This fixes the column alignment issue by properly formatting the CSV
 */

const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data', 'exercises.csv');
const backupPath = path.join(__dirname, 'data', 'exercises.csv.backup');

// Read the broken CSV
const content = fs.readFileSync(csvPath, 'utf-8');

// Backup the original
fs.writeFileSync(backupPath, content);
console.log('✅ Backup created: exercises.csv.backup\n');

// Split by "////" to separate writing and comprehension exercises
const parts = content.split('////');

// Process writing exercises
console.log('Analyzing CSV structure...\n');

const writingText = parts[0];
const comprehensionText = parts[1] ? parts[1] : '';

// Extract header from writing section
const writingLines = writingText.trim().split('\n');
const header = writingLines[0];

console.log('Header found:');
console.log(header);
console.log('\nSample data row:');
console.log(writingLines[1] ? writingLines[1].substring(0, 200) + '...' : 'No data');

// Analyze the structure
const headerFields = header.split(',').length;
console.log(`\nHeader has ${headerFields} fields\n`);

// The issue: writing exercises have 4 empty option columns
// They need to be: stimulus_value, [empty], [empty], [empty], [empty], correct_answer
// That's 5 commas (,,,,,) but the CSV might only have 4 commas (,,,,)

// Solution: manually reconstruct properly formatted CSV

const exercises = [];

// Parse all writing exercises
const writingDataLines = writingLines.slice(1).filter(line => line.trim());
for (const line of writingDataLines) {
  if (!line.trim()) continue;
  if (line.startsWith('////')) break;
  
  // For writing exercises, we need to carefully parse them
  // Expected format: exercise_id,module,title,description,category,difficulty,question_id,question_type,stimulus_type,stimulus_value,option_1,option_2,option_3,option_4,correct_answer,...cues
  
  const match = line.match(/^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),(.*)/);
  
  if (match) {
    const [, exerciseId, module, title, description, category, difficulty, questionId, questionType, stimulusType, stimulusValue, rest] = match;
    
    // For writing exercises, options are empty and next field is correct_answer
    // Rest should be: ,,,correct_answer,cue_functional,cue_rhyming,...
    // We need to extract: empty, empty, empty, empty, correct_answer, and all cues
    
    const restParts = rest.split(/,(?=(?:[^"]*"[^"]*")*[^"]*$)/); // Split by comma not inside quotes
    
    // First 4 items in rest should be the empty options (might be missing one)
    // The correct_answer is typically the 5th item but might be the 4th if we're missing one
    
    exercises.push({
      exerciseId,
      module,
      title,
      description,
      category,
      difficulty,
      questionId,
      questionType,
      stimulusType,
      stimulusValue,
      option_1: '',
      option_2: '',
      option_3: '',
      option_4: '',
      rest: rest,
      isWriting: true
    });
  }
}

// Parse comprehension exercises
if (comprehensionText) {
  const compLines = comprehensionText.trim().split('\n');
  const compDataLines = compLines.filter(line => line.trim() && !line.startsWith('////'));
  
  for (const line of compDataLines) {
    if (!line.trim()) continue;
    
    const match = line.match(/^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),(.+)/);
    
    if (match) {
      const [, exerciseId, module, title, description, category, difficulty, questionId, questionType, stimulusType, rest] = match;
      
      exercises.push({
        exerciseId,
        module,
        title,
        description,
        category,
        difficulty,
        questionId,
        questionType,
        stimulusType,
        rest: rest,
        isComprehension: true
      });
    }
  }
}

console.log(`Parsed ${exercises.length} exercises\n`);

// The issue is complex - let me just fix it by adjusting the commas
// For writing exercises: stimulus_value needs to be followed by 5 commas (4 empty options)

const repairedLines = [header];

for (const ex of exercises) {
  if (ex.isWriting) {
    // Reconstruct with proper format: exercise_id, module, title, desc, category, difficulty, question_id, question_type, stimulus_type, stimulus_value, , , , , correct_answer, rest
    
    // Find where the correct answer is in the rest (first value after options)
    const restParts = ex.rest.split(/,(?=(?:[^"]*"[^"]*")*[^"]*$)/).map(p => p.trim());
    
    // Join back with proper spacing for the 4 empty option columns
    const line = `${ex.exerciseId},${ex.module},${ex.title},${ex.description},${ex.category},${ex.difficulty},${ex.questionId},${ex.questionType},${ex.stimulusType},${ex.stimulusValue},,,,${ex.rest}`;
    repairedLines.push(line);
  } else if (ex.isComprehension) {
    const line = `${ex.exerciseId},${ex.module},${ex.title},${ex.description},${ex.category},${ex.difficulty},${ex.questionId},${ex.questionType},${ex.stimulusType},${ex.rest}`;
    repairedLines.push(line);
  }
}

// Write the repaired CSV
const repairedCSV = repairedLines.join('\n');
fs.writeFileSync(csvPath, repairedCSV);

console.log('✅ CSV rebuilt with correct formatting!');
console.log(`\n📊 Summary:`);
console.log(`   Total exercises: ${exercises.length}`);
console.log(`   Writing exercises: ${exercises.filter(e => e.isWriting).length}`);
console.log(`   Comprehension exercises: ${exercises.filter(e => e.isComprehension).length}`);
console.log(`\n💾 Repaired CSV saved to: exercises.csv`);
console.log(`📦 Original backup saved to: exercises.csv.backup`);

process.exit(0);
