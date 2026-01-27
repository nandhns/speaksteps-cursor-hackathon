/**
 * SpeakSteps ML Debug Dashboard - Firebase Cloud Function
 * 
 * Deploy to Firebase:
 *   firebase deploy --only functions:mlDebug
 * 
 * Access at:
 *   https://YOUR_PROJECT_ID.cloudfunctions.net/mlDebug
 */

const functions = require('firebase-functions');
const express = require('express');

const app = express();

// Global log storage
const logs = [];
const MAX_LOGS = 500;

// Middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

// ============================================================================
// API ENDPOINTS
// ============================================================================

/**
 * GET /api/logs - Retrieve all captured logs
 */
app.get('/api/logs', (req, res) => {
  res.json(logs);
});

/**
 * POST /api/logs - Add a new log (for remote logging)
 */
app.post('/api/logs', express.json(), (req, res) => {
  const { message, type = 'default', timestamp } = req.body;
  
  if (!message) {
    return res.status(400).json({ error: 'Message required' });
  }
  
  logs.push({
    timestamp: timestamp || new Date().toLocaleTimeString(),
    message: String(message).trim(),
    type: type || categorizeLog(message)
  });
  
  // Keep only recent logs
  if (logs.length > MAX_LOGS) {
    logs.shift();
  }
  
  res.json({ status: 'logged', count: logs.length });
});

/**
 * POST /api/clear - Clear all logs
 */
app.post('/api/clear', (req, res) => {
  logs.length = 0;
  res.json({ status: 'cleared' });
});

/**
 * GET /api/stats - Get log statistics
 */
app.get('/api/stats', (req, res) => {
  const stats = {
    total: logs.length,
    by_type: {
      default: 0,
      warning: 0,
      success: 0,
      info: 0,
      test: 0,
      ml: 0
    }
  };
  
  logs.forEach(log => {
    stats.by_type[log.type]++;
  });
  
  res.json(stats);
});

// ============================================================================
// DASHBOARD ENDPOINT
// ============================================================================

app.get('/', (req, res) => {
  res.type('html').send(getDashboardHTML());
});

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

function categorizeLog(text) {
  const str = String(text).toLowerCase();
  
  if (text.includes('⚠️') || str.includes('error') || str.includes('warning')) {
    return 'warning';
  }
  if (text.includes('✅') || str.includes('passed') || str.includes('success')) {
    return 'success';
  }
  if (text.includes('📊') || str.includes('result') || str.includes('metric')) {
    return 'info';
  }
  if (text.includes('🧠') || text.includes('probability') || str.includes('ml') || str.includes('predict')) {
    return 'ml';
  }
  if (text.includes('📋') || str.includes('test')) {
    return 'test';
  }
  
  return 'default';
}

function getDashboardHTML() {
  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SpeakSteps ML Debug Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Monaco', 'Courier New', monospace;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #00ff88;
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            background: rgba(0, 255, 136, 0.1);
            border: 2px solid #00ff88;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 0 20px rgba(0, 255, 136, 0.2);
        }
        
        h1 {
            font-size: 28px;
            margin-bottom: 10px;
            text-shadow: 0 0 10px rgba(0, 255, 136, 0.5);
        }
        
        .subtitle {
            font-size: 14px;
            color: #00cc66;
            opacity: 0.8;
        }
        
        .controls {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            flex-wrap: wrap;
        }
        
        button {
            background: #00ff88;
            color: #1a1a2e;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            font-family: inherit;
            transition: all 0.3s;
        }
        
        button:hover {
            background: #00cc66;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 255, 136, 0.3);
        }
        
        button:active {
            transform: translateY(0);
        }
        
        .status {
            display: inline-block;
            padding: 8px 16px;
            background: rgba(0, 255, 136, 0.2);
            border: 1px solid #00ff88;
            border-radius: 5px;
            font-size: 13px;
        }
        
        .status.connected::before {
            content: "● ";
            color: #00ff88;
        }
        
        .status.disconnected::before {
            content: "● ";
            color: #ff4444;
        }
        
        .dashboard {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        @media (max-width: 1200px) {
            .dashboard {
                grid-template-columns: 1fr;
            }
        }
        
        .card {
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid #00ff88;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 0 20px rgba(0, 255, 136, 0.1);
        }
        
        .card h2 {
            font-size: 18px;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #00ff88;
            color: #00ffff;
        }
        
        .log-container {
            background: rgba(0, 0, 0, 0.5);
            border: 1px solid #00ff88;
            border-radius: 6px;
            padding: 15px;
            height: 500px;
            overflow-y: auto;
            font-size: 13px;
            line-height: 1.6;
        }
        
        .log-entry {
            margin-bottom: 8px;
            padding: 8px;
            border-left: 3px solid transparent;
            border-radius: 3px;
            animation: slideIn 0.3s ease-out;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(-10px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }
        
        .log-entry.default { border-left-color: #00ff88; color: #00ff88; }
        .log-entry.warning { border-left-color: #ffaa00; color: #ffaa00; background: rgba(255, 170, 0, 0.1); }
        .log-entry.success { border-left-color: #00ff88; color: #00ff88; background: rgba(0, 255, 136, 0.1); }
        .log-entry.info { border-left-color: #00ffff; color: #00ffff; background: rgba(0, 255, 255, 0.05); }
        .log-entry.test { border-left-color: #ff6699; color: #ff6699; background: rgba(255, 102, 153, 0.05); }
        .log-entry.ml { border-left-color: #ffff00; color: #ffff00; background: rgba(255, 255, 0, 0.08); }
        
        .log-time {
            opacity: 0.6;
            font-size: 11px;
            color: #00cc66;
        }
        
        .log-message {
            word-break: break-word;
            white-space: pre-wrap;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .stat {
            background: rgba(0, 255, 136, 0.05);
            border: 1px solid #00ff88;
            border-radius: 5px;
            padding: 12px;
            text-align: center;
        }
        
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #00ffff;
        }
        
        .stat-label {
            font-size: 12px;
            color: #00cc66;
            margin-top: 5px;
        }
        
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: rgba(0, 255, 136, 0.1); border-radius: 10px; }
        ::-webkit-scrollbar-thumb { background: #00ff88; border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #00cc66; }
        
        .empty-state {
            color: #00cc66;
            text-align: center;
            padding: 40px 20px;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🧠 SpeakSteps ML Debug Dashboard</h1>
            <p class="subtitle">Real-time ML Cueing Engine Monitoring</p>
            <div class="controls">
                <button onclick="toggleAutoScroll()">Auto-scroll: ON</button>
                <button onclick="clearLogs()">Clear Logs</button>
                <button onclick="downloadLogs()">Download Logs</button>
                <div class="status connected" id="status">Connected</div>
            </div>
        </header>
        
        <div class="dashboard">
            <div class="card">
                <h2>📊 Statistics</h2>
                <div class="stats">
                    <div class="stat">
                        <div class="stat-value" id="logCount">0</div>
                        <div class="stat-label">Total Logs</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" id="mlLogs">0</div>
                        <div class="stat-label">ML Logs</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" id="warningCount">0</div>
                        <div class="stat-label">Warnings</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" id="successCount">0</div>
                        <div class="stat-label">Success</div>
                    </div>
                </div>
            </div>
            
            <div class="card">
                <h2>🎛️ Controls</h2>
                <p style="margin-bottom: 15px; color: #00cc66; font-size: 13px;">
                    Real-time monitoring of ML cueing engine debug output.
                </p>
                <button onclick="refreshLogs()" style="width: 100%; margin-bottom: 10px;">
                    🔄 Refresh Now
                </button>
                <div style="background: rgba(0, 255, 136, 0.05); border: 1px solid #00cc66; padding: 10px; 
                            border-radius: 4px; font-size: 12px; line-height: 1.5;">
                    <div><strong>API Endpoint:</strong> /api/logs</div>
                    <div style="margin-top: 10px; color: #ffaa00;">
                        💡 Share this URL with assessors to see live ML in action!
                    </div>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>📜 Debug Output</h2>
            <div class="log-container" id="logContainer">
                <div class="empty-state">Waiting for logs...</div>
            </div>
        </div>
    </div>
    
    <script>
        let autoScroll = true;
        let previousLogCount = 0;
        
        async function refreshLogs() {
            try {
                const response = await fetch('/api/logs');
                const logs = await response.json();
                
                if (logs.length !== previousLogCount) {
                    renderLogs(logs);
                    updateStats(logs);
                    previousLogCount = logs.length;
                }
                
                document.getElementById('status').className = 'status connected';
            } catch (error) {
                document.getElementById('status').className = 'status disconnected';
            }
        }
        
        function updateStats(logs) {
            const mlLogs = logs.filter(l => l.type === 'ml').length;
            const warnings = logs.filter(l => l.type === 'warning').length;
            const success = logs.filter(l => l.type === 'success').length;
            
            document.getElementById('logCount').textContent = logs.length;
            document.getElementById('mlLogs').textContent = mlLogs;
            document.getElementById('warningCount').textContent = warnings;
            document.getElementById('successCount').textContent = success;
        }
        
        function renderLogs(logs) {
            const container = document.getElementById('logContainer');
            
            if (logs.length === 0) {
                container.innerHTML = '<div class="empty-state">No logs yet...</div>';
                return;
            }
            
            container.innerHTML = logs.map(log => \`
                <div class="log-entry \${log.type}">
                    <div class="log-time">[\${log.timestamp}]</div>
                    <div class="log-message">\${escapeHtml(log.message)}</div>
                </div>
            \`).join('');
            
            if (autoScroll) {
                container.scrollTop = container.scrollHeight;
            }
        }
        
        function escapeHtml(text) {
            const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
            return text.replace(/[&<>"']/g, m => map[m]);
        }
        
        function toggleAutoScroll() {
            autoScroll = !autoScroll;
            event.target.textContent = 'Auto-scroll: ' + (autoScroll ? 'ON' : 'OFF');
        }
        
        async function clearLogs() {
            if (confirm('Clear all logs?')) {
                await fetch('/api/clear', { method: 'POST' });
                previousLogCount = 0;
                refreshLogs();
            }
        }
        
        function downloadLogs() {
            fetch('/api/logs')
                .then(r => r.json())
                .then(logs => {
                    const text = logs.map(l => \`[\${l.timestamp}] \${l.message}\`).join('\\n');
                    const blob = new Blob([text], { type: 'text/plain' });
                    const url = URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = \`ml-debug-\${Date.now()}.log\`;
                    a.click();
                });
        }
        
        // Auto-refresh every 500ms
        refreshLogs();
        setInterval(refreshLogs, 500);
    </script>
</body>
</html>
`;
}

// ============================================================================
// EXPORT AS CLOUD FUNCTION
// ============================================================================

exports.mlDebug = functions.https.onRequest(app);

// Optional: Create a scheduled function to rotate logs every hour
exports.rotateLogs = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(() => {
    const maxAge = 3600000; // 1 hour
    const now = Date.now();
    // Could implement log archiving here
    return null;
  });
