const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');

const csvPath = path.join(__dirname, 'data', 'exercises.csv');

// Read with csv-parser to get the actual parsed rows
const rows = [];
fs.createReadStream(csvPath)
  .pipe(csv())
  .on('data', (row) => {
    rows.push(row);
  })
  .on('end', () => {
    console.log(`\n📊 CSV Analysis:`);
    console.log(`Total rows: ${rows.length}`);
    
    // Check first row
    const firstRow = rows[0];
    console.log(`\nFirst row (${firstRow.exercise_id}):`);
    console.log(`Columns: ${Object.keys(firstRow).length}`);
    console.log(`Keys: ${Object.keys(firstRow).join(', ')}`);
    
    // Show cues
    console.log(`\nCue values:`);
    console.log(`- cue_functional: "${firstRow.cue_functional}"`);
    console.log(`- cue_rhyming: "${firstRow.cue_rhyming}"`);
    console.log(`- cue_written_initial: "${firstRow.cue_written_initial}"`);
    console.log(`- cue_spelling: "${firstRow.cue_spelling}"`);
    console.log(`- cue_sentence_completion: "${firstRow.cue_sentence_completion}"`);
    console.log(`- cue_phonemic: "${firstRow.cue_phonemic}"`);
    console.log(`- cue_modeling: "${firstRow.cue_modeling}"`);
    
    // Check correct_answer
    console.log(`\ncorrect_answer: "${firstRow.correct_answer}"`);
    
    // The issue: find which field is being overwritten
    console.log(`\nAll fields:`);
    Object.entries(firstRow).forEach(([key, value], idx) => {
      console.log(`  ${idx+1}. ${key}: "${value}"`);
    });
    
    process.exit(0);
  })
  .on('error', (err) => {
    console.error('Error:', err);
    process.exit(1);
  });
