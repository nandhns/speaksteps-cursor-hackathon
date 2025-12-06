# SpeakSteps Firestore Schema

## Overview

```
firestore/
├── therapists/{therapistId}
├── patients/{patientId}
├── questions/{questionId}
└── sessions/{sessionId}
    └── trials/{trialId}

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

### `/patients/{patientId}`

Patient profiles linked to therapists.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | ❌ | Real name (optional for privacy) |
| `alias` | string | ✅ | Display name/identifier |
| `assigned_therapist` | string | ✅ | Therapist UID (foreign key) |
| `created_at` | timestamp | ✅ | Registration time |

**Example:**
```json
{
  "name": "John Doe",
  "alias": "Patient A",
  "assigned_therapist": "therapist_uid_123",
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

### `/sessions/{sessionId}`

Therapy session records.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `patient_id` | string | ✅ | Patient document ID |
| `therapist_id` | string | ✅ | Therapist UID |
| `start_time` | timestamp | ✅ | Session start |
| `end_time` | timestamp | ❌ | Session end (null if active) |
| `device_type` | string | ✅ | `"mobile"` or `"web"` |
| `trial_count` | number | ❌ | Number of trials (denormalized) |

**Example:**
```json
{
  "patient_id": "patient_xyz789",
  "therapist_id": "therapist_uid_123",
  "start_time": "2024-02-01T10:00:00Z",
  "end_time": "2024-02-01T10:30:00Z",
  "device_type": "mobile",
  "trial_count": 25
}
```

---

### `/sessions/{sessionId}/trials/{trialId}`

Individual question attempts within a session.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `question_id` | string | ✅ | Question document ID |
| `response_time_seconds` | number | ✅ | Time to respond |
| `correct` | boolean | ✅ | Answer correctness |
| `cue_given` | boolean | ❌ | Whether a cue was provided |
| `cue_type` | string | ❌ | Cue type if given |
| `cue_stage` | number | ❌ | Cue hierarchy stage (0-7) |
| `user_answer` | string | ❌ | User's response |
| `timestamp` | timestamp | ✅ | Trial time |

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
  "question_id": "q_abc123",
  "response_time_seconds": 15.5,
  "correct": false,
  "cue_given": true,
  "cue_type": "phonemic",
  "cue_stage": 3,
  "user_answer": "dag",
  "timestamp": "2024-02-01T10:05:30Z"
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

Collection: sessions
Fields: patient_id (ASC), start_time (DESC)

Collection: sessions/{sessionId}/trials
Fields: timestamp (ASC)
```

---

## Security Summary

| Collection | Read | Create | Update | Delete |
|------------|------|--------|--------|--------|
| therapists | Self, Admin | Self | Self (no email) | Admin |
| patients | Therapist, Self, Admin | Therapist | Therapist | Therapist, Admin |
| questions | Authenticated | Therapist, Admin | Creator, Admin | Admin |
| sessions | Therapist, Patient, Admin | Therapist, Patient | Therapist, Patient | Admin |
| trials | Therapist, Patient, Admin | Authenticated | ❌ | Admin |

---

## Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Therapist  │────▶│   Patient   │────▶│   Session   │
│  (creates)  │     │ (assigned)  │     │  (therapy)  │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
┌─────────────┐                                ▼
│  Questions  │◀───────────────────────┌─────────────┐
│   (items)   │                        │   Trials    │
└─────────────┘                        │ (attempts)  │
                                       └─────────────┘
```

