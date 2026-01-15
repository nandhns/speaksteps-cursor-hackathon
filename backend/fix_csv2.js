const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data', 'exercises.csv');
let content = fs.readFileSync(csvPath, 'utf-8');

// Fix all writing exercises (pic_to_word)
// Pattern: pic_to_word,image,<image_path>,,,,,<word>
// Should be: pic_to_word,image,<image_path>,,,,<word>
// Change: ,,,,<word>, to ,,,,,<word>,

const lines = content.split('\n');
const fixed = [lines[0]]; // Keep header

for (let i = 1; i < lines.length; i++) {
  let line = lines[i];
  if (!line.trim()) {
    fixed.push(line);
    continue;
  }
  
  // Check if this is a writing exercise (pic_to_word)
  if (line.includes('pic_to_word')) {
    // Find the pattern: ,pic_to_word,image,<path>,,,,,<word>,
    // Replace with: ,pic_to_word,image,<path>,,,,<word>,
    // We need to find the section between stimulus_value and correct_answer with 3 commas
    
    // Better approach: replace ,,,,<non-comma>," with ,,,,,<non-comma>,"
    line = line.replace(/,pic_to_word,image,([^,]+),,,,([^,]+),"/g, ',pic_to_word,image,$1,,,,,$ 2,"');
    // Wait, that's too complex. Let me use a different approach.
    
    // Find all instances of: <image_path>,,,,<word>,"
    // And replace with: <image_path>,,,,,<word>,"
    const imagePath = line.match(/images\/[^,]+/);
    if (imagePath) {
      const path_str = imagePath[0];
      // Find the pattern after the image path
      const pattern = new RegExp(`(${path_str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}),,,,(\\w+),"`);
      if (pattern.test(line)) {
        line = line.replace(pattern, `$1,,,,,$2,"`);
      }
    }
  }
  
  fixed.push(line);
}

fs.writeFileSync(csvPath, fixed.join('\n'));
console.log('✅ CSV fixed: Added missing empty option field to writing exercises');
