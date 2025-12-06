# SpeakSteps - Broca's Aphasia Therapy App

## Project Structure
speaksteps/
├── backend/ # Python ML pipeline & Firebase config
├── frontend/ # Flutter mobile app
├── docs/ # Documentation & protocols
├── images/ # Generated placeholder images
└── speaksteps_ml_notebook.ipynb # ML training notebook


## Setup Instructions

### Prerequisites
- Python 3.9+
- Flutter 3.x
- Android Studio (for testing)

### Backend (ML Pipeline)
cd backend
pip install pandas numpy scikit-learn tensorflow pillow
python generate_synth_dataset.py### Frontend (Flutter App)
cd frontend
flutter pub get
flutter run -d <android-device>⚠️ **Note:** The app uses TFLite which does NOT work on web. 
Run on Android/iOS/Desktop only.

### Testing on Android
1. Open `frontend/` in Android Studio
2. Start an Android emulator
3. Run the app

## Key Files
- `backend/cueing_engine.py` - Hybrid rule+ML cueing logic
- `frontend/lib/services/cue_predictor.dart` - TFLite inference
- `speaksteps_ml_notebook.ipynb` - Full ML pipeline

Frontend (Flutter App)
cd frontend
flutter pub get
flutter run -re/ml-pipeline

# Add files (gitignore will filter)
git add .

# Check what will be committed
git status

# Commit
git commit -m "Add ML pipeline, Flutter TFLite integration, cueing engine"

# Push
git push -u origin feature/ml-pipeline
⚠️ Note: The app uses TFLite which does NOT work on web.
Run on Android/iOS/Desktop only.

Testing on Android
1. Open frontend/ in Android Studio
2. Start an Android emulator
3. Run the app

Key Files
backend/cueing_engine.py - Hybrid rule+ML cueing logic
frontend/lib/services/cue_predictor.dart - TFLite inference
speaksteps_ml_notebook.ipynb - Full ML pipeline