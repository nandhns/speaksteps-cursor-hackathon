const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');

const csvPath = path.join(__dirname, 'data/exercises.csv');
const content = fs.readFileSync(csvPath, 'utf-8');
const records = parse(content, {
  columns: true,
  skip_empty_lines: true,
  relax_column_count: true,
});

console.log('📊 CSV Analysis\n');
console.log(`Total records in CSV: ${records.length}`);

// Check for duplicate IDs
const ids = records.map(r => r.exercise_id);
const duplicateIds = ids.filter((id, index) => ids.indexOf(id) !== index);

if (duplicateIds.length > 0) {
  console.log('\n⚠️  Duplicate IDs found:');
  duplicateIds.forEach(id => {
    const matches = records.filter(r => r.exercise_id === id);
    console.log(`\n  ${id}: ${matches.length} occurrences`);
    matches.forEach((m, i) => {
      console.log(`    [${i + 1}] ${m.module} - ${m.title} - ${m.category}`);
    });
  });
} else {
  console.log('\n✅ No duplicate IDs found in CSV');
}

// Check the body exercises that were marked as duplicates
console.log('\n\n🔍 Checking Body Parts exercises:');
const bodyExercises = records.filter(r => r.exercise_id.includes('BODY'));
console.log(`Found ${bodyExercises.length} body parts exercises:`);
bodyExercises.forEach(r => {
  console.log(`  ${r.exercise_id} - ${r.module} - ${r.title}`);
});

// Check comprehension body exercises specifically
console.log('\n\n🔍 Comprehension Body Parts exercises:');
const compBodyExercises = records.filter(r => 
  r.exercise_id.includes('C_BODY') || 
  (r.module === 'comprehension' && r.category === 'badan')
);
console.log(`Found ${compBodyExercises.length}:`);
compBodyExercises.forEach(r => {
  console.log(`  ${r.exercise_id} - ${r.category} - ${r.title}`);
});
