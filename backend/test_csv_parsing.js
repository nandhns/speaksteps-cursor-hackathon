const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');

const csvPath = path.join(__dirname, 'data/exercises.csv');
const csvContent = fs.readFileSync(csvPath, 'utf-8');

console.log('Testing CSV parsing with different options...\n');

// Test 1: No special options
try {
  const records = parse(csvContent, {
    columns: true,
  });
  console.log('✅ Test 1 (basic): SUCCESS -', records.length, 'records');
} catch (e) {
  console.log('❌ Test 1 (basic): FAILED -', e.message);
}

// Test 2: With skip_empty_lines
try {
  const records = parse(csvContent, {
    columns: true,
    skip_empty_lines: true,
  });
  console.log('✅ Test 2 (skip empty): SUCCESS -', records.length, 'records');
} catch (e) {
  console.log('❌ Test 2 (skip empty): FAILED -', e.message);
}

// Test 3: With trim
try {
  const records = parse(csvContent, {
    columns: true,
    trim: true,
  });
  console.log('✅ Test 3 (trim): SUCCESS -', records.length, 'records');
} catch (e) {
  console.log('❌ Test 3 (trim): FAILED -', e.message);
}

// Test 4: With all options from deep_cleanup
try {
  const records = parse(csvContent, {
    columns: true,
    skip_empty_lines: true,
    trim: true,
    relax_column_count: true,
  });
  console.log('✅ Test 4 (all): SUCCESS -', records.length, 'records');
} catch (e) {
  console.log('❌ Test 4 (all): FAILED -', e.message);
}

// Test 5: Without quote option
try {
  const records = parse(csvContent, {
    columns: true,
    skip_empty_lines: true,
    trim: true,
    relax_column_count: true,
    quote: false,
  });
  console.log('✅ Test 5 (no quotes): SUCCESS -', records.length, 'records');
} catch (e) {
  console.log('❌ Test 5 (no quotes): FAILED -', e.message);
}
