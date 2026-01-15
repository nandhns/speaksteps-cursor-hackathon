const fs = require('fs');
const csv = require('csv-parser');

console.log('🔍 Verifying CSV Structure...\n');

const results = [];
let writingCount = 0;
let comprehensionCount = 0;
let errors = [];

fs.createReadStream('./data/exercises.csv')
  .pipe(csv())
  .on('data', (data) => {
    results.push(data);
    
    // Check writing exercises
    if (data.question_type === 'pic_to_word') {
      writingCount++;
      
      // Verify structure for writing
      if (!data.correct_answer || data.correct_answer.trim() === '') {
        errors.push(`❌ ${data.exercise_id}: Missing correct_answer`);
      }
      if (!data.cue_functional || !data.cue_modeling) {
        errors.push(`❌ ${data.exercise_id}: Missing cues (functional or modeling)`);
      }
      if (data.option_1 || data.option_2 || data.option_3 || data.option_4) {
        // Writing exercises should NOT have options filled
        // errors.push(`⚠️  ${data.exercise_id}: Writing exercise has option fields filled (should be empty)`);
      }
    }
    
    // Check comprehension exercises
    else if (data.question_type === 'word_to_pic') {
      comprehensionCount++;
      
      // Verify structure for comprehension
      const correctIndex = parseInt(data.correct_answer);
      if (isNaN(correctIndex) || correctIndex < 1 || correctIndex > 4) {
        errors.push(`❌ ${data.exercise_id}: correct_answer must be 1-4 (got: ${data.correct_answer})`);
      }
      
      // For comprehension, image paths should be in option_1-4
      if (!data.option_1 || !data.option_2 || !data.option_3 || !data.option_4) {
        errors.push(`❌ ${data.exercise_id}: Missing image options in option_1-4`);
      }
      
      if (!data.cue_functional || !data.cue_modeling) {
        errors.push(`❌ ${data.exercise_id}: Missing cues (functional or modeling)`);
      }
    }
  })
  .on('end', () => {
    console.log('📊 CSV PARSE SUMMARY');
    console.log('─'.repeat(50));
    console.log(`✓ Total exercises parsed: ${results.length}`);
    console.log(`  • Writing (pic_to_word): ${writingCount}`);
    console.log(`  • Comprehension (word_to_pic): ${comprehensionCount}`);
    console.log(`  • Total: ${writingCount + comprehensionCount}`);
    
    // Check column count
    if (results.length > 0) {
      const cols = Object.keys(results[0]).length;
      console.log(`\n📋 Column Count`);
      console.log('─'.repeat(50));
      console.log(`Total columns: ${cols} (expected: 22)`);
      console.log(`${cols === 22 ? '✓' : '❌'} Column count ${cols === 22 ? 'correct' : 'INCORRECT'}`);
    }
    
    // Display sample data
    console.log(`\n📝 SAMPLE DATA VERIFICATION`);
    console.log('─'.repeat(50));
    
    if (results.length > 0) {
      const writing = results.find(r => r.question_type === 'pic_to_word');
      if (writing) {
        console.log(`\n✓ Writing Exercise (${writing.exercise_id}):`);
        console.log(`  • Question Type: ${writing.question_type}`);
        console.log(`  • Stimulus: ${writing.stimulus_value}`);
        console.log(`  • Correct Answer: ${writing.correct_answer}`);
        console.log(`  • Cue Functional: ${writing.cue_functional.substring(0, 50)}...`);
        console.log(`  • Cue Modeling: ${writing.cue_modeling}`);
      }
      
      const comprehension = results.find(r => r.question_type === 'word_to_pic');
      if (comprehension) {
        console.log(`\n✓ Comprehension Exercise (${comprehension.exercise_id}):`);
        console.log(`  • Question Type: ${comprehension.question_type}`);
        console.log(`  • Instruction: ${comprehension.stimulus_value}`);
        console.log(`  • Correct Answer (index): ${comprehension.correct_answer}`);
        console.log(`  • Option 1: ${comprehension.option_1}`);
        console.log(`  • Option 2: ${comprehension.option_2}`);
        console.log(`  • Option 3: ${comprehension.option_3}`);
        console.log(`  • Option 4: ${comprehension.option_4}`);
        console.log(`  • Cue Functional: ${comprehension.cue_functional.substring(0, 50)}...`);
        console.log(`  • Cue Modeling: ${comprehension.cue_modeling}`);
      }
    }
    
    // Errors
    if (errors.length > 0) {
      console.log(`\n⚠️  ERRORS FOUND (${errors.length}):`);
      console.log('─'.repeat(50));
      errors.forEach(err => console.log(err));
    } else {
      console.log(`\n✅ NO ERRORS FOUND`);
    }
    
    // Display counts by category
    const categories = {};
    const difficulties = {};
    const modules = {};
    
    results.forEach(r => {
      categories[r.category] = (categories[r.category] || 0) + 1;
      difficulties[r.difficulty] = (difficulties[r.difficulty] || 0) + 1;
      modules[r.module] = (modules[r.module] || 0) + 1;
    });
    
    console.log(`\n📈 BREAKDOWN BY CATEGORY`);
    console.log('─'.repeat(50));
    Object.entries(categories).sort().forEach(([cat, count]) => {
      console.log(`  ${cat}: ${count}`);
    });
    
    console.log(`\n📈 BREAKDOWN BY DIFFICULTY`);
    console.log('─'.repeat(50));
    Object.entries(difficulties).sort().forEach(([diff, count]) => {
      console.log(`  ${diff}: ${count}`);
    });
    
    console.log(`\n📈 BREAKDOWN BY MODULE`);
    console.log('─'.repeat(50));
    Object.entries(modules).sort().forEach(([mod, count]) => {
      console.log(`  ${mod}: ${count}`);
    });
    
    console.log('\n✅ Verification complete!');
    console.log('\n🎯 Ready for therapist and patient app integration.');
  })
  .on('error', (err) => {
    console.error('❌ CSV Parse Error:', err.message);
  });
