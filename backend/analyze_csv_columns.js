const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');

const csvPath = path.join(__dirname, 'data/exercises.csv');

// Read and parse CSV
const content = fs.readFileSync(csvPath, 'utf-8');
const records = parse(content, {
  columns: true,
  skip_empty_lines: true,
  relax_column_count: true,
});

console.log('🔍 Analyzing CSV structure...\n');
console.log(`First record fields:`);
console.log(`  option_1: "${records[0].option_1}"`);
console.log(`  option_2: "${records[0].option_2}"`);
console.log(`  option_3: "${records[0].option_3}"`);
console.log(`  option_4: "${records[0].option_4}"`);
console.log(`  correct_answer: "${records[0].correct_answer}"`);
console.log(`  cue_functional: "${records[0].cue_functional}"`);
console.log(`  cue_rhyming: "${records[0].cue_rhyming}"`);
console.log(`  cue_written_initial: "${records[0].cue_written_initial}"`);
console.log(`  cue_spelling: "${records[0].cue_spelling}"`);
console.log(`  cue_sentence_completion: "${records[0].cue_sentence_completion}"`);
console.log(`  cue_phonemic: "${records[0].cue_phonemic}"`);
console.log(`  cue_modeling: "${records[0].cue_modeling}"`);

console.log(`\n\nSecond record (comprehension) fields:`);
const compRecord = records.find(r => r.module === 'comprehension');
if (compRecord) {
  console.log(`  option_1: "${compRecord.option_1}"`);
  console.log(`  option_2: "${compRecord.option_2}"`);
  console.log(`  option_3: "${compRecord.option_3}"`);
  console.log(`  option_4: "${compRecord.option_4}"`);
  console.log(`  correct_answer: "${compRecord.correct_answer}"`);
  console.log(`  cue_functional: "${compRecord.cue_functional}"`);
}
