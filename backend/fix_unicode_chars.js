const fs = require('fs');
const path = require('path');

const csvPath = path.join(__dirname, 'data/exercises.csv');

// Read entire file
let content = fs.readFileSync(csvPath, 'utf-8');

// Replace problematic Unicode characters
content = content.replace(/…/g, '...'); // Replace ellipsis with three dots
content = content.replace(/'/g, "'"); // Replace curly single quote with straight quote (if any)
content = content.replace(/"/g, '"'); // Replace curly double quotes with straight quotes (left)
content = content.replace(/"/g, '"'); // Replace curly double quotes with straight quotes (right)

fs.writeFileSync(csvPath, content, 'utf-8');
console.log(`✅ Fixed CSV: Replaced Unicode characters with ASCII equivalents`);
