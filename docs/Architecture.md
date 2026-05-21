# CobraSthenics — System Architecture

**Version:** 2.0.0  
**Date:** 2026-05-16  
**Author:** Mobile Architecture Team  
**Status:** Approved

---

## Table of Contents

1. [High-Level System Architecture](#1-high-level-system-architecture)
2. [Flutter Project Structure](#2-flutter-project-structure)
3. [Service Layer Architecture](#3-service-layer-architecture)
4. [Repository Pattern Design](#4-repository-pattern-design)
5. [State Management](#5-state-management)
6. [Firebase Integration Strategy](#6-firebase-integration-strategy)
7. [Security Architecture](#7-security-architecture)
8. [Data Flow Diagrams](#8-data-flow-diagrams)
9. [Error Handling Strategy](#9-error-handling-strategy)
10. [Testing Architecture](#10-testing-architecture)

---

## 1. High-Level System Architecture

### 1.1 System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CLIENT LAYER                                       │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    Flutter Mobile App                               │   │
│   │                  (iOS & Android — Single Codebase)                  │   │
│   │                                                                     │   │
│   │   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │   │
│   │   │ Presentation │  │    Domain    │  │         Data             │  │   │
│   │   │    Layer     │  │    Layer     │  │         Layer            │  │   │
│   │   │              │  │              │  │                          │  │   │
│   │   │  Screens     │  │  Use Cases   │  │  Repository Impls        │  │   │
│   │   │  Widgets     │◄─┤  Entities    │◄─┤  Remote Data Sources     │  │   │
│   │   │  Providers   │  │  Repo        │  │  Local Data Sources      │  │   │
│   │   │  (Riverpod)  │  │  Interfaces  │  │  DTOs / Mappers          │  │   │
│   │   └──────────────┘  └──────────────┘  └──────────────────────────┘  │   │ 
│   │                                                                     │   │
│   │   ┌──────────────────────────────────────────────────────────────┐  │   │
│   │   │                    Local Storage (Isar DB)                   │  │   │
│   │   │      Workout Cache │ Skill Log Cache │ Exercise DB           │  │   │
│   │   └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │ HTTPS / WSS (TLS 1.3)
┌───────────────────────────────────▼────────────────────────────────────────┐
│                        FIREBASE PLATFORM                                   │
│                                                                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐ │
│  │    Firebase     │  │     Cloud       │  │      Firebase               │ │
│  │ Authentication  │  │   Firestore     │  │      Storage                │ │
│  │                 │  │                 │  │                             │ │
│  │ • Email/Pass    │  │ • User docs     │  │ • Progress photos           │ │
│  │ • Google OAuth  │  │ • Workouts      │  │ • Exercise videos (Premium) │ │
│  │ • Apple Sign-In │  │ • Skill logs    │  │ • Profile avatars           │ │
│  │ • JWT tokens    │  │ • Programs      │  │                             │ │
│  │ • Custom claims │  │ • Personal PRs  │  │                             │ │
│  └─────────────────┘  └────────┬────────┘  └─────────────────────────────┘ │
│                                │ triggers                                  │
│  ┌─────────────────┐  ┌────────▼────────┐  ┌─────────────────────────────┐ │
│  │    Firebase     │  │    Firebase     │  │      Firebase               │ │
│  │      FCM        │  │ Cloud Functions │  │   Remote Config             │ │
│  │                 │  │  (Node.js 20)   │  │                             │ │
│  │ • Push alerts   │  │                 │  │ • Feature flags             │ │
│  │ • Workout nudge │  │ • onWorkoutSave │  │ • Paywall variants          │ │
│  │ • PR celebrate  │  │ • onSkillLogSave│  │ • Exercise DB version       │ │
│  │ • Skill unlock  │  │ • onPhotoUpload │  │ • Maintenance mode          │ │
│  │ • Data topics   │  │ • onSubChange   │  │                             │ │
│  │                 │  │ • scheduledPush │  │                             │ │
│  └─────────────────┘  └────────┬────────┘  └─────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────│
                                    │ Webhooks / HTTP
┌───────────────────────────────────▼────────────────────────────────────────────┐
│                       EXTERNAL SERVICES                                        │
│                                                                                │
│  ┌───────────────────────────────────────────────────────────────────────┐     │
│  │                          RevenueCat                                   │     │
│  │  • Subscription management  • Entitlement validation  • IAP receipts  │     │
│  │  • Server-to-server webhooks → Firebase Cloud Function                │     │
│  └───────────────────────────────────────────────────────────────────────┘     │
│                                                                                │
│  Note: No GPS mapping, nutrition database, or barcode scanning APIs.           │
│  CobraSthenics is intentionally self-contained as a calisthenics training app. │
└────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Clean Architecture Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                             │
│  Flutter Widgets · Riverpod Providers · GoRouter            │
│  Depends on: Domain layer only                              │
│  Rule: No Firebase imports, no DTOs, no HTTP calls          │
├─────────────────────────────────────────────────────────────┤
│              DOMAIN LAYER  (pure Dart)                      │ 
│  Entities · Use Cases · Repository Interfaces               │
│  Value Objects · Domain Failures                            │
│  Depends on: Nothing (innermost ring)                       │
│  Rule: Zero external dependencies — no Flutter, no Firebase │
├─────────────────────────────────────────────────────────────┤
│              DATA LAYER                                     │
│  Repository Implementations · Remote Sources                │
│  Local Sources (Isar) · DTOs · Mappers                      │
│  Depends on: Domain layer interfaces                        │
│  Rule: Implements domain contracts, owns all I/O            │
└─────────────────────────────────────────────────────────────┘

Dependency Rule: Always points INWARD.
Outer layers depend on inner. Inner layers know nothing of outer.
```

---

## 2. Flutter Project Structure

### 2.1 Top-Level Directory Layout

```
CobraSthenics/
├── android/                        # Android host project
├── ios/                            # iOS host project
├── lib/
│   ├── main.dart                   # Entry point — bootstraps app
│   ├── app/                        # App-wide wiring
│   │   ├── app.dart                # Root MaterialApp + ProviderScope
│   │   ├── router/
│   │   │   ├── app_router.dart     # GoRouter configuration
│   │   │   ├── app_routes.dart     # Route name constants
│   │   │   └── route_guards.dart   # Auth + subscription guards
│   │   └── theme/
│   │       ├── app_theme.dart      # ThemeData (light + dark)
│   │       ├── app_colors.dart     # Palette constants
│   │       ├── app_text_styles.dart
│   │       └── app_spacing.dart    # 8-pt grid constants
│   │
│   ├── core/                       # Cross-cutting infrastructure
│   │   ├── di/
│   │   │   └── providers.dart      # Top-level Riverpod providers (Firebase, HTTP)
│   │   ├── network/
│   │   │   ├── connectivity_service.dart
│   │   │   └── api_client.dart     # Dio HTTP client (for future external APIs)
│   │   ├── error/
│   │   │   ├── failures.dart       # Sealed failure hierarchy
│   │   │   ├── exceptions.dart     # Raw exception types
│   │   │   └── error_handler.dart  # Global exception → Failure mapper
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── unit_converter.dart     # kg↔lb, cm↔in
│   │   │   └── calisthenics_calculators.dart  # FFMI, body fat (Navy method), volume load
│   │   ├── extensions/
│   │   │   ├── datetime_ext.dart
│   │   │   ├── string_ext.dart
│   │   │   └── num_ext.dart
│   │   └── constants/
│   │       ├── firestore_paths.dart    # Collection path constants
│   │       ├── storage_paths.dart
│   │       └── app_constants.dart
│   │
│   ├── features/                   # Feature-first modules
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── dashboard/
│   │   ├── workout/                # Workout logging + exercise database
│   │   ├── skill/                  # Skill progression + timed hold sessions
│   │   ├── program/                # Program browser + custom builder
│   │   ├── body_metrics/           # Weight + measurement logging
│   │   ├── progress_photos/
│   │   ├── analytics/
│   │   ├── notifications/
│   │   └── subscription/
│   │
│   └── shared/                     # Shared UI components
│       ├── widgets/
│       │   ├── buttons/
│       │   ├── cards/
│       │   ├── charts/             # Reusable fl_chart wrappers
│       │   ├── dialogs/
│       │   ├── inputs/
│       │   └── loaders/
│       └── models/
│           └── pagination_state.dart
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── pubspec.yaml
├── analysis_options.yaml           # Very strict lints
├── firebase.json
└── .firebaserc
```

### 2.2 Feature Module Internal Structure

Every feature follows the same internal 3-layer pattern. Example: `features/workout/`

```
features/workout/
├── domain/
│   ├── entities/
│   │   ├── workout_session.dart        # Pure Dart class — no JSON logic
│   │   ├── exercise_log.dart
│   │   └── set_log.dart
│   ├── repositories/
│   │   └── workout_repository.dart     # Abstract interface only
│   ├── usecases/
│   │   ├── start_workout_usecase.dart
│   │   ├── log_set_usecase.dart
│   │   ├── complete_workout_usecase.dart
│   │   ├── get_workout_history_usecase.dart
│   │   └── get_personal_records_usecase.dart
│   └── failures/
│       └── workout_failures.dart       # Feature-specific Failure subtypes
│
├── data/
│   ├── models/                         # DTOs with JSON serialization
│   │   ├── workout_session_model.dart
│   │   ├── exercise_log_model.dart
│   │   └── set_log_model.dart
│   ├── mappers/
│   │   └── workout_mapper.dart         # Model ↔ Entity conversions
│   ├── datasources/
│   │   ├── workout_remote_datasource.dart   # Firestore operations
│   │   └── workout_local_datasource.dart    # Isar operations
│   └── repositories/
│       └── workout_repository_impl.dart
│
└── presentation/
    ├── screens/
    │   ├── workout_tab_screen.dart
    │   ├── active_workout_screen.dart
    │   ├── workout_summary_screen.dart
    │   └── workout_history_screen.dart
    ├── widgets/
    │   ├── set_log_row.dart
    │   ├── rest_timer_overlay.dart
    │   ├── muscle_heatmap_widget.dart
    │   └── pr_badge_widget.dart
    └── providers/
        ├── active_workout_provider.dart
        ├── workout_history_provider.dart
        └── personal_records_provider.dart
```

Example: `features/skill/`

```
features/skill/
├── domain/
│   ├── entities/
│   │   ├── skill_log.dart              # Timed hold session entity
│   │   ├── skill_set.dart             # Individual hold attempt
│   │   └── skill_profile.dart         # Metadata for a skill (tree position, category)
│   ├── repositories/
│   │   └── skill_repository.dart      # Abstract interface
│   ├── usecases/
│   │   ├── log_skill_session_usecase.dart
│   │   ├── get_skill_trend_usecase.dart
│   │   ├── get_skill_tree_usecase.dart
│   │   └── get_skill_milestones_usecase.dart
│   └── failures/
│       └── skill_failures.dart
│
├── data/
│   ├── models/
│   │   ├── skill_log_model.dart
│   │   └── skill_set_model.dart
│   ├── mappers/
│   │   └── skill_mapper.dart
│   ├── datasources/
│   │   ├── skill_remote_datasource.dart
│   │   └── skill_local_datasource.dart
│   └── repositories/
│       └── skill_repository_impl.dart
│
└── presentation/
    ├── screens/
    │   ├── skill_tab_screen.dart
    │   ├── skill_tree_screen.dart
    │   ├── skill_detail_screen.dart
    │   ├── timed_hold_session_screen.dart
    │   └── skill_milestones_screen.dart
    ├── widgets/
    │   ├── skill_tree_node_widget.dart
    │   ├── hold_timer_widget.dart
    │   ├── skill_trend_chart.dart
    │   └── skill_milestone_badge.dart
    └── providers/
        ├── skill_session_provider.dart
        ├── skill_trend_provider.dart
        └── skill_tree_provider.dart
```

### 2.3 Key `pubspec.yaml` Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.0

  # Firebase
  firebase_core: ^3.3.0
  firebase_auth: ^5.1.4
  cloud_firestore: ^5.2.1
  firebase_storage: ^12.1.3
  firebase_messaging: ^15.0.4
  firebase_remote_config: ^5.0.4
  firebase_analytics: ^11.2.1
  firebase_crashlytics: ^4.0.4

  # Local storage
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0

  # Networking
  dio: ^5.4.3
  connectivity_plus: ^6.0.3

  # Subscriptions
  purchases_flutter: ^7.3.0

  # UI / Charts
  fl_chart: ^0.69.0
  cached_network_image: ^3.3.1
  flutter_local_notifications: ^17.2.1
  video_player: ^2.9.1               # For exercise video demonstrations (Premium)

  # Utilities
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  dartz: ^0.10.1                     # Functional Either type
  equatable: ^2.0.5
  intl: ^0.19.0
  image_picker: ^1.1.2
  path_provider: ^2.1.3
  permission_handler: ^11.3.1
  wakelock_plus: ^1.2.0              # Keep screen on during timed hold sessions

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  isar_generator: ^3.1.0
  mockito: ^5.4.4
  flutter_lints: ^4.0.0
  golden_toolkit: ^0.15.0
```

> **Intentionally excluded:** `geolocator`, `google_maps_flutter`, `flutter_background_geolocation` (no GPS tracking), `mobile_scanner` (no barcode scanning). CobraSthenics is a focused calisthenics app — these packages are not needed and would bloat the binary.

---

## 3. Service Layer Architecture

The service layer lives in `core/` and provides singleton infrastructure objects consumed by data layer datasources. Services are never imported by domain or presentation layers.

### 3.1 Service Registry

```
core/
└── services/
    ├── firebase/
    │   ├── firebase_auth_service.dart
    │   ├── firestore_service.dart
    │   ├── storage_service.dart
    │   ├── fcm_service.dart
    │   └── remote_config_service.dart
    ├── subscription/
    │   └── subscription_service.dart      # RevenueCat wrapper
    └── local/
        ├── isar_service.dart              # Isar DB lifecycle
        └── secure_storage_service.dart    # flutter_secure_storage wrapper
```

### 3.2 FirestoreService

```dart
// core/services/firebase/firestore_service.dart

/// Low-level Firestore wrapper. Datasources call this; they never
/// import cloud_firestore directly in the domain or presentation layers.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db) {
    _db.settings = const Settings(
      persistenceEnabled: true,           // Built-in offline cache
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<Map<String, dynamic>> getDocument(String path) async {
    final snap = await _db.doc(path).get();
    if (!snap.exists) throw FirestoreException.notFound(path);
    return snap.data()!;
  }

  Stream<Map<String, dynamic>?> documentStream(String path) {
    return _db.doc(path).snapshots().map((s) => s.exists ? s.data() : null);
  }

  Future<List<Map<String, dynamic>>> getCollection({
    required String path,
    List<QueryFilter> filters = const [],
    List<QueryOrder> orders = const [],
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(path);
    for (final f in filters) query = f.apply(query);
    for (final o in orders) query = query.orderBy(o.field, descending: o.descending);
    if (limit != null) query = query.limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snap = await query.get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Stream<List<Map<String, dynamic>>> collectionStream({
    required String path,
    List<QueryFilter> filters = const [],
    List<QueryOrder> orders = const [],
  }) {
    Query<Map<String, dynamic>> query = _db.collection(path);
    for (final f in filters) query = f.apply(query);
    for (final o in orders) query = query.orderBy(o.field, descending: o.descending);
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<void> setDocument(String path, Map<String, dynamic> data, {bool merge = false}) async {
    await _db.doc(path).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument(String path, Map<String, dynamic> fields) async {
    await _db.doc(path).update(fields);
  }

  Future<void> deleteDocument(String path) async {
    await _db.doc(path).delete();
  }

  Future<String> addDocument(String collectionPath, Map<String, dynamic> data) async {
    final ref = await _db.collection(collectionPath).add(data);
    return ref.id;
  }

  Future<void> runTransaction(Future<void> Function(Transaction txn) handler) async {
    await _db.runTransaction(handler);
  }

  Future<void> runBatch(void Function(WriteBatch batch) handler) async {
    final batch = _db.batch();
    handler(batch);
    await batch.commit();
  }
}
```

### 3.3 IsarService

```dart
// core/services/local/isar_service.dart

/// Manages Isar DB lifecycle and schema registration.
/// All features share a single Isar instance opened at app start.
class IsarService {
  late final Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        WorkoutSessionIsarSchema,
        ExerciseLogIsarSchema,
        ExerciseIsarSchema,        // Full exercise library cached locally
        SkillLogIsarSchema,        // Skill session cache for offline access
        WeightLogIsarSchema,
      ],
      directory: dir.path,
    );
  }

  Isar get db => _isar;
}
```

---

## 4. Repository Pattern Design

### 4.1 Workout Repository

```dart
// features/workout/domain/repositories/workout_repository.dart

abstract class WorkoutRepository {
  /// Starts a new workout session. Writes to local Isar immediately.
  Future<Either<Failure, WorkoutSession>> startWorkout({String? name});

  /// Adds or updates a set log within the active workout.
  Future<Either<Failure, WorkoutSession>> logSet({
    required String workoutId,
    required String exerciseId,
    required SetLog setLog,
  });

  /// Finalises the workout: computes muscle group volume, checks PRs, syncs to Firestore.
  Future<Either<Failure, WorkoutSession>> completeWorkout(String workoutId);

  /// Paginated history, newest first.
  Future<Either<Failure, PaginatedList<WorkoutSession>>> getHistory({
    int page = 0,
    int pageSize = 20,
  });

  /// Streams the currently active (incomplete) workout, or null if none.
  Stream<Either<Failure, WorkoutSession?>> watchActiveWorkout();
}
```

### 4.2 Skill Repository

```dart
// features/skill/domain/repositories/skill_repository.dart

abstract class SkillRepository {
  /// Logs a completed skill hold session. Writes to Isar immediately.
  Future<Either<Failure, SkillLog>> logSkillSession(SkillLog session);

  /// Returns hold-time trend for a given skill, ordered by date ascending.
  Future<Either<Failure, List<SkillLog>>> getSkillTrend({
    required String skillId,
    int limitDays = 90,
  });

  /// Returns the full skill tree structure for the browser.
  Future<Either<Failure, List<SkillProfile>>> getSkillTree();

  /// Returns all skill milestones the user has achieved.
  Future<Either<Failure, List<SkillMilestone>>> getMilestones();
}
```

### 4.3 Repository Implementation Pattern (Offline-First)

```dart
// features/workout/data/repositories/workout_repository_impl.dart

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource _remote;
  final WorkoutLocalDataSource _local;
  final ConnectivityService _connectivity;

  const WorkoutRepositoryImpl({
    required WorkoutRemoteDataSource remote,
    required WorkoutLocalDataSource local,
    required ConnectivityService connectivity,
  }) : _remote = remote, _local = local, _connectivity = connectivity;

  @override
  Future<Either<Failure, WorkoutSession>> startWorkout({String? name}) async {
    try {
      final session = WorkoutSessionModel.create(name: name);
      // Always write to Isar first — offline-first
      await _local.saveWorkout(session);
      // Best-effort Firestore sync; do not fail if offline
      final isOnline = await _connectivity.isConnected;
      if (isOnline) {
        await _remote.upsertWorkout(session);
      }
      return Right(WorkoutMapper.toEntity(session));
    } on IsarException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on FirestoreException catch (e) {
      // Firestore failure is non-fatal during workout start
      return Right(WorkoutMapper.toEntity(
        await _local.getActiveWorkout() ?? WorkoutSessionModel.create(name: name),
      ));
    }
  }

  @override
  Stream<Either<Failure, WorkoutSession?>> watchActiveWorkout() {
    // Stream from Isar for real-time UI updates during active workout
    return _local.watchActiveWorkout().map(
      (model) => Right(model != null ? WorkoutMapper.toEntity(model) : null),
    );
  }
}
```

---

## 5. State Management

### 5.1 Riverpod Provider Hierarchy

```dart
// ── Infrastructure Providers (core/di/providers.dart) ─────────────────

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirestoreService firestoreService(FirestoreServiceRef ref) =>
    FirestoreService(FirebaseFirestore.instance);

@Riverpod(keepAlive: true)
IsarService isarService(IsarServiceRef ref) => IsarService();

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(SubscriptionServiceRef ref) =>
    SubscriptionService(Purchases.instance);

// ── Feature Providers (per feature) ───────────────────────────────────

// features/workout/presentation/providers/active_workout_provider.dart
@riverpod
class ActiveWorkoutNotifier extends _$ActiveWorkoutNotifier {
  @override
  Future<WorkoutSession?> build() async {
    final useCase = ref.read(watchActiveWorkoutUseCaseProvider);
    // Subscribe to Isar stream
    ref.listenSelf((_, __) {});
    return useCase.watch().first.then((e) => e.fold((_) => null, (s) => s));
  }

  Future<void> logSet({required String exerciseId, required SetLog setLog}) async {
    final workoutId = state.value?.id;
    if (workoutId == null) return;
    final useCase = ref.read(logSetUseCaseProvider);
    final result = await useCase(workoutId: workoutId, exerciseId: exerciseId, setLog: setLog);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (session) => state = AsyncData(session),
    );
  }

  Future<void> completeWorkout() async {
    final workoutId = state.value?.id;
    if (workoutId == null) return;
    state = const AsyncLoading();
    final useCase = ref.read(completeWorkoutUseCaseProvider);
    final result = await useCase(workoutId);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }
}

// features/skill/presentation/providers/skill_session_provider.dart
@riverpod
class SkillSessionNotifier extends _$SkillSessionNotifier {
  @override
  SkillSessionState build() => SkillSessionState.idle();

  void startTimer() {
    state = state.copyWith(isRunning: true, startedAt: DateTime.now());
    // Wakelock enabled via platform channel when timer is running
  }

  void stopTimer() {
    final duration = DateTime.now().difference(state.startedAt!);
    state = state.copyWith(
      isRunning: false,
      lastHoldSeconds: duration.inSeconds,
      sets: [...state.sets, SkillSet(holdSeconds: duration.inSeconds)],
    );
  }

  Future<void> saveSession(String skillId) async {
    final log = SkillLog(skillId: skillId, sets: state.sets);
    final useCase = ref.read(logSkillSessionUseCaseProvider);
    await useCase(log);
    state = SkillSessionState.idle();
  }
}
```

### 5.2 GoRouter Auth & Subscription Guards

```dart
// app/router/route_guards.dart

String? authGuard(BuildContext context, GoRouterState routerState) {
  final isAuthenticated = ref.read(authStateProvider).valueOrNull != null;
  if (!isAuthenticated) return AppRoutes.welcome;
  return null;
}

String? premiumGuard(BuildContext context, GoRouterState routerState) {
  final isPremium = ref.read(subscriptionStatusProvider).valueOrNull?.isPremium ?? false;
  if (!isPremium) return AppRoutes.paywall;
  return null;
}
```

---

## 6. Firebase Integration Strategy

### 6.1 Firestore Collection Paths

```dart
// core/constants/firestore_paths.dart

class FirestorePaths {
  // ── User Root ─────────────────────────────────────────────────────────
  static String user(String uid)                => 'users/$uid';

  // ── Workout ───────────────────────────────────────────────────────────
  static String workouts(String uid)            => 'users/$uid/workouts';
  static String workout(String uid, String id)  => 'users/$uid/workouts/$id';

  // ── Skill Logs ────────────────────────────────────────────────────────
  static String skillLogs(String uid)           => 'users/$uid/skillLogs';
  static String skillLog(String uid, String id) => 'users/$uid/skillLogs/$id';

  // ── Program Enrollments ───────────────────────────────────────────────
  static String enrollments(String uid)         => 'users/$uid/programEnrollments';
  static String enrollment(String uid, String id) => 'users/$uid/programEnrollments/$id';

  // ── Personal Records ──────────────────────────────────────────────────
  static String personalRecords(String uid)     => 'users/$uid/personalRecords';
  static String personalRecord(String uid, String exerciseId)
    => 'users/$uid/personalRecords/$exerciseId';

  // ── Body Metrics ──────────────────────────────────────────────────────
  static String weightLogs(String uid)          => 'users/$uid/weightLogs';
  static String measurementLogs(String uid)     => 'users/$uid/measurementLogs';

  // ── Progress Photos ───────────────────────────────────────────────────
  static String progressPhotos(String uid)      => 'users/$uid/progressPhotos';

  // ── Custom Exercises ──────────────────────────────────────────────────
  static String customExercises(String uid)     => 'users/$uid/customExercises';

  // ── Global Collections ────────────────────────────────────────────────
  static const String exercises                 = 'exercises';
  static const String globalPrograms            = 'globalPrograms';
  static const String appConfig                 = 'appConfig';

  FirestorePaths._();
}
```

### 6.2 Cloud Functions

```javascript
// functions/src/index.ts

// Triggered after a workout is written to Firestore
exports.onWorkoutComplete = functions.firestore
  .document('users/{uid}/workouts/{workoutId}')
  .onWrite(async (change, context) => {
    const workout = change.after.data();
    if (!workout || !workout.completedAt) return; // Only run on completion

    const uid = context.params.uid;
    await updatePersonalRecords(uid, workout.exerciseLogs);
    await computeMuscleGroupVolume(uid, workout);
    await sendPrNotificationIfApplicable(uid, workout);
  });

// Triggered after a skill log is written
exports.onSkillLogSave = functions.firestore
  .document('users/{uid}/skillLogs/{skillLogId}')
  .onCreate(async (snap, context) => {
    const log = snap.data();
    const uid = context.params.uid;
    await updateSkillPersonalRecord(uid, log.skillId, log.bestHoldSeconds);
    await checkSkillMilestone(uid, log.skillId, log.bestHoldSeconds);
  });

// Triggered on photo upload to generate thumbnail
exports.onPhotoUpload = functions.storage
  .object()
  .onFinalize(async (object) => {
    if (!object.name?.includes('/photos/')) return;
    if (object.name?.includes('/thumbs/')) return; // Avoid re-triggering
    await generateThumbnail(object, 200, 200);
  });

// RevenueCat subscription webhook
exports.onSubscriptionChange = functions.https.onRequest(async (req, res) => {
  const event = req.body;
  await syncEntitlementToFirestore(event);
  res.sendStatus(200);
});

// Scheduled push notifications (runs via Cloud Scheduler)
exports.sendScheduledNotifications = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async () => {
    await sendWorkoutReminders();
    await sendWeeklySummaries(); // Sunday evenings only
    await sendAdherenceNudges();
  });
```

---

## 7. Security Architecture

### 7.1 Authentication Flow

```
User taps Sign In (Google / Apple / Email)
    │
    ▼
FirebaseAuthService.signInWith*()
    │
    ▼
Firebase Authentication validates credentials
    │
    ▼
JWT issued (valid 1 hour; Firebase auto-refreshes)
    │
    ▼
AuthStateChanges stream emits new User
    │
    ▼
GoRouter auth guard allows navigation to main app
    │
    ▼
All subsequent Firestore/Storage requests include JWT in header
```

### 7.2 Firestore Security Rules Summary

| Collection | Read | Write |
|---|---|---|
| `exercises/` | Any authenticated user | Admin custom claim only |
| `globalPrograms/` | Any authenticated user | Admin custom claim only |
| `appConfig/` | Any authenticated user | Admin custom claim only |
| `users/{uid}/**` | Own UID only | Own UID only (except `personalRecords/` — Cloud Fn only) |

### 7.3 Storage Security Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Exercise videos and thumbnails — readable by all authenticated users
    match /exercises/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false; // Admin SDK only
    }

    // User-scoped files (photos, avatars)
    match /users/{uid}/{allPaths=**} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

### 7.4 Subscription Entitlement Validation

```
Client (Flutter)
    │
    │  request.isPremium
    ▼
SubscriptionService (RevenueCat SDK)
    │
    │  validates receipt with RevenueCat servers
    ▼
RevenueCat Platform
    │
    │  webhook on status change
    ▼
Firebase Cloud Function (onSubscriptionChange)
    │
    │  writes subscriptionStatus to users/{uid}
    ▼
Firestore
    │
    │  Firestore rules check subscriptionStatus for gated collections
    ▼
Client reads updated entitlement status
```

> **Rule:** The client SDK result from RevenueCat is used for UI gating only. Firestore rules are the authoritative gate for server-side data access. Client-side entitlement values are never trusted for security decisions.

---

## 8. Data Flow Diagrams

### 8.1 Workout Logging Data Flow (Offline-First)

```
User completes a set
    │
    ▼
ActiveWorkoutNotifier.logSet()
    │
    ▼
LogSetUseCase.call()
    │
    ▼
WorkoutRepositoryImpl.logSet()
    │
    ├──► WorkoutLocalDataSource.updateSet()  ←── Isar write (< 200 ms)
    │         │
    │         └──► Isar emits updated WorkoutSession
    │                   │
    │                   └──► ActiveWorkoutNotifier state updated
    │                             │
    │                             └──► UI rebuilds (set marked complete, rest timer starts)
    │
    └──► (background) WorkoutRemoteDataSource.upsertWorkout()  ←── Firestore write
              │
              └──► If offline: queued by Firestore SDK, sent on reconnect
```

### 8.2 Skill Session Data Flow

```
User taps [Stop] after holding front lever
    │
    ▼
SkillSessionNotifier.stopTimer()
    │  Calculates hold duration from startedAt → now
    ▼
state updated with holdSeconds, set added to sets[]
    │
    ▼ (user taps [Save Session])
SkillSessionNotifier.saveSession()
    │
    ▼
LogSkillSessionUseCase.call(SkillLog)
    │
    ▼
SkillRepositoryImpl
    │
    ├──► SkillLocalDataSource.saveSkillLog()   ←── Isar write
    │
    └──► SkillRemoteDataSource.upsertSkillLog() ←── Firestore write
              │
              └──► Cloud Function: onSkillLogSave
                        │
                        ├──► Update personalRecords/{skillId}
                        └──► Check skill milestone → send push if new milestone
```

### 8.3 Exercise Database Sync

```
App first launch (or Remote Config signals new version)
    │
    ▼
ExerciseRepositoryImpl.syncExerciseDatabase()
    │
    ▼
ExerciseRemoteDataSource.fetchAll()   ←── Reads /exercises collection (500+ docs)
    │
    ▼
ExerciseLocalDataSource.replaceAll()  ←── Writes to Isar (one-time, batched)
    │
    ▼
All subsequent exercise searches use Isar (local, < 500 ms, works offline)
```

---

## 9. Error Handling Strategy

### 9.1 Failure Hierarchy

```dart
// core/error/failures.dart

sealed class Failure extends Equatable {
  final String message;
  final String? code;
  const Failure({required this.message, this.code});
  @override List<Object?> get props => [message, code];
}

// Infrastructure failures
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.code});
}
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}
final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

// Domain failures
final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}
final class WorkoutFailure extends Failure {
  const WorkoutFailure({required super.message, super.code});
}
final class SkillFailure extends Failure {
  const SkillFailure({required super.message, super.code});
}
final class SubscriptionFailure extends Failure {
  const SubscriptionFailure({required super.message, super.code});
}
```

### 9.2 Error Handler (Data Layer)

```dart
// core/error/error_handler.dart

class ErrorHandler {
  static Failure handle(Object error) {
    return switch (error) {
      FirebaseException e  => _handleFirebaseError(e),
      IsarException e      => CacheFailure(message: e.message ?? 'Local storage error'),
      SocketException _    => const NetworkFailure(),
      DioException e       => _handleDioError(e),
      _                    => ServerFailure(message: error.toString()),
    };
  }

  static Failure _handleFirebaseError(FirebaseException e) {
    return switch (e.code) {
      'not-found'          => CacheFailure(message: 'Document not found', code: 'not_found'),
      'permission-denied'  => const AuthFailure(message: 'Permission denied', code: 'permission_denied'),
      'unavailable'        => const NetworkFailure(message: 'Service temporarily unavailable'),
      'resource-exhausted' => const ServerFailure(message: 'Quota exceeded', code: 'quota_exceeded'),
      _                    => ServerFailure(message: e.message ?? 'Firebase error', code: e.code),
    };
  }

  static Failure _handleDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout    => const NetworkFailure(message: 'Connection timed out'),
      DioExceptionType.connectionError   => const NetworkFailure(),
      DioExceptionType.badResponse       => ServerFailure(
          message: e.response?.data?['message'] ?? 'Server error',
          code: e.response?.statusCode?.toString(),
        ),
      _                                  => const NetworkFailure(),
    };
  }
}
```

---

## 10. Testing Architecture

### 10.1 Unit Test Structure (Domain Layer)

```dart
// test/unit/features/workout/usecases/complete_workout_usecase_test.dart

void main() {
  late CompleteWorkoutUseCase useCase;
  late MockWorkoutRepository mockRepo;

  setUp(() {
    mockRepo = MockWorkoutRepository();
    useCase = CompleteWorkoutUseCase(mockRepo);
  });

  group('CompleteWorkoutUseCase', () {
    const workoutId = 'workout_123';
    final tSession = WorkoutSession(
      id: workoutId,
      name: 'Push Day',
      startedAt: DateTime.now(),
      completedAt: DateTime.now(),
      durationSeconds: 2700,
      muscleGroupVolume: {'chest': 30, 'triceps': 20, 'shoulders': 15},
      exerciseLogs: [],
    );

    test('should return WorkoutSession on success', () async {
      when(mockRepo.completeWorkout(workoutId))
          .thenAnswer((_) async => Right(tSession));

      final result = await useCase(workoutId);

      expect(result, Right(tSession));
      verify(mockRepo.completeWorkout(workoutId)).called(1);
    });

    test('should return CacheFailure when local save fails', () async {
      const failure = CacheFailure(message: 'Isar write failed');
      when(mockRepo.completeWorkout(workoutId))
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(workoutId);

      expect(result, const Left(failure));
    });
  });
}
```

### 10.2 Skill Session Unit Test

```dart
// test/unit/features/skill/usecases/log_skill_session_usecase_test.dart

void main() {
  late LogSkillSessionUseCase useCase;
  late MockSkillRepository mockRepo;

  setUp(() {
    mockRepo = MockSkillRepository();
    useCase = LogSkillSessionUseCase(mockRepo);
  });

  group('LogSkillSessionUseCase', () {
    final tLog = SkillLog(
      id: 'sl_abc',
      skillId: 'tuck-front-lever',
      skillName: 'Tuck Front Lever',
      sets: [
        SkillSet(setIndex: 0, holdSeconds: 8),
        SkillSet(setIndex: 1, holdSeconds: 10),
      ],
      bestHoldSeconds: 10,
    );

    test('should persist skill log on success', () async {
      when(mockRepo.logSkillSession(tLog))
          .thenAnswer((_) async => Right(tLog));

      final result = await useCase(tLog);

      expect(result.isRight(), true);
      verify(mockRepo.logSkillSession(tLog)).called(1);
    });
  });
}
```

### 10.3 Repository Test with Fake DataSources

```dart
// test/unit/features/workout/data/workout_repository_impl_test.dart

void main() {
  late WorkoutRepositoryImpl repo;
  late FakeWorkoutRemoteDataSource fakeRemote;
  late FakeWorkoutLocalDataSource fakeLocal;
  late MockConnectivityService mockConnectivity;

  setUp(() {
    fakeRemote = FakeWorkoutRemoteDataSource();
    fakeLocal = FakeWorkoutLocalDataSource();
    mockConnectivity = MockConnectivityService();
    repo = WorkoutRepositoryImpl(
      remote: fakeRemote,
      local: fakeLocal,
      connectivity: mockConnectivity,
    );
  });

  test('startWorkout writes to local immediately regardless of connectivity', () async {
    when(mockConnectivity.isConnected).thenAnswer((_) async => false);

    final result = await repo.startWorkout(name: 'Morning Pull Day');

    expect(result.isRight(), true);
    expect(fakeLocal.savedWorkouts, hasLength(1));
    expect(fakeRemote.upsertedWorkouts, isEmpty); // No remote write when offline
  });
}
```

### 10.4 Widget Test Pattern

```dart
// test/widget/features/workout/active_workout_screen_test.dart

void main() {
  testWidgets('shows set completion button when exercise is added', (tester) async {
    final container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(FakeWorkoutRepository()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ActiveWorkoutScreen()),
      ),
    );

    await tester.tap(find.byKey(const Key('add_exercise_button')));
    await tester.pumpAndSettle();

    expect(find.byType(SetLogRow), findsOneWidget);
    expect(find.byKey(const Key('complete_set_button')), findsOneWidget);
  });

  testWidgets('timed hold session shows running timer when started', (tester) async {
    final container = ProviderContainer(
      overrides: [
        skillRepositoryProvider.overrideWithValue(FakeSkillRepository()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TimedHoldSessionScreen(skillId: 'l-sit')),
      ),
    );

    await tester.tap(find.byKey(const Key('start_hold_button')));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('hold_timer_display')), findsOneWidget);
    expect(find.byKey(const Key('stop_hold_button')), findsOneWidget);
  });
}
```

---

## Appendix A — ADRs (Architecture Decision Records)

### ADR-001: Riverpod over BLoC
**Decision:** Use Riverpod 2.x with codegen.  
**Rationale:** BLoC adds boilerplate (Events, States, Cubits per feature). Riverpod's `AsyncNotifier` handles the async+stream pattern natively, has built-in DI, and integrates with `go_router` redirect guards without extra plumbing.  
**Trade-off:** Smaller community vs BLoC; steeper Riverpod learning curve for junior devs.

### ADR-002: Isar as local cache over Hive
**Decision:** Use Isar 3.x for local persistence.  
**Rationale:** Isar provides type-safe queries, ACID transactions, and significantly better read performance than Hive for complex filtering (workout history, exercise search, skill trend queries). Hive's box model is unsuitable for relational-ish queries.  
**Trade-off:** Larger binary footprint (+2 MB).

### ADR-003: dartz Either over exception-based error handling
**Decision:** All repository methods return `Either<Failure, T>`.  
**Rationale:** Explicit error types at compile time; callers cannot accidentally ignore failures. Eliminates try/catch in presentation layer entirely.  
**Trade-off:** Requires team familiarity with functional patterns.

### ADR-004: Feature-first over layer-first folder structure
**Decision:** `lib/features/workout/` instead of `lib/data/`, `lib/domain/`, `lib/presentation/`.  
**Rationale:** Feature-first maximises code locality. A developer working on the skill feature edits only files under `features/skill/`. Layer-first scatters related files across the project.  
**Trade-off:** Slightly harder to enforce layer rules via folder linting.

### ADR-005: No GPS / No Nutrition features
**Decision:** Explicitly excluded GPS activity tracking and nutrition/calorie logging from CobraSthenics.  
**Rationale:** CobraSthenics is a dedicated calisthenics app. Adding GPS tracking (running, cycling) and nutrition logging would dilute the product identity and introduce 6+ heavy dependencies (geolocator, google_maps_flutter, background location service, Open Food Facts API, barcode scanner, FatSecret API). The calisthenics market is underserved by focused tools; a tight scope delivers a more polished experience. Users requiring nutrition tracking should use dedicated apps.  
**Trade-off:** Cannot serve users who want an all-in-one fitness app.

---

## Appendix B — Dependency Graph

```
Presentation ──depends on──► Domain ◄──depends on── Data
                                │                      │
                                │                      │
                          [Interfaces]          [Implementations]
                          [Entities]            [DTOs + Mappers]
                          [Use Cases]           [FirestoreService]
                                                [IsarService]
                                                [ApiClient (future)]

External:
  Data ──uses──► FirebaseSDK, Isar, Dio, RevenueCatSDK
  Presentation ──uses──► Flutter, Riverpod, GoRouter, fl_chart, video_player
  Domain ──uses──► dartz, equatable  (pure Dart only)
```

---

*Document maintained by the CobraSthenics Architecture Team. Raise a pull request to propose changes; all ADRs require tech-lead sign-off.*
