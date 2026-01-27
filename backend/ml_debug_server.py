"""
SpeakSteps ML Debug Server
===========================
A lightweight HTTP server that captures and displays ML cueing engine
debug information in a browser without requiring authentication.

Usage:
    python ml_debug_server.py

Then open: http://localhost:8080/debug
"""

from http.server import HTTPServer, SimpleHTTPRequestHandler
import json
import threading
import sys
from datetime import datetime
from io import StringIO
import os

# Global log storage
class DebugLogger:
    def __init__(self):
        self.logs = []
        self.max_logs = 500
        self.lock = threading.Lock()
    
    def write(self, text):
        """Capture print statements."""
        if text.strip():
            with self.lock:
                timestamp = datetime.now().strftime("%H:%M:%S")
                log_entry = {
                    'timestamp': timestamp,
                    'message': text.strip(),
                    'type': self._categorize(text)
                }
                self.logs.append(log_entry)
                
                # Keep only recent logs
                if len(self.logs) > self.max_logs:
                    self.logs = self.logs[-self.max_logs:]
        
        # Also print to original stdout
        sys.__stdout__.write(text)
    
    def flush(self):
        pass
    
    def _categorize(self, text):
        """Categorize log messages for styling."""
        if '⚠️' in text or 'error' in text.lower():
            return 'warning'
        elif '✅' in text or 'passed' in text.lower():
            return 'success'
        elif '📊' in text or 'result' in text.lower():
            return 'info'
        elif '📋' in text or 'test' in text.lower():
            return 'test'
        elif 'probability' in text.lower() or 'ml' in text.lower():
            return 'ml'
        else:
            return 'default'
    
    def get_logs(self):
        """Get all logs as JSON."""
        with self.lock:
            return list(self.logs)
    
    def clear_logs(self):
        """Clear all logs."""
        with self.lock:
            self.logs = []

# Initialize logger
debug_logger = DebugLogger()

class DebugRequestHandler(SimpleHTTPRequestHandler):
    """HTTP request handler for debug dashboard."""
    
    def do_GET(self):
        """Handle GET requests."""
        # API endpoint for getting logs
        if self.path == '/api/logs':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            logs = debug_logger.get_logs()
            self.wfile.write(json.dumps(logs).encode())
            return
        
        # API endpoint for clearing logs
        if self.path == '/api/clear':
            debug_logger.clear_logs()
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({'status': 'cleared'}).encode())
            return
        
        # Serve debug dashboard
        if self.path == '/debug' or self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(self.get_debug_dashboard().encode())
            return
        
        # 404
        self.send_response(404)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'Not Found')
    
    def log_message(self, format, *args):
        """Suppress default logging."""
        pass
    
    def get_debug_dashboard(self):
        """Return the HTML dashboard."""
        return """
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
            margin: 5px 0;
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
        
        .log-entry.default {
            border-left-color: #00ff88;
            color: #00ff88;
        }
        
        .log-entry.warning {
            border-left-color: #ffaa00;
            color: #ffaa00;
            background: rgba(255, 170, 0, 0.1);
        }
        
        .log-entry.success {
            border-left-color: #00ff88;
            color: #00ff88;
            background: rgba(0, 255, 136, 0.1);
        }
        
        .log-entry.info {
            border-left-color: #00ffff;
            color: #00ffff;
            background: rgba(0, 255, 255, 0.05);
        }
        
        .log-entry.test {
            border-left-color: #ff6699;
            color: #ff6699;
            background: rgba(255, 102, 153, 0.05);
        }
        
        .log-entry.ml {
            border-left-color: #ffff00;
            color: #ffff00;
            background: rgba(255, 255, 0, 0.08);
        }
        
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
        
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-top: 10px;
        }
        
        .info-item {
            background: rgba(0, 255, 136, 0.05);
            border: 1px solid #00cc66;
            padding: 10px;
            border-radius: 4px;
            font-size: 12px;
        }
        
        .info-label {
            color: #00cc66;
            font-weight: bold;
        }
        
        .info-value {
            color: #00ffff;
            font-family: monospace;
        }
        
        ::-webkit-scrollbar {
            width: 8px;
        }
        
        ::-webkit-scrollbar-track {
            background: rgba(0, 255, 136, 0.1);
            border-radius: 10px;
        }
        
        ::-webkit-scrollbar-thumb {
            background: #00ff88;
            border-radius: 10px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: #00cc66;
        }
        
        .empty-state {
            color: #00cc66;
            text-align: center;
            padding: 40px 20px;
            opacity: 0.7;
        }
        
        .footer {
            text-align: center;
            padding: 20px;
            color: #00cc66;
            font-size: 12px;
            border-top: 1px solid #00ff88;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🧠 SpeakSteps ML Debug Dashboard</h1>
            <p class="subtitle">Real-time ML Cueing Engine Monitoring</p>
            <div class="controls">
                <button onclick="autoScroll = !autoScroll; this.textContent = 'Auto-scroll: ' + (autoScroll ? 'ON' : 'OFF')">
                    Auto-scroll: ON
                </button>
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
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Last Update:</div>
                        <div class="info-value" id="lastUpdate">--:--:--</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Session Time:</div>
                        <div class="info-value" id="sessionTime">00:00:00</div>
                    </div>
                </div>
            </div>
            
            <div class="card">
                <h2>🎛️ Controls</h2>
                <p style="margin-bottom: 15px; color: #00cc66; font-size: 13px;">
                    Real-time monitoring of ML cueing engine debug output. Shows probability calculations, 
                    cue decisions, and performance metrics as they happen.
                </p>
                <button onclick="refreshLogs()" style="width: 100%; margin-bottom: 10px;">
                    🔄 Refresh Now
                </button>
                <div style="background: rgba(0, 255, 136, 0.05); border: 1px solid #00cc66; padding: 10px; 
                            border-radius: 4px; font-size: 12px; line-height: 1.5;">
                    <div><strong>Auto-refresh:</strong> Every 500ms</div>
                    <div><strong>Max logs kept:</strong> Last 500 entries</div>
                    <div><strong>API endpoint:</strong> /api/logs</div>
                    <div style="margin-top: 10px; color: #ffaa00;">
                        💡 Tip: Monitor this while running cueing engine tests
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
        
        <div class="footer">
            <p>🚀 SpeakSteps ML Debug Dashboard | Scroll down for new entries | No authentication required</p>
        </div>
    </div>
    
    <script>
        let autoScroll = true;
        let sessionStartTime = new Date();
        let previousLogs = [];
        
        async function refreshLogs() {
            try {
                const response = await fetch('/api/logs');
                const logs = await response.json();
                
                // Update stats
                updateStats(logs);
                
                // Check for new logs
                if (logs.length !== previousLogs.length || 
                    (logs.length > 0 && previousLogs.length > 0 && 
                     logs[logs.length - 1].timestamp !== previousLogs[previousLogs.length - 1].timestamp)) {
                    renderLogs(logs);
                    previousLogs = logs;
                }
            } catch (error) {
                document.getElementById('status').textContent = 'Disconnected';
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
            
            if (logs.length > 0) {
                document.getElementById('lastUpdate').textContent = logs[logs.length - 1].timestamp;
            }
            
            // Update session time
            const now = new Date();
            const elapsed = Math.floor((now - sessionStartTime) / 1000);
            const hours = Math.floor(elapsed / 3600);
            const minutes = Math.floor((elapsed % 3600) / 60);
            const seconds = elapsed % 60;
            document.getElementById('sessionTime').textContent = 
                String(hours).padStart(2, '0') + ':' +
                String(minutes).padStart(2, '0') + ':' +
                String(seconds).padStart(2, '0');
            
            // Update status
            if (logs.length > 0) {
                document.getElementById('status').textContent = 'Connected';
                document.getElementById('status').className = 'status connected';
            }
        }
        
        function renderLogs(logs) {
            const container = document.getElementById('logContainer');
            
            if (logs.length === 0) {
                container.innerHTML = '<div class="empty-state">No logs yet...</div>';
                return;
            }
            
            container.innerHTML = logs.map(log => `
                <div class="log-entry ${log.type}">
                    <div class="log-time">[${log.timestamp}]</div>
                    <div class="log-message">${escapeHtml(log.message)}</div>
                </div>
            `).join('');
            
            // Auto-scroll to bottom
            if (autoScroll) {
                container.scrollTop = container.scrollHeight;
            }
        }
        
        function escapeHtml(text) {
            const map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return text.replace(/[&<>"']/g, m => map[m]);
        }
        
        async function clearLogs() {
            if (confirm('Are you sure you want to clear all logs?')) {
                await fetch('/api/clear');
                previousLogs = [];
                document.getElementById('logContainer').innerHTML = 
                    '<div class="empty-state">Logs cleared</div>';
                location.reload();
            }
        }
        
        function downloadLogs() {
            fetch('/api/logs')
                .then(r => r.json())
                .then(logs => {
                    const text = logs.map(l => `[${l.timestamp}] ${l.message}`).join('\\n');
                    const blob = new Blob([text], { type: 'text/plain' });
                    const url = window.URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = `ml-debug-${new Date().getTime()}.log`;
                    a.click();
                });
        }
        
        // Initial load and auto-refresh
        refreshLogs();
        setInterval(refreshLogs, 500);
    </script>
</body>
</html>
"""

def start_debug_server(port=8080):
    """Start the debug server."""
    # Redirect stdout to our logger
    sys.stdout = debug_logger
    
    server_address = ('', port)
    httpd = HTTPServer(server_address, DebugRequestHandler)
    
    print(f"\n{'='*70}")
    print(f"🧠 SpeakSteps ML Debug Server Started")
    print(f"{'='*70}")
    print(f"📊 Dashboard: http://localhost:{port}/debug")
    print(f"📡 API: http://localhost:{port}/api/logs")
    print(f"{'='*70}\n")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n\n⏹️  Server stopped")
        httpd.shutdown()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    start_debug_server(port)
