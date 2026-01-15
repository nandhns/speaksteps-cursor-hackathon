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

console.log('🔧 Fixing comprehension exercise structure...\n');

// Analyze the structure
const comp1 = records.find(r => r.exercise_id === 'EX_C_ANI_E_001');

console.log('Current structure for EX_C_ANI_E_001:');
console.log('  stimulus_type:', comp1.stimulus_type);
console.log('  stimulus_value:', comp1.stimulus_value);
console.log('  option_1:', comp1.option_1);
console.log('  option_2:', comp1.option_2);
console.log('  option_3:', comp1.option_3);
console.log('  option_4:', comp1.option_4);
console.log('  correct_answer:', comp1.correct_answer);
console.log('  cue_functional:', comp1.cue_functional);

console.log('\n💡 Understanding:');
console.log('For comprehension (word_to_pic):');
console.log('  - Question: Show text/audio "Haiwan ini mengeong dan suka bermain."');
console.log('  - Options: Show 4 images, one is correct (images/kucing.png)');
console.log('  - Patient selects the correct image');

console.log('\n📋 Correct structure should be:');
console.log('  stimulus_type: "audio" or "text"');
console.log('  stimulus_value: "Haiwan ini mengeong dan suka bermain." (the question)');
console.log('  option_1: "images/kucing.png" (correct answer image)');
console.log('  option_2: "images/anjing.png"');
console.log('  option_3: "images/ikan.png"');
console.log('  option_4: "images/ayam.png"');
console.log('  correct_answer: "images/kucing.png" or "0" (index of correct option)');

console.log('\n🔄 Current CSV has:');
console.log('  stimulus_value = images/kucing.png (should be the question text!)');
console.log('  option_1-3 = wrong answer images (correct)');
console.log('  option_4 = 1 (index)');
console.log('  correct_answer = the question text (wrong!)');

console.log('\n⚠️  The comprehension exercises need restructuring:');
console.log('   1. Move stimulus_value (image) to option_1');
console.log('   2. Move correct_answer (text) to stimulus_value');
console.log('   3. Shift options: option_1→option_2, option_2→option_3, option_3→option_4');
console.log('   4. Set correct_answer to image path or "0"');
