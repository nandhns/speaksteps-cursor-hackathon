@echo off
REM Test Runner Script for SpeakSteps
REM Run all unit and integration tests

echo ==================================
echo SpeakSteps - Full Test Suite
echo ==================================
echo.

set FAILED=0

REM Backend Python Tests
echo Running Backend Python Tests...
echo ==================================
cd backend

echo.
echo 1. Cueing Engine Unit Tests
python test_cueing_engine_unit.py
if errorlevel 1 set FAILED=1

echo.
echo 2. ML Predictor Unit Tests
python test_ml_predictor_unit.py
if errorlevel 1 set FAILED=1

echo.
echo 3. Hierarchical Cueing Tests
python test_hierarchical_cueing.py
if errorlevel 1 set FAILED=1

echo.
echo 4. Performance Timing Tests
python test_performance_timing.py
if errorlevel 1 set FAILED=1

cd ..

REM Frontend Flutter Tests
echo.
echo ==================================
echo Running Frontend Flutter Tests...
echo ==================================
cd frontend

echo.
echo 5. Widget and Unit Tests
flutter test --coverage
if errorlevel 1 set FAILED=1

cd ..

REM Summary
echo.
echo ==================================
echo Test Suite Summary
echo ==================================
if %FAILED%==0 (
    echo ✅ All tests passed!
    exit /b 0
) else (
    echo ❌ Some tests failed. Check output above.
    exit /b 1
)
