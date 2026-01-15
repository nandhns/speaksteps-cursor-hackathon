const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data', 'exercises.csv');
const lines = fs.readFileSync(csvPath, 'utf-8').split('\n');

const fixed = [lines[0]]; // Keep header

for (let i = 1; i < lines.length; i++) {
  let line = lines[i];
  if (!line.trim()) {
    fixed.push(line);
    continue;
  }
  
  // For writing exercises (pic_to_word), the pattern should be:
  // ,pic_to_word,image,<imagepath>,,,,,<word>,"
  // But we currently have:
  // ,pic_to_word,image,<imagepath>,,,, <word>,"  or variations with regex artifacts
  
  // Simply use csv-parser to read, fix, and rewrite
  // Extract parts and reconstruct properly
  
  if (line.includes('pic_to_word')) {
    // Parse manually to fix
    const match = line.match(/^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),pic_to_word,([^,]+),([^,]+),(?:[^,]*,){4}([^,]+),(.+)$/);
    
    if (match) {
      const [,ex_id, module, title, desc, cat, diff, q_id, stim_type, stim_val, word, cues] = match;
      // Reconstruct with correct empty options
      line = `${ex_id},${module},${title},${desc},${cat},${diff},${q_id},pic_to_word,${stim_type},${stim_val},,,,${word},${cues}`;
    }
  }
  
  fixed.push(line);
}

fs.writeFileSync(csvPath, fixed.join('\n'));
console.log('✅ CSV properly fixed!');
