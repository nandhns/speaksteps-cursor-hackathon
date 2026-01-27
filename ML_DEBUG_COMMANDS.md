# 🚀 ML Debug Dashboard - Command Reference

## Quick Commands

### START LOCAL DASHBOARD (Right Now)

**Option 1: Windows (Easiest)**
```
Double-click: start_ml_dashboard.bat
```

**Option 2: Command Line**
```bash
cd backend
python ml_debug_runner.py
```

**Option 3: Just the Server**
```bash
cd backend
python ml_debug_server.py
```

**Result:** Browser opens to `http://localhost:8080/debug`

---

## DEPLOYMENT COMMANDS

### Firebase Cloud Functions (Permanent)
```bash
# First time setup
firebase init functions

# Copy the Firebase dashboard script
copy frontend\functions\mlDebug.js functions\

# Deploy
firebase deploy --only functions:mlDebug

# Result: https://YOUR_PROJECT.cloudfunctions.net/mlDebug
```

### Node.js/Express (Your Server)
```bash
# Copy code from frontend/functions/mlDebug.js to your Express app
# Add endpoints to your server
# Deploy as usual

# Then access: https://your-domain.com/ml-debug
```

---

## USAGE COMMANDS

### Run Tests (Local)
```bash
cd backend
python ml_debug_runner.py
# Automatically starts server and runs tests
# Output appears on dashboard
```

### Run Server Only
```bash
cd backend
python ml_debug_server.py
# Server runs, waiting for tests
# Open: http://localhost:8080/debug
# Run your tests separately
```

### Run Tests Separately
```bash
# Terminal 1: Start server
cd backend
python ml_debug_server.py

# Terminal 2: Run your tests
cd backend
python test_cueing_engine_unit.py
# or
python cueing_engine.py
# Output appears on dashboard in Terminal 1's browser
```

### Different Port
```bash
# Use port 3000 instead of 8080
python backend/ml_debug_server.py 3000

# Access: http://localhost:3000/debug
```

---

## API COMMANDS

### Get All Logs
```bash
curl http://localhost:8080/api/logs
```

### Clear All Logs
```bash
curl -X POST http://localhost:8080/api/clear
```

### Post New Log (for remote logging)
```bash
curl -X POST http://localhost:8080/api/logs \
  -H "Content-Type: application/json" \
  -d '{"message": "Test message", "type": "ml"}'
```

### Get Stats (Firebase only)
```bash
curl https://YOUR_PROJECT.cloudfunctions.net/mlDebug/api/stats
```

---

## VIEW COMMANDS

### Open Dashboard in Browser
```bash
# Local
http://localhost:8080/debug

# Or open with command
start http://localhost:8080/debug         # Windows
open http://localhost:8080/debug          # Mac
xdg-open http://localhost:8080/debug      # Linux
```

### View Raw HTML
```bash
curl http://localhost:8080/
```

### Test API
```bash
# Get logs as JSON
curl http://localhost:8080/api/logs | python -m json.tool
```

---

## TROUBLESHOOTING COMMANDS

### Check if Port is in Use
```bash
# Windows
netstat -ano | findstr 8080

# Mac/Linux
lsof -i :8080
```

### Kill Process on Port
```bash
# Windows
taskkill /PID <PID> /F

# Mac/Linux
kill -9 <PID>
```

### Check Python Installation
```bash
python --version
python -m pip list
```

### Run with Verbose Output
```bash
# Windows
python -u backend/ml_debug_server.py

# See all output immediately
```

### Check Browser Console
```
Press F12 in browser
Go to Console tab
Look for errors
```

---

## DEPLOYMENT VERIFICATION

### Local Deployment Check
```bash
# 1. Start server
python backend/ml_debug_runner.py

# 2. In another terminal, check API
curl http://localhost:8080/api/logs

# Should see: [] or [...]
```

### Firebase Deployment Check
```bash
# 1. Deploy
firebase deploy --only functions:mlDebug

# 2. Get your URL from deployment output
# Should be something like:
# https://YOUR_PROJECT.cloudfunctions.net/mlDebug

# 3. Test it
curl https://YOUR_PROJECT.cloudfunctions.net/mlDebug/api/logs

# Should see: [] or [...]
```

---

## DEBUGGING COMMANDS

### Check Server Logs
```bash
# If you see errors, check:
# 1. Is Python installed?
python --version

# 2. Is Flask/dependencies installed?
pip list | findstr flask

# 3. Try running with Python verbose mode
python -v backend/ml_debug_server.py
```

### Monitor Network Traffic
```bash
# Chrome DevTools (F12)
# Go to Network tab
# Refresh dashboard
# You should see:
# - GET /api/logs (200 OK)
# - Response with JSON logs
```

### Check Memory Usage
```bash
# Windows Task Manager
# Ctrl+Shift+Esc
# Find Python process
# Check memory usage

# Should be <50 MB for 500 logs
```

---

## SHARING COMMANDS

### Share Local URL with Assessors
```
Share this URL: http://localhost:8080/debug
Make sure they're on same network!
```

### Share Firebase URL
```
Share this URL: https://YOUR_PROJECT.cloudfunctions.net/mlDebug
Works from anywhere!
```

### Create QR Code (Optional)
```bash
# Generate QR code for URL
# Online tool: qrcode.com or similar
# Scan → Opens dashboard on their phone

URL: http://localhost:8080/debug
```

---

## MAINTENANCE COMMANDS

### Clear All Logs
```bash
# Option 1: Via API
curl -X POST http://localhost:8080/api/clear

# Option 2: Via Browser
# Click "Clear Logs" button on dashboard
```

### Restart Server
```bash
# Stop: Ctrl+C in terminal
# Start: python backend/ml_debug_server.py
```

### Download Logs
```bash
# Via browser: Click "Download Logs" button
# Via API:
curl http://localhost:8080/api/logs > logs.json
```

### Backup Logs
```bash
# Save logs before clearing
curl http://localhost:8080/api/logs > backup-$(date +%s).json

# On Windows:
curl http://localhost:8080/api/logs > backup.json
```

---

## CUSTOMIZATION COMMANDS

### Modify Configuration
```bash
# Edit these files:
backend/ml_debug_server.py       # Change MAX_LOGS, colors, etc.
backend/ml_debug_runner.py       # Change launch behavior
frontend/functions/mlDebug.js    # Change Firebase version
```

### Change Port
```bash
# Change this line in code:
server_address = ('', 8080)

# To:
server_address = ('', 3000)

# Or run:
python ml_debug_server.py 3000
```

### Change Refresh Rate
```javascript
// In dashboard HTML, change:
setInterval(refreshLogs, 500);

// To:
setInterval(refreshLogs, 1000);  // Slower
// Or:
setInterval(refreshLogs, 250);   // Faster
```

---

## PRODUCTION DEPLOYMENT

### Firebase (Recommended)
```bash
# 1. Setup Firebase
firebase init

# 2. Copy function
cp frontend/functions/mlDebug.js functions/mlDebug.js

# 3. Deploy
firebase deploy --only functions:mlDebug

# 4. Get URL from output
# 5. Add to documentation
# 6. Share with stakeholders
```

### Your Server
```bash
# 1. Copy endpoint code from mlDebug.js
# 2. Add to your Express/Node server
# 3. Deploy your app as usual
# 4. Dashboard available at your domain
# 5. Integrate with auth if needed
```

### Docker Deployment
```bash
# Create Dockerfile with Python
# Copy ml_debug_server.py
# Expose port 8080
# Deploy to Docker container

docker build -t ml-debug .
docker run -p 8080:8080 ml-debug
```

---

## WORKFLOW COMMANDS

### Complete Demo Workflow
```bash
# Terminal 1: Start dashboard
cd backend
python ml_debug_runner.py

# Waits for browser to open
# Browser shows: http://localhost:8080/debug

# Terminal 2: Can run additional tests
cd backend
python test_cueing_engine_unit.py

# All output appears in dashboard!
```

### Remote Demo Workflow
```bash
# Step 1: Deploy to Firebase
firebase deploy --only functions:mlDebug

# Step 2: Get URL from output
# Example: https://project.cloudfunctions.net/mlDebug

# Step 3: Share URL with assessor
# They open in their browser

# Step 4: You run tests
cd backend
python cueing_engine.py

# Step 5: Their dashboard updates in real-time!
```

---

## Quick Reference

| Command | Use | Result |
|---------|-----|--------|
| `python ml_debug_runner.py` | Auto-start + tests | Dashboard + logs |
| `python ml_debug_server.py` | Just server | Waiting for logs |
| `python ml_debug_server.py 3000` | Different port | Uses port 3000 |
| `firebase deploy` | Cloud deploy | Permanent URL |
| `curl http://localhost:8080/api/logs` | Check API | JSON logs |
| `Double-click start_ml_dashboard.bat` | Windows easy | One-click start |
| `http://localhost:8080/debug` | Open browser | View dashboard |

---

## Environment Variables (Optional)

```bash
# You can set these if desired:
set ML_DEBUG_PORT=3000
set ML_DEBUG_HOST=0.0.0.0
set ML_DEBUG_MAX_LOGS=1000

# Then code would use them:
python ml_debug_server.py
```

---

## Help Commands

```bash
# Get Python help
python -h
python --version

# Get pip help
pip help
pip list

# Check module installation
python -c "import http.server; print('OK')"

# Run with debugging
python -u ml_debug_server.py    # Unbuffered output
python -m pdb ml_debug_server.py # Debugger
```

---

## Shortcuts

**Windows:**
```
F5 = Refresh dashboard
F12 = Browser developer tools
Ctrl+C = Stop server
Win+R = Run dialog
```

**Mac:**
```
Cmd+R = Refresh
Cmd+Option+I = Developer tools
Ctrl+C = Stop server
```

**Linux:**
```
F5 = Refresh
F12 = Developer tools
Ctrl+C = Stop server
```

---

## Final Checklist

Before demo:
```bash
# 1. Start server
python backend/ml_debug_runner.py

# 2. Check browser opens
# (should show http://localhost:8080/debug)

# 3. Run test
# (wait for logs to appear)

# 4. Verify logs display
# (should see colored logs)

# 5. Test download
# (download button should work)

# 6. Share URL
# (give assessor the URL)

# 7. Done! 🎉
```

---

**You're ready! Pick a command above and get started!** 🚀
