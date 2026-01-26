#!/bin/bash

# Test Runner Script for SpeakSteps
# Run all unit and integration tests

echo "=================================="
echo "SpeakSteps - Full Test Suite"
echo "=================================="
echo ""

# Track overall status
FAILED=0

# Backend Python Tests
echo "Running Backend Python Tests..."
echo "=================================="
cd backend

echo ""
echo "1. Cueing Engine Unit Tests"
python3 test_cueing_engine_unit.py
if [ $? -ne 0 ]; then FAILED=1; fi

echo ""
echo "2. ML Predictor Unit Tests"
python3 test_ml_predictor_unit.py
if [ $? -ne 0 ]; then FAILED=1; fi

echo ""
echo "3. Hierarchical Cueing Tests"
python3 test_hierarchical_cueing.py
if [ $? -ne 0 ]; then FAILED=1; fi

echo ""
echo "4. Performance Timing Tests"
python3 test_performance_timing.py
if [ $? -ne 0 ]; then FAILED=1; fi

cd ..

# Frontend Flutter Tests
echo ""
echo "=================================="
echo "Running Frontend Flutter Tests..."
echo "=================================="
cd frontend

echo ""
echo "5. Widget and Unit Tests"
flutter test --coverage
if [ $? -ne 0 ]; then FAILED=1; fi

cd ..

# Summary
echo ""
echo "=================================="
echo "Test Suite Summary"
echo "=================================="
if [ $FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed. Check output above."
    exit 1
fi
