#!/usr/bin/env python3
"""
ML Debug Runner
===============
Runs cueing engine tests with real-time debug output captured
and displayed in a browser dashboard (no login required).

Usage:
    python ml_debug_runner.py

Then open: http://localhost:8080/debug in your browser
"""

import subprocess
import sys
import threading
import time

def start_debug_server():
    """Start debug server in background."""
    try:
        import ml_debug_server
        ml_debug_server.start_debug_server()
    except Exception as e:
        print(f"Error starting debug server: {e}")

def run_cueing_tests():
    """Run cueing engine tests with output captured."""
    try:
        import cueing_engine
        
        # Run the test cases
        print("\n" + "="*70)
        print("🚀 STARTING CUEING ENGINE TESTS")
        print("="*70 + "\n")
        
        cueing_engine.run_test_cases()
        
        print("\n" + "="*70)
        print("✅ TESTS COMPLETED")
        print("="*70)
        
    except Exception as e:
        print(f"❌ Error running tests: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    print("\n🧠 SpeakSteps ML Debug Dashboard Launcher")
    print("="*70)
    print("\n1️⃣  Starting debug server...")
    
    # Start server in background thread
    server_thread = threading.Thread(target=start_debug_server, daemon=True)
    server_thread.start()
    
    # Give server time to start
    time.sleep(2)
    
    print("\n2️⃣  Opening browser to http://localhost:8080/debug")
    print("   (If it doesn't open automatically, copy-paste the URL)")
    
    # Try to open browser
    try:
        import webbrowser
        webbrowser.open('http://localhost:8080/debug')
    except:
        print("   ℹ️  Could not auto-open browser, open manually above")
    
    print("\n3️⃣  Running cueing engine tests...")
    print("-"*70 + "\n")
    
    # Run tests
    run_cueing_tests()
    
    print("\n" + "="*70)
    print("📊 Dashboard available at: http://localhost:8080/debug")
    print("🔄 Tests will continue to run and update the dashboard")
    print("⏹️  Press Ctrl+C to stop the server")
    print("="*70 + "\n")
    
    # Keep server running
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n\n👋 Shutting down...")
        sys.exit(0)
