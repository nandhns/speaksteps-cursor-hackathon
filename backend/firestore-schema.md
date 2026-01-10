# SpeakSteps Firestore Schema

## Overview

```
firestore/
├── users/{userId}                        # Unified user collection (therapists & patients)
├── questions/{questionId}                # Exercise questions/items
├── exercise_sessions/{sessionId}         # Session-level aggregated data
├── question_responses/{responseId}       # Individual question responses
└── exercise_scores/{scoreId}             # Legacy score tracking

storage/
└── questions/{questionId}/{filename}.jpg
```

---

## Collections

### `/therapists/{therapistId}`

Therapist profiles. Document ID = Firebase Auth UID.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | ✅ | Full name |
| `email` | string | ✅ | Email address (from Auth) |
| `clinic` | string | ❌ | Clinic/organization name |
| `created_at` | timestamp | ✅ | Account creation time |

**Example:**
```json
{
  "name": "Dr. Jane Smith",
  "email": "jane.smith@clinic.com",
  "clinic": "Speech Therapy Center",
  "created_at": "2024-01-15T10:30:00Z"
}
```

---

### `/patients/{patientId}` (now unified with `/users/{userId}`)

Patient profiles linked to therapists. Patients are users with role='patient'.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Patient UID (same as Auth UID) |
| `name` | string | ✅ | Full name |
| `email` | string | ✅ | Email address (from Auth) |
| `role` | string | ✅ | Always "patient" for patients |
| `diagnosis` | string | ❌ | Type of aphasia or condition |
| `patientPhone` | string | ❌ | Patient's phone number |
| `caregiverName` | string | ❌ | Primary caregiver's name |
| `caregiverPhone` | string | ❌ | Caregiver's phone number |
| `therapistId` | string | ✅ | Therapist UID (foreign key) |
| `assignedModules` | array | ❌ | Therapy modules assigned (e.g., ["writing", "comprehension"]) |
| `onboardingEmailSent` | boolean | ❌ | Whether onboarding email was sent |
| `preferredLanguage` | string | ❌ | Language preference ('en' or 'ms') |
| `created_at` | timestamp | ✅ | Registration time |

**Example:**
```json
{
  "id": "patient_xyz789",
  "name": "John Doe",
  "email": "john.doe@email.com",
  "role": "patient",
  "diagnosis": "Broca's Aphasia",
  "patientPhone": "+60123456789",
  "caregiverName": "Jane Doe",
  "caregiverPhone": "+60123456788",
  "therapistId": "therapist_uid_123",
  "assignedModules": ["writing", "comprehension"],
  "onboardingEmailSent": true,
  "preferredLanguage": "en",
  "created_at": "2024-01-20T14:00:00Z"
}
```

---

### `/questions/{questionId}`

Therapy exercise questions/items.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `module` | string | ✅ | `"writing"` or `"comprehension"` |
| `category` | string | ✅ | `"animals"`, `"body_parts"`, `"clothing"`, `"food"` |
| `item` | string | ✅ | Target word (e.g., "dog", "hand") |
| `difficulty_label` | string | ✅ | `"easy"` or `"hard"` |
| `image_path` | string | ❌ | Storage path: `questions/{id}/item.jpg` |
| `image_url` | string | ❌ | Public download URL |
| `created_by` | string | ✅ | Creator's UID or `"admin"` |
| `tags` | array | ❌ | Optional tags for filtering |
| `created_at` | timestamp | ✅ | Creation time |

**Example:**
```json
{
  "module": "writing",
  "category": "animals",
  "item": "dog",
  "difficulty_label": "easy",
  "image_path": "questions/q_abc123/dog.jpg",
  "image_url": "https://storage.googleapis.com/...",
  "created_by": "therapist_uid_123",
  "tags": ["common", "pet", "4-letter"],
  "created_at": "2024-01-10T09:00:00Z"
}
```

---

### `/exercise_sessions/{sessionId}`

Comprehensive therapy session records with aggregated metrics.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Session document ID |
| `patientId` | string | ✅ | Patient UID |
| `therapistId` | string | ✅ | Therapist UID |
| `exerciseId` | string | ✅ | Exercise identifier |
| `exerciseTitle` | string | ✅ | Exercise name |
| `module` | string | ✅ | Module type (writing/comprehension) |
| `category` | string | ✅ | Exercise category |
| `startTime` | timestamp | ✅ | Session start |
| `endTime` | timestamp | ❌ | Session end (null if active) |
| `totalTimeSeconds` | number | ✅ | Total time spent |
| `activeTimeSeconds` | number | ✅ | Active working time |
| `totalQuestions` | number | ✅ | Number of questions |
| `correctAnswers` | number | ✅ | Correct answer count |
| `incorrectAnswers` | number | ✅ | Incorrect answer count |
| `questionsSkipped` | number | ❌ | Skipped question count |
| `accuracyPercentage` | number | ✅ | Accuracy % |
| `totalCuesGiven` | number | ✅ | Total cues provided |
| `questionsWithCues` | number | ✅ | Questions that needed cues |
| `cueTypeCount` | map | ✅ | Count per cue type |
| `deviceType` | string | ❌ | Device used (web/android/ios) |
| `metadata` | map | ❌ | Additional data (ML model used, etc.) |

**Example:**
```json
{
  "id": "session_xyz789",
  "patientId": "patient_xyz789",
  "therapistId": "therapist_uid_123",
  "exerciseId": "ex_writing_animals_001",
  "exerciseTitle": "Animal Naming - Easy",
  "module": "writing",
  "category": "animals",
  "startTime": "2024-02-01T10:00:00Z",
  "endTime": "2024-02-01T10:30:00Z",
  "totalTimeSeconds": 1800,
  "activeTimeSeconds": 1650,
  "totalQuestions": 10,
  "correctAnswers": 7,
  "incorrectAnswers": 3,
  "questionsSkipped": 0,
  "accuracyPercentage": 70.0,
  "totalCuesGiven": 5,
  "questionsWithCues": 3,
  "cueTypeCount": {
    "functional": 3,
    "rhyming": 2
  },
  "deviceType": "web",
  "metadata": {
    "mlModelUsed": true,
    "exerciseDifficulty": 2
  }
}
```

---

### `/question_responses/{responseId}`

Individual question responses with detailed timing and cue data (replaces trials subcollection).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Response document ID |
| `sessionId` | string | ✅ | Links to exercise_sessions |
| `patientId` | string | ✅ | Patient UID |
| `therapistId` | string | ✅ | Therapist UID (for filtering) |
| `exerciseId` | string | ✅ | Exercise/question bank ID |
| `questionIndex` | number | ✅ | Question order in exercise |
| `questionText` | string | ✅ | The question asked |
| `questionImageUrl` | string | ❌ | Image URL if applicable |
| `userAnswer` | string | ❌ | User's response |
| `correctAnswer` | string | ✅ | Correct answer |
| `isCorrect` | boolean | ✅ | Answer correctness |
| `presentedAt` | timestamp | ✅ | When question was shown |
| `respondedAt` | timestamp | ❌ | When user submitted answer |
| `responseTimeSeconds` | number | ✅ | Total time to respond |
| `cueGiven` | boolean | ✅ | Whether a cue was provided |
| `cueType` | string | ❌ | Type of cue given |
| `cueStage` | number | ✅ | Cue hierarchy stage (0-7) |
| `cueWaitSeconds` | number | ❌ | Time before first cue shown |
| `timeAfterCueDisplayed` | number | ❌ | Time from cue display to answer |
| `hintCount` | number | ✅ | Number of cues/hints shown |
| `difficulty` | string | ❌ | Question difficulty level |
| `category` | string | ❌ | Question category |
| `module` | string | ❌ | Module type (writing/comprehension) |
| `attemptNumber` | number | ❌ | Retry attempt number |
| `metadata` | map | ❌ | Additional custom data |

**Cue Types:**
- `functional` - Describes function/use
- `rhyming` - Rhyming word hint
- `sentence_completion` - Word in context
- `written_initial` - First letter(s)
- `spelling` - Spelling breakdown
- `phonemic` - Sound/phoneme cue
- `modeling` - Full model answer

**Example:**
```json
{
  "id": "resp_abc123",
  "sessionId": "session_xyz789",
  "patientId": "patient_xyz789",
  "therapistId": "therapist_uid_123",
  "exerciseId": "ex_writing_animals_001",
  "questionIndex": 3,
  "questionText": "What is this animal?",
  "questionImageUrl": "https://...",
  "userAnswer": "dag",
  "correctAnswer": "dog",
  "isCorrect": false,
  "presentedAt": "2024-02-01T10:05:00Z",
  "respondedAt": "2024-02-01T10:05:30Z",
  "responseTimeSeconds": 30,
  "cueGiven": true,
  "cueType": "functional",
  "cueStage": 1,
  "cueWaitSeconds": 15,
  "timeAfterCueDisplayed": 15,
  "hintCount": 1,
  "difficulty": "easy",
  "category": "animals",
  "module": "writing",
  "attemptNumber": 1,
  "metadata": {}
}
```

---

## Storage Structure

```
storage/
└── questions/
    └── {questionId}/
        └── {item}.jpg      # Main question image
```

### Image Requirements

- **Format:** JPEG, PNG, WebP
- **Max Size:** 5 MB
- **Recommended:** 512x512 px or larger
- **Naming:** `{item}.jpg` (e.g., `dog.jpg`)

---

## Indexes

### Required Composite Indexes

```
Collection: questions
Fields: module (ASC), category (ASC), created_at (DESC)

Collection: exercise_sessions
Fields: patientId (ASC), startTime (DESC)
Fields: therapistId (ASC), startTime (DESC)

Collection: question_responses
Fields: patientId (ASC), presentedAt (DESC)
Fields: sessionId (ASC), questionIndex (ASC)
Fields: therapistId (ASC), presentedAt (DESC)

Collection: users
Fields: role (ASC), therapistId (ASC), createdAt (DESC)
```

---

## Security Summary

| Collection | Read | Create | Update | Delete |
|------------|------|--------|--------|--------|
| users | Self, Assigned Therapist, Admin | Therapist (for patients), Self | Self, Assigned Therapist | Admin |
| questions | Authenticated | Therapist, Admin | Creator, Admin | Admin |
| exercise_sessions | Patient (self), Therapist (their patients), Admin | Patient | Patient, Therapist | Admin |
| question_responses | Patient (self), Therapist (their patients), Admin | Patient | ❌ | Admin |
| exercise_scores | Patient (self), Therapist (their patients), Admin | Patient | ❌ | Admin |

---

## Data Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│  Therapist   │────▶│   Patient    │────▶│ Exercise Session │
│  (creates)   │     │  (assigned)  │     │  (aggregated)    │
└──────────────┘     └──────────────┘     └─────────┬────────┘
                                                     │
┌──────────────┐                                    ▼
│  Questions   │◀──────────────────────┌────────────────────┐
│   (items)    │                       │ Question Responses │
└──────────────┘                       │  (detailed data)   │
                                       └────────────────────┘

Features Tracked:
• Response times (total, before cue, after cue)
• Cue usage (type, stage, count)
• Timing metrics (question-level and session-level)
• Accuracy and performance metrics
• Device and context information
```

