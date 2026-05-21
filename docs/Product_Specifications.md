# CobraSthenics — Product Requirements Document

**Version:** 2.0.0  
**Date:** 2026-05-16  
**Status:** Draft  
**Owner:** Product Team  
**Platform:** Cross-platform mobile (iOS & Android) — Flutter + Firebase

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Target Users](#2-target-users)
3. [Feature List](#3-feature-list)
4. [User Flows](#4-user-flows)
5. [Screen List](#5-screen-list)
6. [Core Data Entities](#6-core-data-entities)
7. [Technical Requirements](#7-technical-requirements)

---

## 1. Product Overview

### 1.1 Vision

CobraSthenics is a dedicated calisthenics training companion that unifies workout tracking, skill progression, training programs, and body progress analytics into a single, seamless experience. Built on Flutter and Firebase, it delivers a native-quality UI on both iOS and Android from a single codebase.

### 1.2 Mission Statement

To empower every individual — from first pull-up to human flag — with the tools to plan smarter, train with intention, and measure their transformation through the art of bodyweight movement, all within one beautifully designed app.

### 1.3 Problem Statement

Calisthenics athletes today either use generic gym-lifting apps (which treat bodyweight as an afterthought) or cobble together notes apps and YouTube videos to track their skill progression. Neither approach handles the nuances of calisthenics: timed holds, bodyweight progressions, skill trees (e.g., tuck planche → advanced tuck → straddle → full planche), and the mix of rep-based and time-based sets that define the discipline. CobraSthenics is purpose-built for calisthenics from the ground up — making it the Heria Pro-style experience for the broader bodyweight community.

### 1.4 Success Metrics

| Metric | Target (12 months post-launch) |
|---|---|
| Monthly Active Users (MAU) | 200,000 |
| Day-7 Retention | ≥ 40% |
| Day-30 Retention | ≥ 22% |
| Free-to-Premium Conversion | ≥ 8% |
| Average Session Length | ≥ 6 minutes |
| App Store Rating | ≥ 4.5 stars |
| Crash-free Sessions | ≥ 99.5% |

### 1.5 Scope

**In Scope (v1.0):** Onboarding, profile management, workout tracking, calisthenics exercise database, skill progression system, training programs, body metrics, progress photos, analytics dashboard, push notifications, subscription/paywall system.

**Out of Scope (v1.0):** GPS activity tracking (running/cycling), nutrition/calorie tracking, social/community feed, wearable device sync (v1.1), AI-generated coaching (v1.2), coach/trainer portal (v2.0).

---

## 2. Target Users

### 2.1 Primary Personas

#### Persona A — "The Aspiring Calisthenics Athlete" (Alex, 24)
- Trains 4–5 days/week; wants to learn muscle-ups and handstands
- Needs clear skill progression paths with structured prerequisites
- Tracks reps, sets, and hold times; interested in strength-to-skill milestones
- Pain point: Gym apps don't understand calisthenics progressions — they just ask for weight
- Device: iPhone 15, iOS 17

#### Persona B — "The Freestyle Street Workout Enthusiast" (Jordan, 29)
- Trains outdoors at a park or at home; no gym equipment beyond a pull-up bar
- Wants curated programs requiring minimal equipment
- Motivated by unlocking new skills and logging personal records (e.g., max hold time)
- Pain point: Most fitness apps assume gym access or don't track time-based exercises properly
- Device: Samsung Galaxy S23, Android 14

#### Persona C — "The Fitness Beginner" (Sam, 20)
- Starting their fitness journey; needs guided beginner programs
- Wants to go from zero pull-ups to 10 clean pull-ups
- Highly motivated by visual progress, streaks, and guided instruction
- Pain point: Overwhelmed by advanced movements; needs beginner-friendly progressions with clear next steps
- Device: iPhone 14, iOS 16

#### Persona D — "The Advanced Practitioner" (Morgan, 35)
- Proficient in pull-ups, dips, and handstand push-ups; chasing planche and front lever
- Needs detailed analytics: volume per muscle group, skill hold-time trends, weekly training load
- Uses premium features; expects advanced metrics and custom program building
- Pain point: No app tracks skill milestones and training load together at an advanced level
- Device: Pixel 8 Pro, Android 14

### 2.2 Secondary Personas

- Weightlifters adding bodyweight training to complement their lifting
- Personal trainers building calisthenics programs for clients (v2.0 coach portal)
- Casual users who want quick, structured bodyweight home workouts

### 2.3 User Jobs-to-Be-Done

- "When I finish a set of pull-ups, I want to log my reps instantly so I don't lose track mid-workout."
- "When I'm working on my handstand, I want to track my hold time each session and see my progression over time."
- "When I start a workout, I want the app to tell me exactly what to do today based on my program."
- "When I review my week, I want to see which muscle groups I trained and how my skills are improving."
- "When I feel unmotivated, I want to see how far I've come since day one."

---

## 3. Feature List

### 3.1 User Onboarding & Profile (Free)

- **F-01** Splash screen with animated brand logo
- **F-02** Social sign-in (Google, Apple) and email/password registration via Firebase Auth
- **F-03** Guided onboarding wizard: goal selection (build strength / learn skills / lose fat / general fitness), current fitness level, primary training location, available equipment (bodyweight only / pull-up bar / parallel bars / gymnastic rings / resistance bands)
- **F-04** Biometric intake: DOB, height, current body weight, unit preference (metric/imperial)
- **F-05** Skill assessment: self-reported ability for key benchmark movements (push-ups, pull-ups, dips, handstand, muscle-up) to calibrate recommended programs and starting progressions
- **F-06** Profile avatar (camera capture or gallery upload, stored in Firebase Storage)
- **F-07** Account settings: email, password change, notification preferences
- **F-08** Privacy settings: data export (JSON), account deletion (GDPR/CCPA compliant)

### 3.2 Workout Tracking (Free + Premium)

- **F-09** Quick-start blank workout or start from a saved program
- **F-10** Exercise search and add with muscle group and equipment filter
- **F-11** Set logging with multiple set types:
  - **Rep-based:** reps per set (e.g., 3×10 pull-ups)
  - **Timed hold:** duration in seconds (e.g., 3×30s L-sit hold)
  - **AMRAP:** as many reps as possible per set
  - **Weighted bodyweight:** bodyweight + added weight (e.g., +10kg dips)
  - **Assisted:** bodyweight with band or spotter assistance (negative value, e.g., -20kg for assisted pull-ups)
- **F-12** Previous performance displayed inline ("Last time: 3×12 | Best hold: 45s")
- **F-13** Rest timer with configurable duration per exercise; auto-starts after set completion; background audio ticks (optional)
- **F-14** Workout notes field (per workout and per exercise)
- **F-15** Superset and circuit grouping of exercises (Premium)
- **F-16** RPE (Rate of Perceived Exertion) field per set (Premium)
- **F-17** Workout summary screen: sets completed, muscles trained, PRs achieved, total duration
- **F-18** Workout history list with search and filter by date/muscle group/exercise
- **F-19** Edit completed workouts (up to 24 hours post-completion)

### 3.3 Calisthenics Exercise Database (Free + Premium)

- **F-20** Built-in library of 400+ calisthenics exercises with: name, primary muscles, secondary muscles, equipment required, movement pattern, difficulty level, and progression tier
- **F-21** Exercise detail page with written step-by-step instructions, coaching cues, and muscle diagram illustration
- **F-22** Skill progression chain shown per exercise — displays the prerequisite movement and the next progression target (e.g., Tuck Planche → Advanced Tuck Planche → Straddle Planche)
- **F-23** Exercise filter: muscle group, equipment, category (push / pull / core / legs / full-body / mobility), difficulty
- **F-24** Custom exercise creation (name, muscles, type, notes) — synced to user's Firestore
- **F-25** Video demonstrations for all exercises (Firebase Storage hosted MP4s, Premium)
- **F-26** Personal records (PR) tracker per exercise: best reps, best hold time, best added weight; shown on exercise detail page

### 3.4 Skill Progression System (Free + Premium)

- **F-27** Skill tree browser: visual hierarchy of calisthenics skill progressions grouped by category (Pushing Skills, Pulling Skills, Core Skills, Leg Skills, Handstand Skills)
- **F-28** Individual skill profiles for major calisthenics milestones: Muscle-Up, Handstand, Planche, Front Lever, Back Lever, Human Flag, L-Sit, Pistol Squat, Handstand Push-Up, One-Arm Pull-Up, and more
- **F-29** Skill goal setting: user selects target skills and the app maps the prerequisite progression chain to follow
- **F-30** Skill session logging: dedicated timed-hold session mode with countdown and auto-logged duration — built for handstands, L-sits, planches, and levers
- **F-31** Hold time trend chart per skill: shows progress across sessions (e.g., L-sit hold: 5s → 12s → 22s over 8 weeks)
- **F-32** Skill unlock milestones: in-app achievement when a user hits a qualifying benchmark (e.g., 10-second freestanding handstand, first clean muscle-up)
- **F-33** Skill analytics board: all tracked skills in one view with current best, last logged, and trend direction (Premium)

### 3.5 Training Programs (Free + Premium)

- **F-34** Program browser: featured programs curated by CobraSthenics — filterable by level, goal, duration, and equipment requirement
- **F-35** Program detail: name, duration (weeks), days/week, description, difficulty, required equipment, target skills
- **F-36** Enroll in a program; active program shown on dashboard with today's session CTA
- **F-37** Program scheduler: assigns workouts to specific weekdays; rest day handling
- **F-38** Custom program builder (Premium): create multi-week training blocks, assign exercises per day, configure rep/hold targets and progression rules
- **F-39** Program progress tracker: completed sessions vs. planned, adherence percentage, weekly heatmap
- **F-40** Program duplication and template sharing (Premium)
- **F-41** Deload week configuration per program (Premium)
- **F-42** Multiple daily difficulty levels: for each program workout day, user can choose their intensity level (light / standard / intense) — inspired by Heria Pro

### 3.6 Body Metrics Tracking (Free + Premium)

- **F-43** Body weight log with trend line (rolling 7-day average)
- **F-44** Body measurement log: neck, shoulders, chest, waist, hips, left/right bicep, left/right thigh, left/right calf
- **F-45** Body fat % estimation: manual entry or Navy method calculator (from measurements)
- **F-46** FFMI (Fat-Free Mass Index) auto-calculation — particularly relevant for natural calisthenics athletes monitoring lean mass
- **F-47** Metric history charts: configurable date range (1W / 1M / 3M / 6M / 1Y / All)
- **F-48** Goal body weight marker on weight chart with ETA calculation (Premium)
- **F-49** Unit switching (kg ↔ lb, cm ↔ in) globally applied retroactively

### 3.7 Progress Photos (Free + Premium)

- **F-50** Photo capture or import from gallery with pose category tag (front, back, side left, side right, custom)
- **F-51** Photos stored securely in Firebase Storage, keyed to user UID; not publicly accessible
- **F-52** Timeline gallery: chronological grid view per pose category
- **F-53** Side-by-side comparison view: pick any two photos from the same pose category with swipe overlay
- **F-54** Body weight overlaid as metadata on each photo card
- **F-55** Photo count cap: 10 photos free; unlimited with Premium
- **F-56** Export progress photos as a shareable collage (Premium)

### 3.8 Analytics Dashboard (Free + Premium)

- **F-57** Home dashboard widgets: today's workout card, active program day, streak badge, weekly training heatmap, top muscles trained this week
- **F-58** Weekly summary card: workouts completed, total training time, top exercises logged, muscle group breakdown
- **F-59** Strength & volume analytics: reps/sets volume trend per exercise, training load per muscle group per week (Premium)
- **F-60** Skill analytics: hold-time trend per skill, skill milestone timeline (Premium)
- **F-61** Body composition chart: weight + body fat % dual-axis chart over time (Premium)
- **F-62** Workout consistency calendar (GitHub-style heatmap): 52-week view
- **F-63** Personal records board: all-time PRs per exercise (best reps, best hold, best weighted) with date achieved
- **F-64** Streak tracking: current and longest workout streak
- **F-65** Top muscles trained chart: ranked bar chart of most-trained muscle groups over selected period (week/month/all)
- **F-66** Top exercises chart: most frequently performed exercises over selected period

### 3.9 Push Notifications (Free + Premium)

- **F-67** Firebase Cloud Messaging (FCM) integration for all notification types
- **F-68** Workout reminder: scheduled daily or on specific days with customizable time and message
- **F-69** Rest timer completion: local notification when background rest timer expires
- **F-70** Program adherence nudge: if user hasn't logged a workout on a scheduled program day by 8 PM
- **F-71** Weekly progress summary push: Sunday evening summary of the week's training stats
- **F-72** PR / skill milestone celebration notification: triggered immediately after a new PR or skill unlock
- **F-73** Notification preference center: granular on/off per notification type, quiet hours setting

### 3.10 Subscription System (Freemium)

- **F-74** Free tier: access to core workout logging, 400+ exercise library, 3 programs, 10 progress photos, basic analytics
- **F-75** CobraSthenics Premium: monthly and annual billing options; 7-day free trial on first subscription
- **F-76** In-app purchase via `purchases_flutter` (RevenueCat SDK) for both iOS App Store and Google Play Billing
- **F-77** Paywall screen with feature comparison table; shown contextually when a Premium feature is tapped
- **F-78** Subscription management: view plan, next billing date, cancel, restore purchases
- **F-79** Grace period handling: 3-day lapsed grace before feature gating on failed renewal
- **F-80** Promotional offer codes (RevenueCat promotional entitlements)

---

## 4. User Flows

### 4.1 New User Onboarding Flow

```
App Launch (first install)
    │
    ▼
Splash / Brand Animation (2s)
    │
    ▼
Welcome Screen
    ├─► [Create Account] ──► Registration (email/password or Google/Apple)
    │                            │
    └─► [Log In] ────────────────┤
                                 ▼
                        Onboarding Wizard
                        Step 1: Primary Goal
                        Step 2: Fitness Level
                        Step 3: Available Equipment
                        Step 4: Skill Assessment (push-ups, pull-ups, etc.)
                        Step 5: Body Metrics (height, weight, DOB)
                        Step 6: Weekly Availability (days/week)
                        Step 7: Unit Preference
                             │
                             ▼
                        Suggested Program Shown (matched to level + equipment)
                        [Skip] or [Enroll in Program]
                             │
                             ▼
                        Home Dashboard (Main App)
```

### 4.2 Workout Logging Flow

```
Home Dashboard
    │
    ▼
[Start Workout] button
    │
    ├─► [Start Blank Workout]
    │       │
    │       ▼
    │   Active Workout Screen
    │   [+ Add Exercise] ──► Exercise Search/Filter ──► Select Exercise
    │                                                       │
    │                                                       ▼
    │                                               Exercise added to workout
    │                                               Set row appears (Set 1)
    │                                               Select set type (reps / timed / AMRAP)
    │                                               Enter reps or duration
    │                                               [✓ Complete Set]
    │                                                   │
    │                                               Rest Timer starts
    │                                               (local notification if backgrounded)
    │                                                   │
    │                                               Add more sets or exercises
    │                                                   │
    │                                               [Finish Workout]
    │                                                   │
    │                                               Workout Summary Screen
    │                                               (muscles trained, duration, PRs)
    │                                                   │
    │                                               [Save] ──► Logged to Firestore
    │
    └─► [Continue Program Day X]
            │
            ▼
        Pre-populated workout from program template
        (same flow as blank workout from here)
```

### 4.3 Skill Training Flow

```
Skills Tab ──► [View Skill Tree] or [My Skills]
    │
    ▼
Select Target Skill (e.g., Front Lever)
    │
    ▼
Skill Detail Screen
    • Current progression milestone shown
    • Prerequisite exercises listed
    • Hold-time trend chart
    │
[Train This Skill] ──► Timed Hold Session Screen
    │
    ▼
Countdown / Active Hold Timer
    • Start hold ──► Running timer
    • [Stop] ──► Log hold duration
    • Rest ──► Repeat for target sets
    │
    ▼
Session Summary (sets logged, best hold, PR if achieved)
    │
[Save] ──► Written to Firestore; chart updated
```

### 4.4 Subscription Upgrade Flow

```
User taps Premium-gated feature
    │
    ▼
Paywall Screen
    • Feature comparison (Free vs Premium)
    • Pricing cards (Monthly / Annual — annual highlighted as "Best Value")
    • 7-day free trial callout
    │
[Start Free Trial] or [Subscribe Monthly/Annually]
    │
    ▼
Native OS Payment Sheet (App Store / Google Play)
    │
    ├─► Payment success ──► RevenueCat webhook ──► Firebase entitlement update
    │                           │
    │                       User returned to feature (now unlocked)
    │
    └─► Payment failed / cancelled ──► Return to Paywall with error handling
```

### 4.5 Progress Photo Comparison Flow

```
Progress Tab ──► Photos Section
    │
    ▼
Photo Gallery (grid, filtered by pose category)
    │
[+ Add Photo] ──► Camera / Gallery ──► Pose tag ──► Confirm ──► Upload to Firebase Storage
    │
[Compare] button (2-photo select mode)
    │
    ▼
Select Photo A (baseline date)
Select Photo B (comparison date)
    │
    ▼
Side-by-Side Comparison Screen
    • Swipe overlay between A and B
    • Date + body weight shown per photo
    • Share / Export (Premium)
```

---

## 5. Screen List

### 5.1 Authentication Screens

| ID | Screen | Description |
|---|---|---|
| S-01 | Splash | Animated brand logo; routes to onboarding or home |
| S-02 | Welcome | CTA buttons: Create Account, Log In; social auth options |
| S-03 | Registration | Email, password, confirm password; or OAuth |
| S-04 | Login | Email/password + forgot password; social auth |
| S-05 | Forgot Password | Email input; Firebase send reset email |
| S-06 | Onboarding Wizard | Multi-step paged flow (7 steps, progress indicator) |

### 5.2 Main Navigation (Bottom Nav Bar)

| Tab | Icon | Label |
|---|---|---|
| T-01 | Home | Dashboard |
| T-02 | Workout | Log / Train |
| T-03 | Skills | Skill Tracker |
| T-04 | Programs | Browse / Active |
| T-05 | Progress | Analytics & Photos |

### 5.3 Dashboard Screens

| ID | Screen | Key Components |
|---|---|---|
| S-07 | Home Dashboard | Today's workout card, active program day CTA, streak badge, weekly heatmap, top muscles this week |
| S-08 | Weekly Summary | Workouts completed, training time, top exercises, muscle group breakdown chart |

### 5.4 Workout Screens

| ID | Screen | Key Components |
|---|---|---|
| S-09 | Workout Tab Home | Active program day CTA, recent workouts list, quick-start blank button |
| S-10 | Active Workout | Exercise list, set rows (reps/time/AMRAP input), rest timer overlay, elapsed time, finish button |
| S-11 | Exercise Search | Search bar, filter chips (muscle, equipment, category), exercise list tiles |
| S-12 | Exercise Detail | Muscle diagram, instructions, progression chain, PR stats, history chart, add to workout |
| S-13 | Workout Summary | Muscles trained heatmap, PRs list, duration, sets completed, save/discard |
| S-14 | Workout History | Filterable/searchable list of past sessions |
| S-15 | Workout Detail | Read-only view of a completed session; edit button (within 24h) |
| S-16 | Rest Timer (Overlay) | Full-screen countdown, skip button, next set preview |

### 5.5 Skills Screens

| ID | Screen | Key Components |
|---|---|---|
| S-17 | Skill Tree | Visual skill hierarchy grouped by category; tap a skill to view detail |
| S-18 | My Skills | List of user's tracked skills with current best and last trained date |
| S-19 | Skill Detail | Progression chain diagram, prerequisites, hold-time trend chart, train/log CTAs |
| S-20 | Timed Hold Session | Countdown timer, start/stop controls, per-set hold duration log, session summary |
| S-21 | Skill Milestones | Achievement badges for unlocked skill milestones with dates |

### 5.6 Program Screens

| ID | Screen | Key Components |
|---|---|---|
| S-22 | Program Browser | Featured, By Goal, By Equipment filter tabs; program cards with level + duration |
| S-23 | Program Detail | Overview, target skills, week schedule, difficulty level selector, enroll CTA |
| S-24 | Active Program | Current week/day, adherence ring, per-day schedule tiles, intensity selector |
| S-25 | Program Builder (Premium) | Week/day matrix, exercise assignment, hold/rep target config, progression rules |

### 5.7 Body Metrics Screens

| ID | Screen | Key Components |
|---|---|---|
| S-26 | Metrics Dashboard | Weight chart, body fat chart, measurement summary cards |
| S-27 | Log Weight | Weight input, date/time, notes |
| S-28 | Log Measurements | Measurement fields per body part, tape guide illustration |
| S-29 | Metrics History | Chart view with date range picker, table toggle |

### 5.8 Progress Photos Screens

| ID | Screen | Key Components |
|---|---|---|
| S-30 | Photos Tab | Pose category filter, chronological grid |
| S-31 | Add Photo | Camera/gallery source picker, pose tag selector, confirm |
| S-32 | Photo Detail | Full-screen photo, metadata overlay, delete |
| S-33 | Photo Comparison | Side-by-side / overlay swipe, date labels, share (Premium) |

### 5.9 Analytics Screens

| ID | Screen | Key Components |
|---|---|---|
| S-34 | Analytics Home | Section cards: Training Volume, Skill Progress, Body Composition |
| S-35 | Volume Analytics (Premium) | Rep/set volume trend per exercise, muscle group load chart |
| S-36 | Skill Analytics (Premium) | Hold-time trend per skill, milestone timeline |
| S-37 | Body Composition (Premium) | Dual-axis weight + body fat % chart |
| S-38 | Consistency Heatmap | 52-week workout calendar, streak stats |
| S-39 | PRs Board | All-time bests per exercise with date achieved |
| S-40 | Top Muscles Chart | Ranked bar chart of most-trained muscles over selected period |

### 5.10 Account & Settings Screens

| ID | Screen | Key Components |
|---|---|---|
| S-41 | Profile | Avatar, name, skill level, stats summary, edit button |
| S-42 | Edit Profile | Biometrics, goal, units, equipment, skill assessment |
| S-43 | Settings Home | Grouped settings sections list |
| S-44 | Notification Settings | Per-type toggles, time pickers, quiet hours |
| S-45 | Subscription | Current plan, billing date, manage/cancel, restore |
| S-46 | Paywall | Pricing cards, feature comparison, trial CTA |
| S-47 | Privacy & Data | Export data, delete account, third-party consents |
| S-48 | About | App version, OSS licenses, support link |

---

## 6. Core Data Entities

All entities are stored in Firestore unless noted. Timestamps use `Timestamp` (Firestore). User-scoped documents live under `/users/{uid}/`.

### 6.1 User

```
users/{uid}
├── uid: String
├── email: String
├── displayName: String
├── avatarUrl: String?              // Firebase Storage URL
├── createdAt: Timestamp
├── updatedAt: Timestamp
├── goal: Enum                      // build_strength | learn_skills | lose_fat | general
├── fitnessLevel: Enum              // beginner | intermediate | advanced
├── equipment: [String]             // bodyweight | pull_up_bar | parallel_bars | rings | bands
├── dob: Date
├── heightCm: Double
├── weightKg: Double
├── bodyFatPercent: Double?
├── unitSystem: Enum                // metric | imperial
├── skillAssessment: Map<String, String>  // e.g. { "pull_up": "10+", "handstand": "wall_supported" }
├── subscriptionStatus: Enum        // free | trial | premium | lapsed
├── subscriptionExpiry: Timestamp?
└── revenueCatUserId: String?
```

### 6.2 Exercise (Global Collection)

```
exercises/{exerciseId}
├── id: String
├── name: String
├── aliases: [String]
├── category: Enum                  // push | pull | core | legs | full_body | mobility | handstand
├── mechanics: Enum                 // compound | isolation
├── force: Enum                     // push | pull | static_hold | hinge | carry
├── primaryMuscles: [String]        // Standardized muscle name enum list
├── secondaryMuscles: [String]
├── equipment: String               // bodyweight | pull_up_bar | parallel_bars | rings | bands | none
├── difficulty: Enum                // beginner | intermediate | advanced | elite
├── defaultSetType: Enum            // reps | timed | amrap | reps_or_timed
├── progressionChain: Map           // { prev: "tuck_planche", next: "straddle_planche" }
├── isSkillExercise: Bool           // true for timed hold/skill exercises
├── instructions: [String]          // Ordered step array
├── tips: String?
├── isPremium: Bool                 // Gates video demonstration
├── videoStoragePath: String?       // Firebase Storage path (premium only)
├── thumbnailStoragePath: String?
├── muscleMapFront: [String]        // SVG region keys for front-body illustration
├── muscleMapBack: [String]         // SVG region keys for back-body illustration
├── searchTokens: [String]          // Lowercased name + alias tokens for client-side search
├── schemaVersion: number
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

### 6.3 Workout Session

```
users/{uid}/workouts/{workoutId}
├── id: String
├── name: String
├── startedAt: Timestamp
├── completedAt: Timestamp?
├── durationSeconds: Int
├── notes: String?
├── programId: String?              // Reference if from a program
├── programDayId: String?
├── muscleGroupVolume: Map<String, Int>  // e.g. { "chest": 24, "back": 30 } (total reps per muscle)
├── exerciseLogs: [ExerciseLog]     // Embedded array
└── isDeleted: Bool
```

**ExerciseLog (embedded in WorkoutSession)**

```
├── exerciseId: String
├── exerciseName: String            // Denormalized for offline/history display
├── orderIndex: Int
├── supersetGroupId: String?        // Links exercises in a superset
├── notes: String?
└── sets: [SetLog]
```

**SetLog (embedded in ExerciseLog)**

```
├── setIndex: Int
├── setType: Enum                   // normal | warmup | dropset | amrap | failure
├── reps: Int?                      // For rep-based sets
├── durationSeconds: Int?           // For timed hold sets
├── addedWeightKg: Double?          // For weighted bodyweight (positive = added, negative = assisted)
├── isBodyweight: Bool              // Always true for calisthenics; used for PR type detection
├── isCompleted: Bool
├── rpe: Double?                    // 1–10
└── completedAt: Timestamp?
```

### 6.4 Skill Log

```
users/{uid}/skillLogs/{skillLogId}
├── id: String
├── skillId: String                 // References exercises/{exerciseId} where isSkillExercise = true
├── skillName: String               // Denormalized
├── sessionDate: Date
├── sets: [SkillSet]
├── bestHoldSeconds: Int            // Max hold from this session
├── notes: String?
├── createdAt: Timestamp
└── isDeleted: Bool
```

**SkillSet (embedded in SkillLog)**

```
├── setIndex: Int
├── holdSeconds: Int
└── completedAt: Timestamp?
```

### 6.5 Training Program

```
programs/{programId}
├── id: String
├── name: String
├── description: String
├── authorName: String              // "CobraSthenics Team" or uid for custom
├── coverImagePath: String          // Firebase Storage path
├── durationWeeks: Int
├── daysPerWeek: Int
├── estimatedMinutesPerSession: Int
├── difficulty: Enum                // beginner | intermediate | advanced
├── targetGoal: [String]            // ["strength", "skill", "hypertrophy", "fat_loss"]
├── targetSkills: [String]          // e.g., ["muscle_up", "handstand"]
├── requiredEquipment: [String]     // ["bodyweight", "pull_up_bar"]
├── isPremium: Bool
├── totalEnrollments: Int           // Denormalized counter (Cloud Fn increments)
├── averageRating: Double           // 0–5.0 (Cloud Fn aggregates)
├── weeks: [ProgramWeek]            // Embedded; bounded array (max 16 weeks × 7 days)
│
│   ProgramWeek {
│     weekNumber: Int
│     isDeload: Bool
│     days: [ProgramDay]
│   }
│
│   ProgramDay {
│     dayNumber: Int                // 1–7 (maps to Mon–Sun)
│     isRestDay: Bool
│     workoutName: String?
│     exercises: [ProgramExercise]
│   }
│
│   ProgramExercise {
│     exerciseId: String
│     exerciseName: String          // Denormalized
│     orderIndex: Int
│     targetSets: Int
│     targetReps: String?           // "8-12" or "AMRAP" (null for timed exercises)
│     targetDurationSeconds: Int?   // For timed hold exercises (null for rep exercises)
│     restSeconds: Int
│     supersetGroupId: String?
│     difficultyVariants: Map       // { light: {...}, standard: {...}, intense: {...} }
│   }
│
├── schemaVersion: Int
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

### 6.6 User Program Enrollment

```
users/{uid}/programEnrollments/{enrollmentId}
├── programId: String
├── programName: String             // Denormalized
├── enrolledAt: Timestamp
├── startDate: Date
├── currentWeek: Int
├── currentDay: Int
├── completedSessionIds: [String]   // Workout IDs for completed sessions
├── adherencePercent: Double        // Cloud Fn computed
├── isActive: Bool
└── completedAt: Timestamp?
```

### 6.7 Personal Records

```
users/{uid}/personalRecords/{exerciseId}
├── exerciseId: String
├── exerciseName: String            // Denormalized
├── bestReps: Int?                  // Best single-set rep count
├── bestRepsDate: Timestamp?
├── bestHoldSeconds: Int?           // Best timed hold
├── bestHoldDate: Timestamp?
├── bestAddedWeightKg: Double?      // Best added weight at any rep count
├── bestWeightDate: Timestamp?
├── updatedAt: Timestamp
└── schemaVersion: Int
```

### 6.8 Weight Log

```
users/{uid}/weightLogs/{logId}
├── weightKg: Double
├── date: Date
├── notes: String?
└── createdAt: Timestamp
```

### 6.9 Measurement Log

```
users/{uid}/measurementLogs/{logId}
├── date: Date
├── neckCm: Double?
├── shouldersCm: Double?
├── chestCm: Double?
├── waistCm: Double?
├── hipsCm: Double?
├── leftBicepCm: Double?
├── rightBicepCm: Double?
├── leftThighCm: Double?
├── rightThighCm: Double?
├── leftCalfCm: Double?
├── rightCalfCm: Double?
├── bodyFatPercent: Double?
└── createdAt: Timestamp
```

### 6.10 Progress Photo

```
users/{uid}/progressPhotos/{photoId}
├── storagePath: String             // Firebase Storage path
├── thumbnailPath: String           // 200×200 thumbnail (Cloud Fn generated)
├── poseCategory: Enum              // front | back | side_left | side_right | custom
├── takenAt: Timestamp
├── bodyWeightKg: Double?           // Auto-populated from latest weight log
└── createdAt: Timestamp
```

---

## 7. Technical Requirements

### 7.1 Tech Stack

| Component | Technology |
|---|---|
| Frontend | Flutter 3.x (Dart 3.x) |
| State Management | Riverpod 2.x with code generation |
| Navigation | GoRouter 13.x |
| Local Storage | Isar 3.x (offline-first workout logging) |
| Auth | Firebase Authentication (Email/Password, Google, Apple) |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Remote Config | Firebase Remote Config |
| Analytics | Firebase Analytics |
| Crash Reporting | Firebase Crashlytics |
| Subscriptions | RevenueCat (`purchases_flutter`) |
| HTTP Client | Dio (for any future external APIs) |
| Codegen | `freezed` + `json_serializable` + `riverpod_generator` |

### 7.2 Third-Party Integrations

| Integration | Purpose | Auth Method |
|---|---|---|
| RevenueCat | Subscription management | SDK + server webhook secret |
| Firebase suite | Auth, DB, Storage, Analytics, FCM | Google service account |

> Note: GPS mapping (Google Maps), nutrition databases (Open Food Facts, FatSecret), and barcode scanning are explicitly out of scope for this calisthenics-focused app.

### 7.3 Firebase Architecture

```
Firebase Project: CobraSthenics-prod
├── Authentication
│   ├── Providers: Email/Password, Google OAuth, Apple Sign-In
│   └── Custom Claims: { admin: true } for content management
├── Firestore
│   ├── Rules: request.auth.uid == userId for all user documents
│   ├── Indexes: compound indexes on workoutId+date, exerciseId+uid, etc.
│   └── Collections: /users, /exercises (global), /globalPrograms (global)
├── Storage
│   ├── Rules: authenticated users can only read/write under /users/{uid}/
│   ├── Buckets: CobraSthenics-prod.appspot.com
│   └── Auto-resize function: Cloud Function triggers on photo upload → creates thumbnail
├── Cloud Functions
│   ├── onWorkoutComplete: update PRs, compute muscle group volume aggregates
│   ├── onSkillLogSave: update skill personal record (best hold time)
│   ├── onSubscriptionChange: sync RevenueCat webhooks → Firestore entitlement
│   ├── sendScheduledNotifications: cron job (Pub/Sub scheduler)
│   └── onPhotoUpload: generate 200×200 thumbnail
└── Remote Config
    ├── premium_features_list: [String]
    ├── free_photo_limit: Int (default: 10)
    ├── paywall_variant: Enum (A/B test)
    └── maintenance_mode: Bool
```

### 7.4 Security & Privacy

- **Firestore Security Rules:** All user documents gated by `request.auth.uid == userId`. Global collections (exercises, globalPrograms) are read-only for authenticated users. Write access to global collections requires custom claims (`admin: true`).
- **Firebase Storage Rules:** Users can only access files under `users/{uid}/`. Signed URLs expire in 1 hour for progress photos.
- **Data Encryption:** Firestore and Storage data encrypted at rest by Google. Transit encrypted via TLS 1.2+.
- **GDPR/CCPA Compliance:** Data export endpoint via Cloud Function (returns JSON zip); account deletion wipes all Firestore documents and Storage files for the user UID. Consent flow on registration with Privacy Policy and Terms of Service links.
- **Minimal Data Collection:** No third-party advertising SDKs. Firebase Analytics events are anonymized. No selling of user health data.

### 7.5 Performance Requirements

| Metric | Target |
|---|---|
| App cold start time (release build) | < 2.5 seconds |
| Home dashboard load | < 1.5 seconds |
| Exercise search response | < 500 ms (local cache) |
| Workout screen set log write | < 200 ms (Isar local) |
| Skill hold timer accuracy | ± 100 ms |
| Photo upload (LTE, 3 MB image) | < 5 seconds |
| Firestore sync latency | < 2 seconds on 4G |
| APK size (Android) | < 30 MB |
| IPA size (iOS) | < 40 MB |
| Frame rate during workout screen | 60 fps sustained |

### 7.6 Offline Behavior

- **Full offline workout logging:** Isar persists all set/rep/duration data; syncs on reconnect.
- **Cached exercise database:** All 400+ exercises cached locally on first launch; refreshed weekly via Remote Config flag.
- **Full offline skill session logging:** Timed hold sessions are written to Isar immediately; synced on reconnect.
- **Queued writes:** Firestore SDK offline persistence handles queued writes; Isar acts as second-layer durability.
- **No offline mode for:** Subscription validation, program browser (catalog), video demonstrations.

### 7.7 Platform-Specific Requirements

**iOS:**
- Minimum deployment target: iOS 16.0
- Background Modes: `remote-notification` (FCM), `audio` (rest timer ticks)
- HealthKit integration (v1.1): read body weight; write workout sessions
- Apple Sign-In required per App Store guidelines

**Android:**
- Minimum SDK: API 29 (Android 10)
- Target SDK: API 35 (Android 15)
- Exact alarms: `SCHEDULE_EXACT_ALARM` permission for rest timer notifications
- Health Connect integration (v1.1)
- 64-bit APK + AAB required for Play Store

### 7.8 Accessibility

- WCAG 2.1 AA compliance
- All interactive elements have semantic labels for screen readers (VoiceOver / TalkBack)
- Minimum tap target size: 48×48 dp
- Text scales with system font size (no fixed pixel text sizes)
- Color contrast ratio ≥ 4.5:1 for normal text, ≥ 3:1 for large text
- Haptic feedback on set completion, PR achievement, timer expiry, skill milestone unlock
- Dark mode support (system-detected; manual override in settings)

### 7.9 Localization

- Launch: English (en-US)
- v1.1: Spanish (es), German (de), French (fr), Portuguese Brazil (pt-BR)
- ARB files for all strings; no hardcoded UI text
- Right-to-left (RTL) layout support for future Arabic/Hebrew locales
- Unit localization: metric default globally; imperial default for US/UK locale detection

### 7.10 Testing Strategy

| Type | Tool | Coverage Target |
|---|---|---|
| Unit tests | `flutter_test` + Mockito | ≥ 80% domain layer |
| Widget tests | `flutter_test` | Key screens: workout, skill session, dashboard |
| Integration tests | `integration_test` package | Critical user flows (onboarding, workout log, skill log, subscription) |
| Golden tests | `golden_toolkit` | Design system components |
| E2E (CI) | Firebase Test Lab (physical device matrix) | Smoke test on 5 device profiles |
| Performance | Flutter DevTools + Firebase Performance | Frame rate, Firestore latency |
| Security | Manual + `firebase-rules-unit-testing` | Firestore rule coverage: 100% |

### 7.11 Deployment & Release

- **Environments:** `dev` (emulators), `staging` (separate Firebase project), `prod`
- **CI/CD:** GitHub Actions triggers on PR merge to `main`; runs tests, builds, deploys to TestFlight (iOS) and Play Internal Track (Android)
- **Release cadence:** Bi-weekly sprints; monthly public releases
- **Feature flags:** Firebase Remote Config gates new features; enables gradual rollout and instant kill switch
- **Crash reporting:** Firebase Crashlytics with custom keys (userId, screen, action)
- **Version naming:** `MAJOR.MINOR.PATCH+BUILD` (e.g., `1.0.0+42`)
- **App signing:** Android keystore managed via GitHub Secrets + Fastlane `supply`; iOS provisioning via Fastlane `match` with App Store Connect API

### 7.12 Subscription & Monetization

| Plan | Price (USD) | Features |
|---|---|---|
| Free | $0 | Core logging, 400+ exercises, 3 programs, 10 progress photos, basic charts |
| Premium Monthly | $9.99/month | All features unlocked, unlimited photos, video library, advanced analytics, skill analytics, custom program builder |
| Premium Annual | $59.99/year ($5.00/mo) | Same as monthly; best value badge |

- RevenueCat manages entitlement validation server-side; client never trusts local receipt.
- Server-to-server webhooks: RevenueCat → Firebase Cloud Function → Firestore `subscriptionStatus` update.
- Free trial: 7 days; credit card required (platform managed).
- Refund policy: directed to platform (App Store / Google Play); no in-app refund mechanism.

---

## Appendix A — Third-Party Integrations

| Integration | Purpose | Auth Method |
|---|---|---|
| RevenueCat | Subscription management | SDK + server webhook secret |
| Firebase suite | Auth, DB, Storage, Analytics, FCM | Google service account |

## Appendix B — Glossary

| Term | Definition |
|---|---|
| Skill Progression | A structured ladder of exercises leading from beginner to advanced (e.g., tuck planche → straddle planche → full planche) |
| Timed Hold | A set type measured in seconds of sustained body position (e.g., L-sit, front lever, handstand) |
| AMRAP | As Many Reps As Possible — a set where the user performs reps to muscular failure |
| Deload | A planned week of reduced training volume/intensity for recovery |
| RPE | Rate of Perceived Exertion — subjective effort scale 1–10 |
| FFMI | Fat-Free Mass Index — body composition metric analogous to BMI but for lean mass |
| Assisted Rep | A rep performed with band or spotter support; tracked as negative added weight |
| Weighted Bodyweight | A bodyweight exercise performed with additional load (e.g., dip belt, vest) |
| Mesocycle | A multi-week training block (typically 4–8 weeks) with a specific focus |
| Entitlement | RevenueCat concept — a feature access right tied to a subscription status |

---

*Document maintained by the CobraSthenics Product Team. For questions or change requests, open a GitHub issue with the label `product-spec`.*
