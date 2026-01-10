# Firebase Deployment Instructions

## Problem: "Could not load the default credentials"

This happens because Firebase Admin SDK needs authentication credentials.

## Solution: Use Web-Based Seeding (Easiest)

### Option 1: Use seed_firestore_web.html (Recommended)

1. Open `seed_firestore_web.html` in a web browser
2. It will authenticate using your Firebase web credentials
3. Click the "Seed Database" button
4. Done! ✅

### Option 2: Get Service Account Key (For Node.js)

If you want to use `seed_firestore.js`:

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: `speaksteps-cursor`
3. Click the gear icon ⚙️ → Project Settings
4. Go to "Service Accounts" tab
5. Click "Generate New Private Key"
6. Download the JSON file
7. Save it as `serviceAccountKey.json` in the `backend` folder
8. Run: `node seed_firestore.js`

**IMPORTANT:** Add `serviceAccountKey.json` to `.gitignore` (never commit it!)

### Option 3: Set Environment Variable

1. Download service account key (steps above)
2. Set environment variable:

**Windows PowerShell:**
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccountKey.json"
node seed_firestore.js
```

**Windows CMD:**
```cmd
set GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\serviceAccountKey.json
node seed_firestore.js
```

**Linux/Mac:**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
node seed_firestore.js
```

## Quick Start (Recommended)

Just open `seed_firestore_web.html` in your browser - it's the easiest way!



