# SpeakSteps - PlantUML Diagrams Guide

All diagrams have been generated and are ready to view with your PlantUML VS Code extension!

## 📊 Generated Diagrams

### 1. **Use Case Diagram** (`01_usecase_diagram.puml`)
Shows all user interactions and system functions:
- **Patient interactions**: Sign in, complete exercises, receive cues, view progress
- **Therapist interactions**: Create patients, assign modules, monitor progress
- **System functions**: Cue prediction, performance calculation, speech processing
- **Relationships**: How use cases interact (e.g., completing exercise triggers adaptive cues)

**Key Actors:**
- Patient
- Therapist  
- System (ML & Rules Engine)

---

### 2. **Conceptual Architecture Diagram** (`02_architecture_diagram.puml`)
Hierarchical view of system components:
- **Frontend Layer**: Flutter app across platforms (mobile, web, desktop)
- **Network Layer**: REST API gateway
- **Cloud Layer**: Firebase services (Auth, Firestore, Functions, Storage)
- **Backend Services**: Cueing engine + ML service with TFLite model
- **Data Layer**: Databases and models
- **External Services**: Speech-to-text, text-to-speech, email

**Key Flows:**
- Frontend → API → Backend Services → Database
- Rules Engine & ML work in parallel for cue decisions
- External services for speech and notifications

---

### 3. **Deployment Diagram** (`03_deployment_diagram.puml`)
Physical/logical deployment structure:
- **Client Tier**: Web, mobile, desktop apps
- **Cloud Platform**: Firebase (managed services)
- **Backend Tier**: Python servers running cueing engine & ML
- **External Services**: Google Cloud APIs, SendGrid

**Deployment Notes:**
- All clients authenticate via Firebase
- Backend communicates with Firestore for data
- External APIs called for speech/email operations

---

### 4. **Entity-Relationship Diagram (ERD)** (`04_erd_diagram.puml`)
Database schema with 11 entities:

**Core Entities:**
- `User` - Authentication & base user info
- `Patient` - Patient-specific data
- `Therapist` - Therapist credentials

**Therapy Entities:**
- `TherapyModule` - Breathing, Writing, Comprehension modules
- `Exercise` - Individual exercises within modules
- `PatientModuleAssignment` - Track module assignments to patients

**Performance Entities:**
- `ExerciseScore` - Scores from completed exercises
- `ExerciseSession` - Session tracking (start/end time, questions count)
- `QuestionResponse` - Individual question responses with timings
- `CueDecision` - Cue given for each response
- `PatientProgress` - Overall progress summary

**Relationships:**
- User (1) → Many Patients/Therapists
- Patient (1) → Many Scores/Sessions/Responses
- Exercise (1) → Many Scores/Sessions
- TherapyModule (1) → Many Exercises

---

### 5. **Sequence Diagram** (`05_sequence_diagram.puml`)
Detailed flow of patient completing an exercise:

**Steps:**
1. Patient signs in
2. Selects exercise
3. Attempts question (voice/text)
4. System evaluates:
   - Gets performance history
   - Runs ML predictor (19 features)
   - Combines with rule-based logic
5. Decides: cue type/stage or no cue
6. Saves response & decision
7. Returns feedback to patient
8. Repeats for next question
9. Session ends with performance summary

**Key Timing Point:** Cue decision happens in near real-time using ML + rules

---

### 6. **Class Diagram** (`06_class_diagram.puml`)
Code-level architecture with 20+ classes:

**Models Package:**
- `User`, `Patient`, `Therapist` (entity models)
- `TherapyModule`, `Exercise` (content models)
- `ExerciseScore`, `PatientProgress` (metrics)
- `UserRole` enum

**Services Package:**
- `AuthProvider` - ChangeNotifier for authentication state
- `LanguageProvider` - ChangeNotifier for language switching
- `AppService` interface with:
  - `FirebaseService` implementation
  - `MockService` implementation (for testing)

**Backend Package:**
- `CueingEngine` - Rule-based cue decisions
- `PerformanceCalculator` - Performance level logic
- `MLPredictor` - TFLite model wrapper
- `FeatureExtractor` - ML feature preparation

**Key Design Patterns:**
- Provider pattern (authentication, language)
- Factory pattern (AppService implementations)
- State management with ChangeNotifier

---

## 🎯 How to View Diagrams

### Option 1: VS Code with PlantUML Extension
1. Open any `.puml` file in VS Code
2. Right-click → "PlantUML: Preview"
3. Or press `Alt+D` (with PlantUML extension)

### Option 2: Online Viewer
Copy content from any file to: https://www.plantuml.com/plantuml/uml/

### Option 3: Export
In VS Code preview → Right-click → Export as PNG/SVG

---

## 📋 Diagram Relationships

```
Use Cases (What?)
     ↓
Architecture (How? - Components)
     ↓
Deployment (Where? - Physical)
     ↓
ERD (What data? - Database)
     ↓
Sequence (When/How? - Interactions)
     ↓
Class (Implementation - Code)
```

---

## 🔍 Key Architecture Decisions Reflected in Diagrams

1. **Hybrid Cueing**: Rules-based + ML-based (visible in sequence & class diagrams)
2. **Multi-platform**: Flutter for all platforms (architecture diagram)
3. **Cloud-first**: Firebase for all backend services (deployment)
4. **Adaptive therapy**: Performance tracking feeds into cue decisions (sequence & ERD)
5. **Speech integration**: External APIs for speech input/output (architecture)
6. **Separation of concerns**: Services layer abstracts Firebase (class diagram)

---

## 🚀 Next Steps

- Use these diagrams in documentation
- Share with team for architecture review
- Keep updated as system evolves
- Generate PNG exports for presentations

All diagrams automatically render with your PlantUML extension!
