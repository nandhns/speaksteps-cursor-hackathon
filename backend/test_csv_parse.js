const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');

const csvPath = path.join(__dirname, 'data', 'exercises.csv');

let count = 0;
fs.createReadStream(csvPath)
  .pipe(csv())
  .on('data', (row) => {
    count++;
    if (count <= 3) {
      console.log(`\n=== Row ${count} ===`);
      console.log(`Exercise ID: ${row.exercise_id}`);
      console.log(`Question ID: ${row.question_id}`);
      console.log(`Cue Functional: "${row.cue_functional}"`);
      console.log(`Cue Rhyming: "${row.cue_rhyming}"`);
      console.log(`Cue Written Initial: "${row.cue_written_initial}"`);
      console.log(`Cue Spelling: "${row.cue_spelling}"`);
      console.log(`Cue Sentence Completion: "${row.cue_sentence_completion}"`);
      console.log(`Cue Phonemic: "${row.cue_phonemic}"`);
      console.log(`Cue Modeling: "${row.cue_modeling}"`);
      
      // Check if cues are shifted
      const allCues = [
        row.cue_functional,
        row.cue_rhyming,
        row.cue_written_initial,
        row.cue_spelling,
        row.cue_sentence_completion,
        row.cue_phonemic,
        row.cue_modeling
      ];
      
      console.log(`\nCues array: [${allCues.map(c => `"${c}"`).join(', ')}]`);
    }
  })
  .on('end', () => {
    console.log(`\n\nTotal rows parsed: ${count}`);
    process.exit(0);
  })
  .on('error', (err) => {
    console.error('Error:', err);
    process.exit(1);
  });
