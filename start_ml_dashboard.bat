@echo off
REM SpeakSteps ML Debug Dashboard Launcher
REM Easy one-click launch for Windows users

echo.
echo ========================================
echo   SpeakSteps ML Debug Dashboard
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Change to backend directory
cd /d "%~dp0backend"

if errorlevel 1 (
    echo ERROR: Could not navigate to backend directory
    pause
    exit /b 1
)

echo [OK] Python found
echo.
echo Starting ML Debug Dashboard...
echo.
echo ========================================
echo Browser will open to:
echo   http://localhost:8080/debug
echo ========================================
echo.

REM Launch the debug runner
python ml_debug_runner.py

if errorlevel 1 (
    echo.
    echo ERROR: Failed to start dashboard
    echo Make sure these files exist:
    echo   - backend\ml_debug_runner.py
    echo   - backend\ml_debug_server.py
    echo   - backend\cueing_engine.py
    pause
    exit /b 1
)

pause
