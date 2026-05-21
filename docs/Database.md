# CobraSthenics — Firestore Database Schema

**Version:** 2.0.0  
**Date:** 2026-05-16  
**Author:** Data Architecture Team  
**Status:** Approved

---

## Table of Contents

1. [Schema Overview](#1-schema-overview)
2. [Collection Architecture](#2-collection-architecture)
3. [Global Collections](#3-global-collections)
4. [User Subcollections](#4-user-subcollections)
5. [Example Documents](#5-example-documents)
6. [Indexing Strategy](#6-indexing-strategy)
7. [Security Rules](#7-security-rules)
8. [Data Growth Considerations](#8-data-growth-considerations)
9. [Migration Strategy](#9-migration-strategy)

---

## 1. Schema Overview

### 1.1 Design Principles

Firestore is a document-oriented NoSQL database. The schema below is optimized around four rules:

- **Query-first design** — every collection shape is derived from a specific UI query, not from relational normalization
- **Denormalization over joins** — critical fields (exercise names, skill names) are copied into child documents to avoid multi-document reads at render time
- **Subcollection over arrays** — arrays are used only for small, bounded, write-infrequent data (≤ 20 items); unbounded data always lives in subcollections
- **Aggregation caching** — computed totals (weekly volume per muscle group, skill PR) are pre-written by Cloud Functions to avoid expensive client-side fan-out reads

### 1.2 Top-Level Collection Map

```
Firestore Root
│
├── users/                          ← User profiles + all user-owned data
│   └── {uid}/
│       ├── [document]              ← Profile document
│       ├── workouts/               ← Workout sessions
│       ├── skillLogs/              ← Skill timed-hold sessions
│       ├── programEnrollments/     ← User-enrolled or user-created programs
│       ├── weightLogs/             ← Body weight entries
│       ├── measurementLogs/        ← Body measurement entries
│       ├── progressPhotos/         ← Photo metadata (storage URL)
│       ├── personalRecords/        ← Best performance per exercise (Cloud Fn)
│       ├── customExercises/        ← User-created exercises
│       └── notificationPrefs/      ← Single-document notification config
│
├── exercises/                      ← Global calisthenics exercise library (read-only for users)
│
├── globalPrograms/                 ← Curated CobraSthenics programs (read-only for users)
│
└── appConfig/                      ← Admin-controlled app-wide configuration
```

### 1.3 Read/Write Pattern Summary

| Collection | Read Frequency | Write Frequency | Strategy |
|---|---|---|---|
| `users/{uid}` | High (every session) | Low (profile edits) | Single doc, cache locally |
| `workouts/` | High (history, dashboard) | High (during workout) | Isar-first, async sync |
| `skillLogs/` | Medium (skill detail, analytics) | Medium (skill sessions) | Isar-first, async sync |
| `exercises/` | High (search) | Very Low (admin only) | Fully cached in Isar on install |
| `personalRecords/` | Medium (analytics, PR board) | Low (Cloud Fn on PR) | One doc per exercise |
| `progressPhotos/` | Low | Low | Metadata only; binary in Storage |

---

## 2. Collection Architecture

### 2.1 Naming Conventions

| Rule | Example |
|---|---|
| Collections: camelCase, plural | `workouts`, `skillLogs` |
| Documents: auto-generated IDs | `Xk3mN8pQrL2vT9wB` |
| Date-keyed documents: ISO 8601 | `2026-05-16` |
| Exercise IDs: stable slugs | `pull-up`, `tuck-planche`, `muscle-up` |
| Timestamp fields: Firestore `Timestamp` | `startedAt`, `createdAt` |
| Soft delete: `isDeleted: true` | Never hard-delete user data |

### 2.2 Document Size Budget

Firestore's hard limit is **1 MB per document**. Budget targets:

| Document Type | Target Size | Hard Limit |
|---|---|---|
| User profile | < 4 KB | 10 KB |
| Workout session | < 20 KB | 100 KB |
| Skill log | < 3 KB | 10 KB |
| Exercise definition | < 10 KB | 20 KB |
| Progress photo metadata | < 1 KB | 2 KB |

> **Workout size control:** A set log is ~200 bytes. A workout with 6 exercises × 5 sets = 30 sets ≈ 6 KB. Workouts with circuits or >10 exercises are split into a `workoutSets/` subcollection (see §8.1).

---

## 3. Global Collections

### 3.1 `exercises/` — Global Calisthenics Exercise Library

**Path:** `/exercises/{exerciseId}`  
**Document ID:** URL-safe slug (e.g., `pull-up`, `tuck-front-lever`, `handstand-push-up`)  
**Written by:** Admin SDK / Cloud Functions only  
**Read by:** All authenticated users

```
exercises/{exerciseId}
├── id: string                      // Same as document ID
├── name: string                    // "Tuck Front Lever"
├── aliases: string[]               // ["Tuck Lever", "Front Lever Tuck Hold"]
├── category: string                // "push" | "pull" | "core" | "legs" | "full_body"
│                                   //   | "mobility" | "handstand"
├── mechanics: string               // "compound" | "isolation"
├── force: string                   // "push" | "pull" | "static_hold" | "hinge"
├── laterality: string              // "bilateral" | "unilateral" | "n/a"
├── primaryMuscles: string[]        // ["lats", "core", "biceps"]
├── secondaryMuscles: string[]      // ["rhomboids", "rear_deltoids"]
├── equipment: string               // "bodyweight" | "pull_up_bar" | "parallel_bars"
│                                   //   | "gymnastic_rings" | "resistance_bands" | "none"
├── difficulty: string              // "beginner" | "intermediate" | "advanced" | "elite"
├── defaultSetType: string          // "reps" | "timed" | "amrap" | "reps_or_timed"
├── isSkillExercise: boolean        // true for timed hold / static skill exercises
├── progressionChain: {             // Skill tree navigation
│     previousId: string | null,   // e.g., "dead-hang"
│     nextId: string | null        // e.g., "advanced-tuck-front-lever"
│   }
├── skillCategory: string | null    // "front_lever" | "planche" | "handstand" | etc.
├── instructions: string[]          // Ordered array of instruction steps
├── tips: string                    // Optional coaching cue
├── muscleMapFront: string[]        // SVG region keys for front-body illustration
├── muscleMapBack: string[]         // SVG region keys for back-body illustration
├── isPremium: boolean              // Gates video; free users get text instructions only
├── videoStoragePath: string        // "exercises/videos/tuck-front-lever.mp4" (nullable)
├── thumbnailStoragePath: string    // "exercises/thumbs/tuck-front-lever.jpg" (nullable)
├── searchTokens: string[]          // Lowercased name + alias tokens for client-side search
├── schemaVersion: number
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

### 3.2 `globalPrograms/` — Curated Training Programs

**Path:** `/globalPrograms/{programId}`  
**Document ID:** URL-safe slug (e.g., `beginner-calisthenics-8week`, `handstand-mastery-12week`)  
**Written by:** Admin only  
**Read by:** All authenticated users

```
globalPrograms/{programId}
├── id: string
├── name: string                    // "Beginner Calisthenics — 8 Weeks"
├── slug: string                    // URL-safe, stable identifier
├── description: string
├── authorName: string              // "CobraSthenics Team" or guest coach name
├── coverImagePath: string          // Firebase Storage path
├── durationWeeks: number           // Total program length
├── daysPerWeek: number
├── estimatedMinutesPerSession: number
├── difficulty: string              // "beginner" | "intermediate" | "advanced"
├── targetGoal: string[]            // ["strength", "skill", "hypertrophy", "fat_loss"]
├── targetSkills: string[]          // e.g., ["muscle_up", "handstand", "front_lever"]
├── requiredEquipment: string[]     // ["bodyweight", "pull_up_bar"]
├── isPremium: boolean
├── totalEnrollments: number        // Denormalized counter (Cloud Fn increments)
├── averageRating: number           // 0–5.0 (Cloud Fn aggregates)
├── weeks: ProgramWeek[]            // Embedded; bounded array (max 16 weeks × 7 days)
│
│   ProgramWeek {
│     weekNumber: number            // 1-indexed
│     isDeload: boolean
│     days: ProgramDay[]
│   }
│
│   ProgramDay {
│     dayNumber: number             // 1–7 (Mon–Sun)
│     isRestDay: boolean
│     workoutName: string | null
│     exercises: ProgramExercise[]
│   }
│
│   ProgramExercise {
│     exerciseId: string
│     exerciseName: string          // Denormalized
│     orderIndex: number
│     targetSets: number
│     targetReps: string | null     // "8-12" | "AMRAP" | null (for timed exercises)
│     targetDurationSeconds: number | null  // For timed hold exercises
│     restSeconds: number
│     supersetGroupId: string | null
│     difficultyVariants: {         // Multiple intensity options per day
│       light:    { targetReps: string | null, targetDurationSeconds: number | null },
│       standard: { targetReps: string | null, targetDurationSeconds: number | null },
│       intense:  { targetReps: string | null, targetDurationSeconds: number | null }
│     }
│   }
│
├── schemaVersion: number
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

### 3.3 `appConfig/` — Application Configuration

**Path:** `/appConfig/{configId}`  
**Written by:** Admin SDK  
**Read by:** All authenticated users

```
appConfig/main
├── exerciseSchemaVersion: number   // Triggers cache refresh in clients
├── minimumAppVersion: string       // Force-update enforcement
├── maintenanceMode: boolean
└── updatedAt: Timestamp
```

---

## 4. User Subcollections

### 4.1 User Profile Document

**Path:** `/users/{uid}`

```
users/{uid}
├── uid: string
├── email: string
├── displayName: string
├── avatarStoragePath: string | null
├── createdAt: Timestamp
├── updatedAt: Timestamp
├── goal: string                    // "build_strength" | "learn_skills" | "lose_fat" | "general"
├── fitnessLevel: string            // "beginner" | "intermediate" | "advanced"
├── equipment: string[]             // ["bodyweight", "pull_up_bar", "parallel_bars", "rings", "bands"]
├── dob: string                     // ISO date "1998-03-15"
├── heightCm: number
├── weightKg: number
├── bodyFatPercent: number | null
├── unitSystem: string              // "metric" | "imperial"
├── skillAssessment: {              // Self-reported baseline from onboarding
│     push_ups: string,            // "0" | "1-5" | "6-15" | "15+"
│     pull_ups: string,            // "0" | "1-3" | "4-10" | "10+"
│     dips: string,
│     handstand: string,           // "none" | "wall_supported" | "freestanding"
│     muscle_up: string            // "none" | "kipping" | "strict"
│   }
├── subscriptionStatus: string      // "free" | "trial" | "premium" | "lapsed"
├── subscriptionExpiry: Timestamp | null
├── revenueCatUserId: string | null
└── schemaVersion: number
```

### 4.2 `workouts/` — Workout Sessions

**Path:** `/users/{uid}/workouts/{workoutId}`

```
workouts/{workoutId}
├── id: string
├── name: string                    // "Morning Push Day" or auto-generated from program
├── startedAt: Timestamp
├── completedAt: Timestamp | null
├── durationSeconds: number
├── notes: string | null
├── programId: string | null        // Reference to globalPrograms or user custom program
├── programDayId: string | null
├── muscleGroupVolume: {            // Total reps (or estimated hold-equivalent) per muscle
│     chest: number,
│     back: number,
│     shoulders: number,
│     biceps: number,
│     triceps: number,
│     core: number,
│     legs: number,
│     // ...
│   }
├── exerciseLogs: ExerciseLog[]     // Embedded array (promoted to subcollection if > 80 KB)
├── usesSetsSubcollection: boolean  // true if exerciseLogs was promoted (see §8.1)
├── isDeleted: boolean
└── schemaVersion: number
```

**ExerciseLog (embedded in `workouts/{workoutId}.exerciseLogs[]`)**

```
{
  exerciseId: string,
  exerciseName: string,             // Denormalized
  orderIndex: number,
  supersetGroupId: string | null,
  notes: string | null,
  sets: SetLog[]
}
```

**SetLog (embedded in ExerciseLog.sets[])**

```
{
  setIndex: number,
  setType: string,                  // "normal" | "warmup" | "dropset" | "amrap" | "failure"
  reps: number | null,              // For rep-based sets
  durationSeconds: number | null,   // For timed hold sets
  addedWeightKg: number | null,     // Positive = added weight, negative = assisted
  isBodyweight: boolean,
  isCompleted: boolean,
  rpe: number | null,               // 1.0–10.0
  completedAt: Timestamp | null
}
```

### 4.3 `skillLogs/` — Skill Timed-Hold Sessions

**Path:** `/users/{uid}/skillLogs/{skillLogId}`

This collection captures dedicated skill training sessions (e.g., handstand practice, front lever holds) separately from regular workouts to power the Skill Analytics feature cleanly.

```
skillLogs/{skillLogId}
├── id: string
├── skillId: string                 // exerciseId where isSkillExercise = true
├── skillName: string               // Denormalized (e.g., "Tuck Front Lever")
├── skillCategory: string           // "front_lever" | "planche" | "handstand" | etc.
├── sessionDate: string             // ISO date "2026-05-16"
├── sets: SkillSet[]
│   SkillSet {
│     setIndex: number,
│     holdSeconds: number,
│     completedAt: Timestamp | null
│   }
├── bestHoldSeconds: number         // Max hold from this session (for quick analytics reads)
├── notes: string | null
├── createdAt: Timestamp
└── isDeleted: boolean
```

### 4.4 `programEnrollments/` — Program Enrollment State

**Path:** `/users/{uid}/programEnrollments/{enrollmentId}`

```
programEnrollments/{enrollmentId}
├── id: string
├── programId: string               // References globalPrograms/{programId}
├── programName: string             // Denormalized
├── enrolledAt: Timestamp
├── startDate: string               // ISO date
├── currentWeek: number             // 1-indexed
├── currentDay: number              // 1–7
├── completedSessionIds: string[]   // workoutId values for completed sessions
├── adherencePercent: number        // 0–100; Cloud Fn recomputes on each session completion
├── isActive: boolean
├── completedAt: Timestamp | null
└── schemaVersion: number
```

### 4.5 `personalRecords/` — Best Performance Per Exercise

**Path:** `/users/{uid}/personalRecords/{exerciseId}`  
**Written by:** Cloud Function `onWorkoutComplete` and `onSkillLogSave` only  
**Read by:** Client (analytics, exercise detail, PRs board)

```
personalRecords/{exerciseId}
├── exerciseId: string
├── exerciseName: string            // Denormalized
├── bestReps: number | null         // Best single-set rep count
├── bestRepsDate: Timestamp | null
├── bestHoldSeconds: number | null  // Best timed hold in seconds
├── bestHoldDate: Timestamp | null
├── bestAddedWeightKg: number | null  // Best added weight (at any rep count)
├── bestWeightDate: Timestamp | null
├── updatedAt: Timestamp
└── schemaVersion: number
```

### 4.6 `weightLogs/` — Body Weight Log

**Path:** `/users/{uid}/weightLogs/{logId}`

```
weightLogs/{logId}
├── weightKg: number
├── date: string                    // ISO date "2026-05-16"
├── notes: string | null
└── createdAt: Timestamp
```

### 4.7 `measurementLogs/` — Body Measurements

**Path:** `/users/{uid}/measurementLogs/{logId}`

```
measurementLogs/{logId}
├── date: string                    // ISO date
├── neckCm: number | null
├── shouldersCm: number | null
├── chestCm: number | null
├── waistCm: number | null
├── hipsCm: number | null
├── leftBicepCm: number | null
├── rightBicepCm: number | null
├── leftThighCm: number | null
├── rightThighCm: number | null
├── leftCalfCm: number | null
├── rightCalfCm: number | null
├── bodyFatPercent: number | null
└── createdAt: Timestamp
```

### 4.8 `progressPhotos/` — Progress Photo Metadata

**Path:** `/users/{uid}/progressPhotos/{photoId}`

```
progressPhotos/{photoId}
├── storagePath: string             // e.g., "users/{uid}/photos/photo_abc.jpg"
├── thumbnailPath: string           // e.g., "users/{uid}/photos/thumbs/photo_abc.jpg"
├── poseCategory: string            // "front" | "back" | "side_left" | "side_right" | "custom"
├── takenAt: Timestamp
├── bodyWeightKg: number | null     // Auto-populated from latest weightLogs entry
└── createdAt: Timestamp
```

### 4.9 `customExercises/` — User-Created Exercises

**Path:** `/users/{uid}/customExercises/{exerciseId}`

```
customExercises/{exerciseId}
├── id: string
├── name: string
├── category: string
├── primaryMuscles: string[]
├── secondaryMuscles: string[]
├── equipment: string
├── defaultSetType: string
├── isSkillExercise: boolean
├── instructions: string[]
├── notes: string | null
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

### 4.10 `notificationPrefs/` — Notification Configuration

**Path:** `/users/{uid}/notificationPrefs/config` (single document)

```
notificationPrefs/config
├── workoutReminder: {
│     enabled: boolean,
│     time: string,                 // "HH:MM" (24h)
│     days: number[]               // [1,2,3,4,5] (Mon–Fri)
│   }
├── programAdherenceNudge: {
│     enabled: boolean
│   }
├── prCelebration: {
│     enabled: boolean
│   }
├── weeklySummary: {
│     enabled: boolean
│   }
├── quietHoursStart: string         // "22:00"
├── quietHoursEnd: string           // "07:00"
├── fcmToken: string | null
└── updatedAt: Timestamp
```

---

## 5. Example Documents

### 5.1 Example: Completed Workout Document

```json
{
  "id": "wk_8xN2pQrL",
  "name": "Pull Day — Week 3 Day 2",
  "startedAt": "2026-05-16T08:00:00Z",
  "completedAt": "2026-05-16T08:52:00Z",
  "durationSeconds": 3120,
  "notes": "Felt strong today. Pull-ups felt light.",
  "programId": "beginner-calisthenics-8week",
  "programDayId": "w3d2",
  "muscleGroupVolume": {
    "back": 48,
    "biceps": 30,
    "core": 20,
    "shoulders": 12
  },
  "exerciseLogs": [
    {
      "exerciseId": "pull-up",
      "exerciseName": "Pull-Up",
      "orderIndex": 0,
      "supersetGroupId": null,
      "notes": null,
      "sets": [
        { "setIndex": 0, "setType": "warmup", "reps": 5, "durationSeconds": null, "addedWeightKg": null, "isBodyweight": true, "isCompleted": true, "rpe": 4, "completedAt": "2026-05-16T08:03:00Z" },
        { "setIndex": 1, "setType": "normal", "reps": 10, "durationSeconds": null, "addedWeightKg": null, "isBodyweight": true, "isCompleted": true, "rpe": 7, "completedAt": "2026-05-16T08:05:30Z" },
        { "setIndex": 2, "setType": "normal", "reps": 9, "durationSeconds": null, "addedWeightKg": null, "isBodyweight": true, "isCompleted": true, "rpe": 8, "completedAt": "2026-05-16T08:08:00Z" },
        { "setIndex": 3, "setType": "normal", "reps": 8, "durationSeconds": null, "addedWeightKg": null, "isBodyweight": true, "isCompleted": true, "rpe": 9, "completedAt": "2026-05-16T08:11:00Z" }
      ]
    },
    {
      "exerciseId": "tuck-front-lever",
      "exerciseName": "Tuck Front Lever",
      "orderIndex": 1,
      "supersetGroupId": null,
      "notes": "Getting closer to 10s per set",
      "sets": [
        { "setIndex": 0, "setType": "normal", "reps": null, "durationSeconds": 8, "addedWeightKg": null, "isBodyweight": true, "isCompleted": true, "rpe": 7, "completedAt": "2026-05-16T08:20:00Z" },
        { "setIndex": 1, "setType": "normal", "reps": null, "durationSeconds": 7, "addedWeightKg": null, "isBodyweight": true, "isCompleted": true, "rpe": 8, "completedAt": "2026-05-16T08:23:00Z" },
        { "setIndex": 2, "setType": "normal", "reps": null, "durationSeconds": 6, "addedWeightKg": null, "isBodyweight": true, "isCompleted": true, "rpe": 9, "completedAt": "2026-05-16T08:26:00Z" }
      ]
    }
  ],
  "usesSetsSubcollection": false,
  "isDeleted": false,
  "schemaVersion": 1
}
```

### 5.2 Example: Skill Log Document

```json
{
  "id": "sk_Lm3Rp9wX",
  "skillId": "freestanding-handstand",
  "skillName": "Freestanding Handstand",
  "skillCategory": "handstand",
  "sessionDate": "2026-05-16",
  "sets": [
    { "setIndex": 0, "holdSeconds": 6, "completedAt": "2026-05-16T09:10:00Z" },
    { "setIndex": 1, "holdSeconds": 9, "completedAt": "2026-05-16T09:13:00Z" },
    { "setIndex": 2, "holdSeconds": 7, "completedAt": "2026-05-16T09:16:00Z" },
    { "setIndex": 3, "holdSeconds": 11, "completedAt": "2026-05-16T09:19:00Z" }
  ],
  "bestHoldSeconds": 11,
  "notes": "Slight improvement. Focus on shoulder stacking.",
  "createdAt": "2026-05-16T09:20:00Z",
  "isDeleted": false
}
```

### 5.3 Example: Personal Record Document

```json
{
  "exerciseId": "pull-up",
  "exerciseName": "Pull-Up",
  "bestReps": 15,
  "bestRepsDate": "2026-04-28T07:55:00Z",
  "bestHoldSeconds": null,
  "bestHoldDate": null,
  "bestAddedWeightKg": 10.0,
  "bestWeightDate": "2026-05-10T08:20:00Z",
  "updatedAt": "2026-05-10T08:20:00Z",
  "schemaVersion": 1
}
```

---

## 6. Indexing Strategy

### 6.1 Required Composite Indexes

```
Collection: users/{uid}/workouts
  Index 1: (uid ASC, completedAt DESC)          — Workout history list, paginated
  Index 2: (uid ASC, isDeleted ASC, completedAt DESC)  — Filtered history (excludes deleted)

Collection: users/{uid}/skillLogs
  Index 1: (skillId ASC, sessionDate DESC)      — Skill trend chart
  Index 2: (skillCategory ASC, sessionDate DESC) — Category-level analytics

Collection: users/{uid}/weightLogs
  Index 1: (date DESC)                          — Weight chart, paginated

Collection: exercises (global)
  Index 1: (category ASC, difficulty ASC)       — Filtered exercise browse
  Index 2: (equipment ASC, difficulty ASC)      — Equipment-filtered browse
  Index 3: (isSkillExercise ASC, skillCategory ASC)  — Skill tree browse

Collection: globalPrograms (global)
  Index 1: (difficulty ASC, isPremium ASC)      — Program browser filter
  Index 2: (targetGoal ARRAY_CONTAINS, difficulty ASC)  — Goal-filtered programs
```

### 6.2 Single-Field Index Overrides

Fields excluded from auto-indexing to reduce costs:

```
exercises: instructions (array — never queried by content)
exercises: searchTokens (array — queried only for exact token match)
workouts: exerciseLogs (array — never queried by sub-field server-side; always local Isar)
```

---

## 7. Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ─── Global Collections (read-only for authenticated users) ───────────────

    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }

    match /globalPrograms/{programId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }

    match /appConfig/{configId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }

    // ─── User Collections (owner-only) ────────────────────────────────────────

    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;

      match /workouts/{workoutId} {
        allow read, write: if request.auth.uid == uid;
        allow delete: if false; // Soft-delete only via isDeleted field
      }

      match /skillLogs/{skillLogId} {
        allow read, write: if request.auth.uid == uid;
      }

      match /programEnrollments/{enrollmentId} {
        allow read, write: if request.auth.uid == uid;
      }

      match /personalRecords/{exerciseId} {
        allow read: if request.auth.uid == uid;
        allow write: if false; // Cloud Function writes only
      }

      match /weightLogs/{logId} {
        allow read, write: if request.auth.uid == uid;
      }

      match /measurementLogs/{logId} {
        allow read, write: if request.auth.uid == uid;
      }

      match /progressPhotos/{photoId} {
        allow read, write: if request.auth.uid == uid;
      }

      match /customExercises/{exerciseId} {
        allow read, write: if request.auth.uid == uid;
      }

      match /notificationPrefs/{docId} {
        allow read, write: if request.auth.uid == uid;
      }
    }
  }
}
```

---

## 8. Data Growth Considerations

### 8.1 Workout Document Size Guard

A set log is ~200 bytes. A typical workout with 6 exercises × 5 sets = 30 sets ≈ 6 KB. This is well within limits. However, high-volume sessions with circuits, 10+ exercises, or very detailed notes can approach the soft limit.

**Strategy: Automatic Subcollection Promotion**

When a workout document exceeds 80 KB, a Cloud Function migrates `exerciseLogs` to a `sets/` subcollection:

```
BEFORE (monolithic):
  workouts/{id}
  └── exerciseLogs: [ ... 15 exercises × 8 sets ... ]   ~95 KB ❌

AFTER (promoted):
  workouts/{id}
  ├── exerciseLogs: []              // cleared
  ├── usesSetsSubcollection: true
  └── sets/                        // Subcollection
      ├── {exerciseId_0_set_0}: SetLog
      ├── {exerciseId_0_set_1}: SetLog
      └── ...
```

The client checks `usesSetsSubcollection` and fetches accordingly. Transparent to the UI.

### 8.2 Workout Volume Estimates

A user training 5 days/week:

| Time Period | Workouts | Est. Total Size |
|---|---|---|
| 1 month | ~22 | ~132 KB |
| 6 months | ~130 | ~780 KB |
| 1 year | ~260 | ~1.6 MB |
| 3 years | ~780 | ~4.7 MB |

Skill logs are smaller (~2 KB each). At 3 skill sessions/week over 1 year: ~300 KB additional.

### 8.3 Progress Photo Storage

10 photos/month at 3 MB average = 30 MB/month. Premium unlimited users could generate 360 MB/year.

Strategies:
1. **Client-side compression:** Flutter compresses to 1920×1080 max, JPEG quality 80 (≈ 600 KB) before upload.
2. **Thumbnail generation:** Cloud Function generates 200×200 thumbnail (≈ 15 KB) on upload for gallery views.
3. **Storage caps:** Free tier: 10 photos (enforced in Firestore rules and Cloud Function count check).
4. **Storage class tiering:** Photos older than 180 days moved to Nearline via lifecycle policy.

### 8.4 Firestore Read Optimization

| Pattern | Problem | Solution |
|---|---|---|
| Dashboard on app open | Multiple document reads (weight, program, streak, top muscles) | Bundle into `dashboardSummary/{date}` doc written by Cloud Fn nightly |
| Skill trend chart | Many skillLog reads for a date range | Single range query on `sessionDate`; Isar cache for recent 90 days |
| Exercise search | Full collection scan on text fields | Pre-load 400+ exercises to Isar on install; search is local |
| PR board | One read per exercise (30+ exercises) | `personalRecords` collection group is a single query |
| Active workout | Polling for timer sync | Stream the single active workout document; no polling |

### 8.5 Cost Optimization Rules

| Rule | Implementation |
|---|---|
| Cache exercises aggressively | Firestore persistence enabled; `source: cache` preferred for exercise reads |
| Batch PR writes | Single Cloud Function batches all PR updates from one workout into one batch write |
| Disable unused indexes | `fieldOverrides` in `firestore.indexes.json` removes indexes on embedded arrays |
| Limit listen scope | Streams only on active workout; history uses one-time `get()` |
| Compress payloads | `exerciseLogs` array avoids separate collection overhead for typical workouts |

---

## 9. Migration Strategy

### 9.1 Schema Versioning

Every document includes `schemaVersion: number`. Cloud Functions detect outdated documents on read and migrate them transparently:

```javascript
// Example: migrating workouts from schema v1 to v2
async function migrateWorkoutIfNeeded(doc) {
  if (doc.schemaVersion >= 2) return doc;

  // v1 → v2: add muscleGroupVolume map (was missing in v1)
  const migrated = {
    ...doc,
    muscleGroupVolume: computeMuscleGroupVolume(doc.exerciseLogs),
    schemaVersion: 2,
  };

  await db.doc(`users/${doc.userId}/workouts/${doc.id}`)
    .update({ muscleGroupVolume: migrated.muscleGroupVolume, schemaVersion: 2 });

  return migrated;
}
```

### 9.2 Additive-Only Field Policy

New fields are always **additive** — existing documents are never broken by new code. Clients handle missing optional fields with null-safe access. Removing a field requires a two-release deprecation cycle:

- **Release N:** Mark field deprecated in schema docs; new code stops writing it
- **Release N+1:** New code stops reading it; Cloud Function batch-deletes it from existing docs

### 9.3 GDPR Data Deletion

On account deletion, a Cloud Function performs a complete cascade delete:

```javascript
export const deleteUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth || context.auth.uid !== data.uid) throw new Error('Unauthorized');

  const uid = data.uid;

  // Delete all subcollection documents via recursive delete
  await db.recursiveDelete(db.collection(`users/${uid}`));
  await db.doc(`users/${uid}`).delete();

  // Delete Firebase Storage files (progress photos, avatars)
  await storage.bucket().deleteFiles({ prefix: `users/${uid}/` });

  // Revoke Firebase Auth
  await admin.auth().deleteUser(uid);
});
```

---

## Appendix A — Collection Reference Card

| Collection Path | Documents | Written by | Max Doc Size |
|---|---|---|---|
| `/users/{uid}` | Profile | Client | 10 KB |
| `/users/{uid}/workouts/` | Sessions | Client (Isar → sync) | 100 KB |
| `/users/{uid}/skillLogs/` | Skill sessions | Client (Isar → sync) | 10 KB |
| `/users/{uid}/programEnrollments/` | Enrollments | Client | 50 KB |
| `/users/{uid}/weightLogs/` | Weight entries | Client | 1 KB |
| `/users/{uid}/measurementLogs/` | Body measurements | Client | 2 KB |
| `/users/{uid}/progressPhotos/` | Photo metadata | Client | 2 KB |
| `/users/{uid}/personalRecords/` | PR per exercise | Cloud Fn only | 2 KB |
| `/users/{uid}/customExercises/` | User exercises | Client | 10 KB |
| `/users/{uid}/notificationPrefs/` | Single config doc | Client | 2 KB |
| `/exercises/` | Exercise library | Admin only | 20 KB |
| `/globalPrograms/` | Curated programs | Admin only | 500 KB |
| `/appConfig/` | Global config | Admin only | 5 KB |

---

*Document maintained by the CobraSthenics Data Architecture Team. Schema changes require a PR with updated `schemaVersion`, migration plan, and index diff.*
