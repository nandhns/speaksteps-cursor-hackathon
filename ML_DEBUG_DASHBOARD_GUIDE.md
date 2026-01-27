# ML Debug Dashboard - Deployment Guide

## Overview

The ML Debug Dashboard is a **no-login-required** web interface that displays real-time ML cueing engine debug information. Perfect for showing assessors how the ML is working in action.

## Quick Start (Local Testing)

### Option 1: Simple Python Server (Fastest)

```bash
cd backend
python ml_debug_runner.py
```

This will:
- Start the debug server on `http://localhost:8080`
- Open your browser automatically
- Run cueing engine tests and display output live
- No authentication required

Visit: **http://localhost:8080/debug**

### Option 2: Just Server (No Tests)

```bash
cd backend
python ml_debug_server.py
```

Then manually run your tests:
```bash
python test_cueing_engine_unit.py
# or
python cueing_engine.py  # if it has test code
```

Output will appear in the dashboard automatically.

---

## Deployment to Hosted Website

### Prerequisites
- Node.js/Express backend OR Firebase Cloud Functions
- Static hosting (Firebase, Netlify, Vercel, etc.)

### Option A: Firebase Cloud Functions (Recommended)

1. **Create a new function** in `functions/`:

```bash
firebase functions:new
```

Name it: `mlDebugServer`

2. **Install dependencies** in `functions/package.json`:

```json
{
  "dependencies": {
    "firebase-functions": "^4.0.0",
    "firebase-admin": "^11.0.0",
    "express": "^4.18.0"
  }
}
```

3. **Add to `functions/index.js`**:

```javascript
const functions = require('firebase-functions');
const express = require('express');
const admin = require('firebase-admin');

admin.initializeApp();

const app = express();

// Global log storage
const logs = [];
const MAX_LOGS = 500;

// Override console methods to capture logs
const originalLog = console.log;
console.log = function(...args) {
  const message = args.join(' ');
  const timestamp = new Date().toLocaleTimeString();
  
  logs.push({
    timestamp,
    message: message.trim(),
    type: categorizeLog(message)
  });
  
  if (logs.length > MAX_LOGS) {
    logs.shift();
  }
  
  originalLog(...args);
};

function categorizeLog(text) {
  if (text.includes('⚠️') || text.toLowerCase().includes('error')) return 'warning';
  if (text.includes('✅') || text.toLowerCase().includes('passed')) return 'success';
  if (text.includes('📊') || text.toLowerCase().includes('result')) return 'info';
  if (text.includes('🧠') || text.toLowerCase().includes('ml')) return 'ml';
  return 'default';
}

// API endpoint for logs
app.get('/api/logs', (req, res) => {
  res.json(logs);
});

// API endpoint to clear logs
app.post('/api/clear', (req, res) => {
  logs.length = 0;
  res.json({ status: 'cleared' });
});

// Dashboard HTML
app.get('/', (req, res) => {
  res.type('html').send(getDashboardHTML());
});

function getDashboardHTML() {
  // Return the same HTML from ml_debug_server.py
  // (copy the HTML from the Python file)
  return `<!DOCTYPE html>...`;
}

exports.mlDebug = functions.https.onRequest(app);
```

4. **Deploy**:

```bash
firebase deploy --only functions:mlDebug
```

Access at: `https://your-firebase-project.cloudfunctions.net/mlDebug`

### Option B: Node.js/Express Backend

1. **Install dependencies**:

```bash
npm install express cors body-parser
```

2. **Add to your Express app**:

```javascript
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());

// Global logs
const logs = [];
const MAX_LOGS = 500;

// Capture console output
const originalLog = console.log;
console.log = function(...args) {
  const message = args.join(' ');
  const timestamp = new Date().toLocaleTimeString();
  
  logs.push({
    timestamp,
    message: message.trim(),
    type: categorizeLog(message)
  });
  
  if (logs.length > MAX_LOGS) logs.shift();
  originalLog(...args);
};

// API Routes
app.get('/api/logs', (req, res) => res.json(logs));
app.post('/api/clear', (req, res) => {
  logs.length = 0;
  res.json({ status: 'cleared' });
});

// Dashboard
app.get('/ml-debug', (req, res) => res.type('html').send(dashboardHTML));

// Start server
app.listen(8080, () => {
  console.log('ML Debug dashboard: http://localhost:8080/ml-debug');
});
```

3. **Access**: 

`http://your-server.com/ml-debug`

### Option C: Static Hosting (No Backend Logs)

For Netlify, Vercel, or Firebase Hosting - just need a way to run Python on-demand:

1. Use a **Netlify Function** or **Vercel Serverless Function** to:
   - Accept POST requests with log messages
   - Store in a simple JSON file or database
   - Return logs via GET

2. Update the dashboard to POST logs:

```javascript
// In dashboard JavaScript
fetch('/api/log', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ message, timestamp })
});
```

3. Python script POSTs to the endpoint:

```python
import requests

def log_to_dashboard(message):
    requests.post(
        'https://your-site.com/api/log',
        json={'message': message, 'timestamp': datetime.now().isoformat()}
    )
```

---

## Features

✨ **Real-time Streaming** - Logs appear instantly as tests run
🔴 **Color-coded** - Warning, Success, ML, Info each have unique colors
📊 **Statistics** - Count of logs by type (ML, warnings, successes)
💾 **Download** - Export logs as `.log` file
🚀 **No Login** - Direct URL access, perfect for assessors
⚡ **Fast** - Updates every 500ms
🎨 **Terminal Theme** - Professional dark terminal aesthetic

---

## For Assessors

Share this URL with assessors:

```
https://your-domain.com/ml-debug
```

They can:
1. Open the link in any browser (no login needed)
2. See real-time ML decision-making
3. Watch probability calculations
4. See cue recommendations
5. Download logs for later review

---

## Running Tests Remotely

Once deployed, you can trigger tests via:

```bash
# SSH into server
ssh your-server

# Run tests (output appears in dashboard)
cd backend
python cueing_engine.py
```

Or from Windows:
```bash
# If using Cloud Functions, you can trigger via API
curl -X POST https://your-firebase-project.cloudfunctions.net/mlDebug/run-tests
```

---

## Customization

### Change Port
```python
python ml_debug_server.py 3000  # Use port 3000 instead
```

### Change Refresh Rate
In the dashboard HTML, change:
```javascript
setInterval(refreshLogs, 500);  // Change 500 to something else
```

### Add Custom Log Categories
Edit the `_categorize()` method in Python or `categorizeLog()` in JavaScript.

### Change Colors
Edit the CSS in the dashboard HTML:
```css
.log-entry.ml {
    color: #ffff00;  /* Change ML log color */
}
```

---

## Troubleshooting

**"Cannot connect to dashboard"**
- Check Python server is running: `python ml_debug_server.py`
- Check port is accessible: `http://localhost:8080/debug`
- Check firewall isn't blocking port 8080

**"Logs not appearing"**
- Make sure tests are actually running
- Check console.log/print statements are being executed
- Try `/api/logs` endpoint directly in browser

**"Dashboard is slow"**
- Reduce log count: `MAX_LOGS = 200` in code
- Increase refresh interval: `setInterval(refreshLogs, 1000)`

**"CORS errors"**
- Make sure CORS headers are set (added in examples)
- If on different domain, verify CORS is enabled

---

## Security Note

This dashboard has **no authentication**. If deployed publicly, it will show all logs to anyone with the URL. 

To add authentication, add a simple password check:

```javascript
// In ml_debug_server.py
if self.path.startswith('/debug'):
    auth = self.headers.get('Authorization', '')
    if auth != 'Bearer SECRET_TOKEN':
        self.send_response(401)
        return
```

Or use Firebase Authentication as a middleware.

---

## Example Use Case

**During Assessment Meeting:**

1. Assessor opens: `https://speaksteps.com/ml-debug`
2. You run: `python cueing_engine.py` on your laptop
3. Assessor sees live:
   - ML probability scores
   - Cue decisions
   - Performance levels
   - Test results
4. Assessor can download logs for review

This proves your ML is working without needing to look at VS Code! 🎉

