# 🚀 Quick Start: ML Debug Dashboard

**Goal:** Show assessors your ML is working in real-time without needing VS Code

## 30-Second Setup

### On Your Local Machine (Testing)

```bash
cd backend
python ml_debug_runner.py
```

✅ Done! Opens browser to `http://localhost:8080/debug`

---

## For Assessors (No Login Needed)

Just share this URL: **`http://localhost:8080/debug`**

Or if deployed: **`https://your-domain.com/ml-debug`**

They see:
- 🧠 Live ML predictions
- 📊 Probability scores
- ✅/⚠️ Cue decisions
- 📈 Real-time statistics
- 💾 Download logs

---

## What They'll See

```
[14:32:45] ======================================================================
[14:32:45] SPEAKSTEPS HYBRID CUEING ENGINE - TEST CASES
[14:32:45] ======================================================================
[14:32:46] ──────────────────────────────────────────────────────────────────
[14:32:46] 📋 Test 1: Easy item, good performance
[14:32:46] ──────────────────────────────────────────────────────────────────
[14:32:46] Input Features:
[14:32:46]   • response_time_seconds: 4.5
[14:32:46]   • attempts_so_far: 0
[14:32:46] 📊 Result:
[14:32:46]   ├─ Cue Type: no_cue
[14:32:46]   ├─ ML Said: No cue
[14:32:46]   ├─ Rules Said: no_cue (stage 0)
[14:32:47]   └─ Reasoning: Quick correct response - no cue needed
```

---

## Deployment Options

### Quick (for local demo)
```bash
python ml_debug_runner.py
# Share: http://localhost:8080/debug
```

### Medium (on your server)
Add to Node.js express server and deploy
(see `frontend/functions/mlDebug.js`)

### Pro (Firebase Cloud Functions)
```bash
firebase deploy --only functions:mlDebug
# Access: https://YOUR_PROJECT.cloudfunctions.net/mlDebug
```

---

## API Endpoints

```
GET  /api/logs       → Get all logs (JSON)
POST /api/clear      → Clear all logs
GET  /api/stats      → Get statistics
POST /api/logs       → Post new log entry
```

---

## Key Features

| Feature | What It Does |
|---------|-------------|
| 🧠 Real-time Logs | See output as it happens |
| 📊 Statistics Panel | Count warnings, ML logs, etc. |
| 🎨 Color Coding | Different colors for different log types |
| 💾 Download | Export logs as `.log` file |
| 🔄 Auto-refresh | Updates every 500ms |
| 🔐 No Login | Direct URL access |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Won't connect | Make sure `python ml_debug_server.py` is running |
| No logs appearing | Check that your tests are actually running |
| Page is blank | Check browser console for errors (F12) |
| Slow performance | Reduce MAX_LOGS value in code |

---

## Show to Assessors Like This

1. **Say:** "Let me show you the ML in action"
2. **Open browser** to: `http://localhost:8080/debug`
3. **Run tests:** `python cueing_engine.py`
4. **Assessor watches:**
   - ML probability scores updating
   - Cue decisions being made
   - Rules being applied
   - All in real-time with color-coded output

**No VS Code needed!** 🎉

---

## For Production Deployment

Once you're ready to deploy:

1. **Check** `ML_DEBUG_DASHBOARD_GUIDE.md` for detailed options
2. **Choose** Option A (Firebase), B (Node.js), or C (Static)
3. **Deploy** to your hosting platform
4. **Share URL** with assessors

---

## Files Created

```
backend/
  ├── ml_debug_server.py      ← Main HTTP server
  └── ml_debug_runner.py      ← Easy launcher script

frontend/
  └── functions/
      └── mlDebug.js          ← Firebase Cloud Function

ML_DEBUG_DASHBOARD_GUIDE.md    ← Full deployment guide
```

---

**Questions?** Check the full guide in `ML_DEBUG_DASHBOARD_GUIDE.md`
