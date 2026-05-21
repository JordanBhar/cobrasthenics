# FitCore — Coding Guidelines

**Version:** 1.0.0  
**Date:** 2026-03-09  
**Author:** Engineering Team  
**Status:** Enforced

> These guidelines are not suggestions. All code merged into `main` must comply. PRs that violate these rules will not be approved. When in doubt, ask before you build — not after.

---

## Table of Contents

1. [Core Principles](#1-core-principles)
2. [Project Structure](#2-project-structure)
3. [Clean Architecture Rules](#3-clean-architecture-rules)
4. [Repository Pattern](#4-repository-pattern)
5. [Riverpod State Management](#5-riverpod-state-management)
6. [Feature Module Rules](#6-feature-module-rules)
7. [Firestore Access Rules](#7-firestore-access-rules)
8. [UI Layer Rules](#8-ui-layer-rules)
9. [Error Handling](#9-error-handling)
10. [Naming Conventions](#10-naming-conventions)
11. [Code Style](#11-code-style)
12. [Testing Standards](#12-testing-standards)
13. [Git Workflow](#13-git-workflow)
14. [Anti-Patterns Catalog](#14-anti-patterns-catalog)

---

## 1. Core Principles

These five principles govern every decision in this codebase. When two guidelines conflict, apply the principle that ranks higher.

### 1.1 The Dependency Rule

**Dependencies always point inward.** Domain has zero external dependencies. Data depends on Domain. Presentation depends on Domain. Data and Presentation never depend on each other.

```
         Presentation
              │
              ▼
           Domain        ◄── innermost; no external deps
              ▲
              │
            Data
```

If you find yourself importing a Firestore type into a domain entity, you have violated this rule. Stop and fix it.

### 1.2 Firestore Is an Implementation Detail

The rest of the application must be completely unaware that Firestore exists. You could swap Firestore for PostgreSQL tomorrow and the domain layer, presentation layer, and all tests should require zero changes. The word `Firestore`, `DocumentSnapshot`, `CollectionReference`, or any Firebase type must never appear outside the `data/` layer.

### 1.3 The UI Knows Nothing About Storage

Widgets and providers do not query databases, call APIs, or manipulate raw data models. They call use cases. Use cases call repositories. Repositories call data sources. This chain is non-negotiable.

### 1.4 Explicit Over Implicit

Prefer explicit, typed, named constructs over clever code. A 40-line function with clear variable names is better than a 10-line function that requires a comment to explain what it does.

### 1.5 Failures Are First-Class Citizens

Every operation that can fail must express that failure in its return type using `Either<Failure, T>`. Throwing exceptions across layer boundaries is forbidden. Exceptions are caught at the data layer and converted to typed `Failure` objects before they surface.

---

## 2. Project Structure

### 2.1 Top-Level Layout

```
lib/
├── app/                    # Root widget, router, theme — app-wide wiring only
├── core/                   # Cross-cutting infrastructure: DI, error, utils, constants
├── features/               # One directory per vertical feature slice
└── shared/                 # Reusable widgets and models with zero feature knowledge
```

### 2.2 Feature Directory Layout

Every feature is a self-contained vertical slice with three internal layers:

```
features/{feature_name}/
├── domain/
│   ├── entities/           # Pure Dart classes — the truth; zero serialization logic
│   ├── repositories/       # Abstract interfaces only — no implementations here
│   ├── usecases/           # One file per use case; single public method
│   └── failures/           # Feature-specific Failure subtypes
├── data/
│   ├── models/             # DTOs: JSON/Firestore serialization, annotated with freezed
│   ├── mappers/            # Model ↔ Entity conversion; no business logic
│   ├── datasources/        # Abstract interfaces + implementations per backend
│   └── repositories/       # Implements domain repository interface
└── presentation/
    ├── screens/            # Full-page widgets; one file per screen
    ├── widgets/            # Feature-specific reusable widgets
    └── providers/          # Riverpod notifiers and functional providers
```

### 2.3 The `core/` Directory

```
core/
├── di/
│   └── providers.dart          # Infrastructure-level Riverpod providers
├── error/
│   ├── failures.dart           # Sealed Failure hierarchy
│   ├── exceptions.dart         # Raw exception types (data layer internal)
│   └── error_handler.dart      # Exception → Failure mapper
├── network/
│   ├── api_client.dart         # Dio instance with interceptors
│   └── connectivity_service.dart
├── services/
│   ├── firebase_auth_service.dart
│   ├── firestore_service.dart
│   ├── storage_service.dart
│   └── fcm_service.dart
├── utils/
│   ├── fitness_calculators.dart
│   ├── unit_converter.dart
│   └── date_utils.dart
├── extensions/
│   ├── either_ext.dart
│   └── async_value_ext.dart
└── constants/
    ├── firestore_paths.dart    # All Firestore collection/document paths
    └── app_constants.dart
```

**Rule:** `core/` contains no feature logic. It knows nothing about workouts, nutrition, or any domain concept. If you find yourself writing `if (workout.isCompleted)` inside `core/`, move that logic to the correct feature.

---

## 3. Clean Architecture Rules

### 3.1 Layer Boundaries — What Each Layer Can Import

| Layer | May Import | Must Not Import |
|---|---|---|
| `domain/` | `dartz`, `equatable`, other domain classes | Flutter, Firebase, Dio, Isar, any `data/` class |
| `data/` | `domain/`, Firebase SDKs, Isar, Dio, `freezed` | `presentation/`, any widget |
| `presentation/` | `domain/`, `riverpod`, Flutter widgets | Firebase SDKs, Isar, `data/` models |
| `core/services/` | Firebase SDKs, external packages | `features/` (any feature) |

Enforce this with `analysis_options.yaml` lint rules and PR review. A failing `import 'package:cloud_firestore/cloud_firestore.dart'` in a `domain/` file is a build-breaking violation.

### 3.2 Entities

Entities are pure Dart classes representing your domain truth. They have no JSON methods, no Firestore methods, no `toMap()`, no `fromJson()`.

```dart
// ✅ CORRECT — pure domain entity
class WorkoutSession extends Equatable {
  final String id;
  final String? name;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double totalVolumeKg;
  final List<ExerciseLog> exerciseLogs;

  const WorkoutSession({
    required this.id,
    this.name,
    required this.startedAt,
    this.completedAt,
    required this.totalVolumeKg,
    required this.exerciseLogs,
  });

  bool get isActive => completedAt == null;

  double get estimatedDurationMinutes =>
      completedAt != null
          ? completedAt!.difference(startedAt).inMinutes.toDouble()
          : DateTime.now().difference(startedAt).inMinutes.toDouble();

  @override
  List<Object?> get props => [id, startedAt, completedAt, totalVolumeKg];
}
```

```dart
// ❌ WRONG — Firestore logic leaked into domain entity
class WorkoutSession {
  // Never do this in an entity
  factory WorkoutSession.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

### 3.3 Use Cases

One use case = one business operation = one public callable method. Use cases are named with a verb + noun: `CompleteWorkoutUseCase`, `LogSetUseCase`, `GetWorkoutHistoryUseCase`.

```dart
// ✅ CORRECT — single responsibility, returns Either
class CompleteWorkoutUseCase {
  final WorkoutRepository _repository;

  const CompleteWorkoutUseCase(this._repository);

  Future<Either<Failure, WorkoutSession>> call(String workoutId) {
    return _repository.completeWorkout(workoutId);
  }
}
```

```dart
// ❌ WRONG — multiple responsibilities in one use case
class WorkoutUseCase {
  Future<void> start() { ... }
  Future<void> complete() { ... }
  Future<void> delete() { ... }
  Future<List<WorkoutSession>> getAll() { ... }
}
```

**Use case rules:**
- Constructor accepts only repository interfaces (injected via Riverpod)
- The single public method is named `call()` to enable function-call syntax
- No `if (Platform.isAndroid)` or any platform checks
- No direct Firebase references
- May call multiple repositories if the operation genuinely spans them

### 3.4 Repository Interfaces

Repository interfaces live in `domain/repositories/` and are abstract classes. They express what the app needs in domain terms — never in storage terms.

```dart
// ✅ CORRECT
abstract class WorkoutRepository {
  Future<Either<Failure, WorkoutSession>> startWorkout({String? name});
  Future<Either<Failure, WorkoutSession>> completeWorkout(String workoutId);
  Future<Either<Failure, PaginatedList<WorkoutSession>>> getHistory({int page, int pageSize});
  Stream<Either<Failure, WorkoutSession?>> watchActiveWorkout();
}
```

```dart
// ❌ WRONG — storage concepts leaking into domain interface
abstract class WorkoutRepository {
  Future<DocumentSnapshot> getWorkoutDocument(String id);         // Firestore type
  Future<void> updateFirestoreField(String id, String field);     // Firestore concept
  Future<QuerySnapshot> queryWorkoutsByDate(Timestamp date);      // Firestore type
}
```

---

## 4. Repository Pattern

### 4.1 Repository Implementation Rules

Repository implementations live in `data/repositories/` and:
- Implement exactly one domain repository interface
- Coordinate between remote and local data sources
- Apply the offline-first strategy (write local first, sync remote asynchronously)
- Catch all data-layer exceptions and convert them to `Failure` objects
- Never return raw models — always map to domain entities before returning

```dart
class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource _remote;
  final WorkoutLocalDataSource _local;
  final ConnectivityService _connectivity;

  const WorkoutRepositoryImpl({
    required WorkoutRemoteDataSource remote,
    required WorkoutLocalDataSource local,
    required ConnectivityService connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity;

  @override
  Future<Either<Failure, WorkoutSession>> completeWorkout(String workoutId) async {
    try {
      // 1. Read from local source — fast, offline-safe
      final model = await _local.getWorkout(workoutId);
      if (model == null) return Left(NotFoundFailure(resource: workoutId));

      // 2. Apply domain logic — completion timestamp, duration
      final completed = model.copyWith(
        completedAt: DateTime.now(),
        status: WorkoutStatus.completed,
      );

      // 3. Persist locally first — never block UI on network
      await _local.saveWorkout(completed);

      // 4. Sync to remote in background — fire and forget
      _syncToRemote(completed);

      // 5. Return domain entity — never the model
      return Right(WorkoutMapper.toDomain(completed));

    } on IsarException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Local write failed'));
    } on Exception catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  void _syncToRemote(WorkoutSessionModel model) async {
    try {
      if (!await _connectivity.isConnected) {
        await _local.markPendingSync(model.id);
        return;
      }
      await _remote.upsertWorkout(model);
    } catch (e) {
      await _local.markPendingSync(model.id);
      // Log to Crashlytics — non-fatal; local write already succeeded
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, fatal: false);
    }
  }
}
```

### 4.2 Data Source Interfaces

Data sources are split by storage backend. Each has an abstract interface so implementations are replaceable in tests.

```dart
// Remote data source — Firestore operations only
abstract class WorkoutRemoteDataSource {
  Future<void> upsertWorkout(WorkoutSessionModel model);
  Future<WorkoutSessionModel?> getWorkout(String id);
  Future<List<WorkoutSessionModel>> getWorkoutHistory({
    required int limit,
    required int offset,
    DateTime? from,
    DateTime? to,
  });
  Stream<WorkoutSessionModel?> watchActiveWorkout(String uid);
}

// Local data source — Isar operations only
abstract class WorkoutLocalDataSource {
  Future<void> saveWorkout(WorkoutSessionModel model);
  Future<WorkoutSessionModel?> getWorkout(String id);
  Future<List<WorkoutSessionModel>> getWorkoutHistory({...});
  Stream<WorkoutSessionModel?> watchActiveWorkout();
  Future<void> markPendingSync(String id);
  Future<List<String>> getPendingSyncIds();
}
```

### 4.3 Models and Mappers

Models are DTOs — they handle serialization. Mappers translate between models and entities. These two concerns are kept in separate files.

```dart
// data/models/workout_session_model.dart
// Models own all serialization logic — freezed + json_serializable

@freezed
class WorkoutSessionModel with _$WorkoutSessionModel {
  const factory WorkoutSessionModel({
    required String id,
    String? name,
    required DateTime startedAt,
    DateTime? completedAt,
    @Default(0.0) double totalVolumeKg,
    @Default([]) List<ExerciseLogModel> exerciseLogs,
    @Default(false) bool isDeleted,
    @Default(1) int schemaVersion,
  }) = _WorkoutSessionModel;

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionModelFromJson(json);
}
```

```dart
// data/mappers/workout_mapper.dart
// Mappers own zero business logic — pure translation

class WorkoutMapper {
  WorkoutMapper._(); // Non-instantiable utility class

  static WorkoutSession toDomain(WorkoutSessionModel model) {
    return WorkoutSession(
      id: model.id,
      name: model.name,
      startedAt: model.startedAt,
      completedAt: model.completedAt,
      totalVolumeKg: model.totalVolumeKg,
      exerciseLogs: model.exerciseLogs
          .map(ExerciseLogMapper.toDomain)
          .toList(),
    );
  }

  static WorkoutSessionModel toModel(WorkoutSession entity) {
    return WorkoutSessionModel(
      id: entity.id,
      name: entity.name,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      totalVolumeKg: entity.totalVolumeKg,
      exerciseLogs: entity.exerciseLogs
          .map(ExerciseLogMapper.toModel)
          .toList(),
    );
  }

  static Map<String, dynamic> toFirestore(WorkoutSessionModel model) {
    final json = model.toJson();
    // Convert DateTime → Firestore Timestamp
    json['startedAt'] = Timestamp.fromDate(model.startedAt);
    if (model.completedAt != null) {
      json['completedAt'] = Timestamp.fromDate(model.completedAt!);
    }
    return json;
  }

  static WorkoutSessionModel fromFirestore(Map<String, dynamic> data) {
    // Convert Firestore Timestamp → DateTime before passing to fromJson
    final normalized = Map<String, dynamic>.from(data);
    normalized['startedAt'] =
        (data['startedAt'] as Timestamp).toDate().toIso8601String();
    if (data['completedAt'] != null) {
      normalized['completedAt'] =
          (data['completedAt'] as Timestamp).toDate().toIso8601String();
    }
    return WorkoutSessionModel.fromJson(normalized);
  }
}
```

---

## 5. Riverpod State Management

### 5.1 Provider Rules

| Provider Type | Use When | Example |
|---|---|---|
| `@riverpod` (functional) | Derived/computed value; no mutation | `isPremiumProvider` |
| `@riverpod Notifier` | Synchronous state with mutation methods | `RestTimerNotifier` |
| `@riverpod AsyncNotifier` | Async initial load + mutation methods | `WorkoutHistoryNotifier` |
| `@riverpod StreamNotifier` | Firestore real-time stream + mutations | `ActiveWorkoutNotifier` |
| `@riverpod` (functional, Stream) | Read-only stream; no mutations | `authStateProvider` |

Always use code generation (`riverpod_annotation`). Hand-written providers are only permitted in `core/di/providers.dart` for infrastructure singletons.

### 5.2 Provider Placement

Providers live in `features/{feature}/presentation/providers/`. Infrastructure providers (Firebase instances, services) live in `core/di/providers.dart`.

```dart
// core/di/providers.dart — infrastructure only

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(FirestoreRef ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirestoreService firestoreService(FirestoreServiceRef ref) =>
    FirestoreService(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
WorkoutRepository workoutRepository(WorkoutRepositoryRef ref) =>
    WorkoutRepositoryImpl(
      remote: ref.watch(workoutRemoteDataSourceProvider),
      local: ref.watch(workoutLocalDataSourceProvider),
      connectivity: ref.watch(connectivityServiceProvider),
    );
```

### 5.3 AsyncNotifier Pattern

```dart
// features/workout/presentation/providers/workout_history_provider.dart

@riverpod
class WorkoutHistory extends _$WorkoutHistory {
  static const _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;
  final _items = <WorkoutSession>[];

  @override
  Future<List<WorkoutSession>> build() async {
    // Reset on rebuild
    _currentPage = 0;
    _hasMore = true;
    _items.clear();
    return _fetchPage();
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || state.isLoading) return;
    _currentPage++;
    state = const AsyncLoading<List<WorkoutSession>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetchPage());
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<List<WorkoutSession>> _fetchPage() async {
    final result = await ref
        .read(workoutRepositoryProvider)
        .getHistory(page: _currentPage, pageSize: _pageSize);

    return result.fold(
      (failure) => throw failure.toException(),
      (paginated) {
        _hasMore = paginated.hasMore;
        _items.addAll(paginated.items);
        return List.unmodifiable(_items);
      },
    );
  }
}
```

### 5.4 StreamNotifier Pattern

```dart
// features/workout/presentation/providers/active_workout_provider.dart

@riverpod
class ActiveWorkout extends _$ActiveWorkout {
  @override
  Stream<WorkoutSession?> build() {
    return ref
        .watch(workoutRepositoryProvider)
        .watchActiveWorkout()
        .map((either) => either.fold(
              (failure) => throw failure.toException(),
              (session) => session,
            ));
  }

  Future<void> logSet({
    required String exerciseLogId,
    required SetLog set,
  }) async {
    final current = state.value;
    if (current == null) return;

    final result = await ref.read(workoutRepositoryProvider).logSet(
          workoutId: current.id,
          exerciseLogId: exerciseLogId,
          set: set,
        );

    result.fold(
      (failure) => throw failure.toException(),
      (_) {}, // Stream automatically emits updated state
    );
  }

  Future<void> completeWorkout() async {
    final current = state.value;
    if (current == null) return;

    final result = await ref
        .read(workoutRepositoryProvider)
        .completeWorkout(current.id);

    result.fold(
      (failure) => throw failure.toException(),
      (_) {},
    );
  }
}
```

### 5.5 Consuming Providers in Widgets

```dart
// ✅ CORRECT — use .when() to handle all states
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);

    return historyAsync.when(
      loading: () => const WorkoutHistorySkeleton(),
      error: (error, _) => ErrorView(
        message: _mapToMessage(error),
        onRetry: () => ref.invalidate(workoutHistoryProvider),
      ),
      data: (sessions) => sessions.isEmpty
          ? const EmptyWorkoutHistory()
          : WorkoutHistoryList(
              sessions: sessions,
              onEndReached: () => ref
                  .read(workoutHistoryProvider.notifier)
                  .loadNextPage(),
            ),
    );
  }
}
```

```dart
// ❌ WRONG — accessing repository directly from a widget
class WorkoutHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Never access repositories from widgets
    final repo = ref.read(workoutRepositoryProvider);
    repo.getHistory(page: 0, pageSize: 20); // ← direct repository call in UI
    ...
  }
}
```

### 5.6 ref.watch vs ref.read

- `ref.watch(provider)` — use in `build()` methods and `build()` method of notifiers; rebuilds when value changes
- `ref.read(provider)` — use in event handlers, notifier methods, and one-time reads; does **not** subscribe
- `ref.listen(provider, callback)` — use when you need to react to state changes with side effects (navigation, showing a snackbar)

```dart
// ✅ CORRECT
@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProfileProvider);  // watch in build
  ...
}

void _onTap(WidgetRef ref) {
  ref.read(activeWorkoutProvider.notifier).logSet(...);  // read in handler
}
```

```dart
// ❌ WRONG
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.read(userProfileProvider);  // read in build won't rebuild
  ref.watch(activeWorkoutProvider.notifier).logSet(...);  // watch in handler
}
```

---

## 6. Feature Module Rules

### 6.1 Feature Independence

Features must not import from each other's internal layers. Communication between features happens through shared domain entities and the navigation layer.

```dart
// ✅ CORRECT — accessing a shared entity from another feature
import 'package:fitcore/features/workout/domain/entities/workout_session.dart';

// ✅ CORRECT — navigating to another feature via GoRouter
context.push(AppRoutes.nutrition);

// ❌ WRONG — importing another feature's internal data layer
import 'package:fitcore/features/nutrition/data/models/nutrition_log_model.dart';

// ❌ WRONG — importing another feature's provider
import 'package:fitcore/features/nutrition/presentation/providers/nutrition_provider.dart';
```

**Exception:** Shared domain entities used by multiple features live in `shared/models/` or in the consuming feature's domain layer if only two features need it. If more than two features share an entity, extract it to `core/domain/`.

### 6.2 Feature Registration

Each feature exposes its routes and DI overrides in a single `{feature}_module.dart` registration file at the feature root:

```dart
// features/workout/workout_module.dart

class WorkoutModule {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutes.workoutHistory,
      builder: (_, __) => const WorkoutHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.activeWorkout,
      builder: (_, __) => const ActiveWorkoutScreen(),
    ),
  ];
}
```

### 6.3 What Belongs in `shared/`

`shared/` contains:
- Generic UI components that are unaware of any feature (`PrimaryButton`, `SkeletonCard`, `MacroRing`, `ErrorView`)
- Generic models used by infrastructure (`PaginatedList<T>`, `Either` extensions)

`shared/` must not:
- Import from any `features/` directory
- Contain business logic
- Reference Firebase, Firestore, or Isar

---

## 7. Firestore Access Rules

### 7.1 The Access Chain

This chain is the single permitted path from intent to storage. No shortcuts.

```
Widget / Screen
     │  calls notifier method
     ▼
Riverpod Notifier
     │  calls use case
     ▼
Use Case
     │  calls repository interface
     ▼
Repository Implementation
     │  calls data source interface
     ▼
Remote Data Source Implementation
     │  calls FirestoreService
     ▼
FirestoreService
     │  calls FirebaseFirestore
     ▼
Firestore
```

### 7.2 FirestoreService Is the Only Firebase Firestore Entry Point

All Firestore operations go through `FirestoreService`. Direct usage of `FirebaseFirestore.instance` is only permitted inside `FirestoreService` itself.

```dart
// ✅ CORRECT — data source uses FirestoreService
class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final FirestoreService _firestore;
  final FirebaseAuthService _auth;

  const WorkoutRemoteDataSourceImpl(this._firestore, this._auth);

  @override
  Future<void> upsertWorkout(WorkoutSessionModel model) async {
    final uid = _auth.requireCurrentUid();
    await _firestore.setDocument(
      FirestorePaths.workout(uid, model.id),
      WorkoutMapper.toFirestore(model),
      merge: true,
    );
  }
}
```

```dart
// ❌ WRONG — data source bypasses FirestoreService
class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  @override
  Future<void> upsertWorkout(WorkoutSessionModel model) async {
    // Direct FirebaseFirestore usage outside FirestoreService
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(model.id)
        .set(model.toJson());
  }
}
```

### 7.3 Firestore Paths Are Constants

All Firestore collection and document paths are defined as static methods in `FirestorePaths`. String interpolation of paths outside this class is forbidden.

```dart
// core/constants/firestore_paths.dart

abstract final class FirestorePaths {
  static String user(String uid)                         => 'users/$uid';
  static String workoutsCollection(String uid)           => 'users/$uid/workouts';
  static String workout(String uid, String workoutId)    => 'users/$uid/workouts/$workoutId';
  static String personalRecord(String uid, String exId)  => 'users/$uid/personalRecords/$exId';
  static String nutritionSummary(String uid, String date)=> 'users/$uid/nutritionSummaries/$date';
  // ... all paths declared here
}
```

```dart
// ✅ CORRECT
await _firestore.setDocument(FirestorePaths.workout(uid, workoutId), data);

// ❌ WRONG — hardcoded path string in data source
await _firestore.setDocument('users/$uid/workouts/$workoutId', data);
```

### 7.4 No Real-Time Listeners in Repositories

Streams (real-time Firestore listeners) are set up at the data source level and exposed upward as `Stream<T>` through the repository interface. The repository converts `Stream<Model>` to `Stream<Either<Failure, Entity>>`. Notifiers subscribe via `StreamNotifier`.

```dart
// ✅ CORRECT stream chain

// data source
Stream<WorkoutSessionModel?> watchActiveWorkout(String uid) {
  return _firestore
      .documentStream(FirestorePaths.workoutsCollection(uid))  // wrapped
      .map((data) => data != null ? WorkoutMapper.fromFirestore(data) : null);
}

// repository
Stream<Either<Failure, WorkoutSession?>> watchActiveWorkout() {
  final uid = _auth.requireCurrentUid();
  return _remote
      .watchActiveWorkout(uid)
      .map<Either<Failure, WorkoutSession?>>((model) =>
          Right(model != null ? WorkoutMapper.toDomain(model) : null))
      .handleError((e) => Left(ErrorHandler.handle(e)));
}

// notifier
@override
Stream<WorkoutSession?> build() {
  return ref
      .watch(workoutRepositoryProvider)
      .watchActiveWorkout()
      .map((either) => either.fold((f) => throw f.toException(), id));
}
```

---

## 8. UI Layer Rules

### 8.1 Widgets Are Dumb

A widget's only jobs are:
1. Read state from Riverpod providers
2. Render that state as pixels
3. Forward user interactions to notifier methods

Widgets must not:
- Contain `if/else` business logic beyond display toggles
- Call use cases directly
- Call repositories directly
- Perform data transformations (do that in the notifier or use case)
- Know about Firestore, Isar, or any storage concept

### 8.2 Screen vs Widget Classification

| Type | Rule |
|---|---|
| **Screen** | Corresponds to a full-page route. Has `ConsumerWidget` or `ConsumerStatefulWidget`. Owns the `Scaffold`. Lives in `presentation/screens/`. |
| **Widget** | Reusable sub-component. Receives data via constructor parameters. May `watch` providers only if it is a complex self-contained widget that manages its own sub-state. |
| **Shared Widget** | In `shared/widgets/`. Receives all data via constructor. Zero provider dependencies. |

### 8.3 State Exposure

Pass domain entities (or simple value types derived from them) down the widget tree via constructors. Do not pass providers, notifiers, or `WidgetRef` down the tree.

```dart
// ✅ CORRECT — entity passed by value
class SetLogRow extends StatelessWidget {
  final SetLog set;
  final VoidCallback onComplete;

  const SetLogRow({super.key, required this.set, required this.onComplete});
}

// ❌ WRONG — WidgetRef passed down the tree
class SetLogRow extends StatelessWidget {
  final WidgetRef ref;  // Never pass WidgetRef as constructor parameter
  final String workoutId;
}
```

### 8.4 Loading and Error States

Every screen that reads an `AsyncValue` must handle all three states: `loading`, `error`, and `data`. Omitting any state is a lint error.

```dart
// ✅ CORRECT
ref.watch(workoutHistoryProvider).when(
  loading: () => const WorkoutHistorySkeleton(),
  error: (error, _) => ErrorView(
    message: _mapToMessage(error),
    onRetry: () => ref.invalidate(workoutHistoryProvider),
  ),
  data: (sessions) => WorkoutHistoryList(sessions: sessions),
);

// ❌ WRONG — ignoring loading and error
final sessions = ref.watch(workoutHistoryProvider).value ?? [];
```

### 8.5 Navigation

Use `GoRouter` via `context.push()`, `context.go()`, or `context.replace()`. Never push screens directly with `Navigator.of(context).push(MaterialPageRoute(...))`.

Route strings are constants in `AppRoutes`:

```dart
abstract final class AppRoutes {
  static const home            = '/';
  static const workoutHistory  = '/workout/history';
  static const activeWorkout   = '/workout/active';
  static const nutritionToday  = '/nutrition';
  static const subscription    = '/subscription';
}
```

---

## 9. Error Handling

### 9.1 The `Either<Failure, T>` Contract

Every method that can fail must return `Either<Failure, T>`. This is the contract enforced across all repository interfaces and use cases. The only exception is `Stream<Either<Failure, T>>` for real-time subscriptions.

```dart
// ✅ All of these are correct return types
Future<Either<Failure, WorkoutSession>> completeWorkout(String id);
Future<Either<Failure, Unit>> deleteWorkout(String id);
Future<Either<Failure, List<WorkoutSession>>> getHistory();
Stream<Either<Failure, WorkoutSession?>> watchActiveWorkout();

// ❌ Void returns hide errors; throwing across layers is forbidden
Future<void> completeWorkout(String id);  // How does the caller know it failed?
```

### 9.2 Failure Hierarchy

```dart
// core/error/failures.dart

sealed class Failure extends Equatable {
  final String message;
  final String? code;
  const Failure({required this.message, this.code});

  Exception toException() => FailureException(this);

  @override
  List<Object?> get props => [message, code];
}

final class NetworkFailure    extends Failure { ... }
final class ServerFailure     extends Failure { ... }
final class NotFoundFailure   extends Failure { ... }
final class AuthFailure       extends Failure { ... }
final class CacheFailure      extends Failure { ... }
final class ValidationFailure extends Failure { ... }
final class SubscriptionFailure extends Failure { ... }
```

### 9.3 Mapping Failures to User Messages

The UI layer converts `Failure` objects to human-readable strings. This mapping lives in presentation layer extension methods or view models — never hardcoded in widgets:

```dart
// shared/extensions/failure_ext.dart

extension FailureMessage on Failure {
  String toUserMessage() => switch (this) {
    NetworkFailure()     => 'Check your connection and try again.',
    NotFoundFailure()    => 'This item could not be found.',
    AuthFailure()        => 'Please sign in again.',
    CacheFailure()       => 'Something went wrong with local storage.',
    ServerFailure()      => 'Server error. Please try again shortly.',
    ValidationFailure()  => message,  // Validation messages are user-facing
    SubscriptionFailure()=> 'This feature requires a Premium subscription.',
    _                    => 'An unexpected error occurred.',
  };
}
```

### 9.4 Where Exceptions Are Caught

Exceptions from external libraries (Firebase, Isar, Dio) are caught **only** in the data layer — specifically in repository implementations. They are immediately converted to `Failure` objects. No `try/catch` blocks belong in use cases, notifiers, or widgets.

```
External SDK throws → Repository implementation catches → Returns Left(Failure) → Never propagates up
```

---

## 10. Naming Conventions

### 10.1 Files and Directories

| Artifact | Convention | Example |
|---|---|---|
| All files | `snake_case.dart` | `workout_session.dart` |
| Feature directories | `snake_case` | `features/body_metrics/` |
| Generated files | `*.g.dart`, `*.freezed.dart` | `workout_session.g.dart` |

### 10.2 Classes and Types

| Artifact | Convention | Example |
|---|---|---|
| Classes, enums, typedefs | `PascalCase` | `WorkoutSession` |
| Domain entities | Noun | `WorkoutSession`, `ExerciseLog` |
| Use cases | Verb + Noun + `UseCase` | `CompleteWorkoutUseCase` |
| Repository interfaces | Noun + `Repository` | `WorkoutRepository` |
| Repository implementations | Interface name + `Impl` | `WorkoutRepositoryImpl` |
| Data sources | Noun + `Remote/Local` + `DataSource` | `WorkoutRemoteDataSource` |
| Data source implementations | Interface name + `Impl` | `WorkoutRemoteDataSourceImpl` |
| DTOs / Models | Entity name + `Model` | `WorkoutSessionModel` |
| Mappers | Entity name + `Mapper` | `WorkoutMapper` |
| Screens | Feature + screen role + `Screen` | `WorkoutHistoryScreen` |
| Notifiers | Feature + role (no suffix) | `ActiveWorkout`, `WorkoutHistory` |
| Failures | Descriptive + `Failure` | `NotFoundFailure`, `NetworkFailure` |

### 10.3 Variables and Methods

| Artifact | Convention | Example |
|---|---|---|
| Variables, parameters | `camelCase` | `workoutId`, `totalVolumeKg` |
| Private fields | `_camelCase` | `_repository`, `_connectivity` |
| Constants | `camelCase` (in `abstract final class`) | `AppConstants.maxPhotoCount` |
| Booleans | Prefixed `is`, `has`, `can`, `should` | `isActive`, `hasMore`, `canDelete` |
| Async methods | Named for what they return/do, not how | `getHistory()` not `fetchHistoryFromFirestore()` |
| Stream methods | `watch` prefix | `watchActiveWorkout()` |
| Void side-effect methods | Verb prefix | `logSet()`, `completeWorkout()` |

### 10.4 Riverpod Providers

Providers are named after the state they hold, in `camelCase`, with the `Provider` suffix dropped (Riverpod codegen handles this):

```dart
// The annotation class name becomes the provider name:

@riverpod
class WorkoutHistory extends _$WorkoutHistory { ... }
// Provider: workoutHistoryProvider

@riverpod
class ActiveWorkout extends _$ActiveWorkout { ... }
// Provider: activeWorkoutProvider

@riverpod
bool isPremium(IsPremiumRef ref) { ... }
// Provider: isPremiumProvider
```

---

## 11. Code Style

### 11.1 `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
    dead_code: warning
    unused_import: error
    unused_local_variable: warning

linter:
  rules:
    # Style
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_fields: true
    prefer_final_locals: true
    avoid_print: true
    use_super_parameters: true

    # Safety
    always_declare_return_types: true
    avoid_dynamic_calls: true
    avoid_returning_null_for_future: true
    avoid_void_async: true
    cancel_subscriptions: true
    close_sinks: true
    unawaited_futures: true

    # Architecture enforcement
    avoid_relative_lib_imports: false  # Relative imports within features are fine
    directives_ordering: true
```

### 11.2 Import Ordering

Imports are grouped and sorted in this order, separated by blank lines:

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:io';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. External packages (alphabetical)
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 4. Internal — core
import 'package:fitcore/core/error/failures.dart';
import 'package:fitcore/core/di/providers.dart';

// 5. Internal — features (alphabetical by feature)
import 'package:fitcore/features/workout/domain/entities/workout_session.dart';

// 6. Relative imports within the same feature
import '../entities/set_log.dart';
```

### 11.3 Line Length and Formatting

- Maximum line length: **100 characters**
- All code must be formatted with `dart format` before commit (enforced by CI)
- Trailing commas on all multiline argument lists and collection literals (enables cleaner diffs)

```dart
// ✅ CORRECT — trailing comma enables dart format to expand vertically
final result = WorkoutSession(
  id: workoutId,
  name: name,
  startedAt: DateTime.now(),
  exerciseLogs: const [],
);

// ❌ WRONG — no trailing comma; dart format leaves it on one line
final result = WorkoutSession(id: workoutId, name: name, startedAt: DateTime.now(), exerciseLogs: const []);
```

### 11.4 `const` Usage

Use `const` wherever the compiler allows it. Const constructors eliminate rebuild overhead.

```dart
// ✅ Widgets with no dynamic state use const constructors
class EmptyWorkoutHistory extends StatelessWidget {
  const EmptyWorkoutHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No workouts yet. Start your first one!'),
    );
  }
}
```

### 11.5 Documentation Comments

Public APIs in `domain/` and `core/` require doc comments. Implementation details in `data/` and `presentation/` are commented only when the reasoning is non-obvious.

```dart
/// Returns the estimated one-rep maximum using the Epley formula.
///
/// Formula: `weight × (1 + reps / 30)`
///
/// Accuracy degrades below 3 reps and above 10 reps. For sets at 1 rep,
/// [weightKg] is returned as-is (it is the 1RM by definition).
double estimateOneRepMax(double weightKg, int reps) {
  if (reps <= 1) return weightKg;
  return weightKg * (1 + reps / 30);
}
```

Use inline comments sparingly. If you need a comment to explain *what* the code does, rewrite the code. If you need a comment to explain *why*, write it.

### 11.6 Magic Numbers

No magic numbers anywhere. All numeric constants have named declarations:

```dart
// ❌ WRONG
if (photos.length >= 10) showPaywall();

// ✅ CORRECT
abstract final class FreeTrialLimits {
  static const int maxProgressPhotos = 10;
  static const int maxEnrolledPrograms = 3;
}

if (photos.length >= FreeTrialLimits.maxProgressPhotos) showPaywall();
```

---

## 12. Testing Standards

### 12.1 Test Coverage Requirements

| Layer | Minimum Coverage | Testing Tool |
|---|---|---|
| Domain (entities, use cases) | 90% | `flutter_test` + `mockito` |
| Data (repositories, mappers) | 80% | `flutter_test` + fake datasources |
| Presentation (notifiers) | 70% | `flutter_test` + `ProviderContainer` |
| Widgets (screens) | Key flows | `flutter_test` golden + interaction |

### 12.2 Test File Location

Tests mirror the `lib/` directory structure under `test/`:

```
test/
├── unit/
│   └── features/
│       └── workout/
│           ├── domain/
│           │   ├── entities/workout_session_test.dart
│           │   └── usecases/complete_workout_usecase_test.dart
│           └── data/
│               ├── mappers/workout_mapper_test.dart
│               └── repositories/workout_repository_impl_test.dart
├── widget/
│   └── features/
│       └── workout/
│           ├── screens/workout_history_screen_test.dart
│           └── widgets/set_log_row_test.dart
└── integration/
    └── workout_logging_flow_test.dart
```

### 12.3 Use Fake Implementations, Not Mocks for Data Sources

Fake data sources provide a realistic in-memory implementation. Mocks verify call counts. Use fakes for integration-style repository tests; use mocks for verifying that a use case calls the right repository method.

```dart
// test/fakes/fake_workout_local_datasource.dart

class FakeWorkoutLocalDataSource implements WorkoutLocalDataSource {
  final _store = <String, WorkoutSessionModel>{};
  final _pendingSync = <String>{};

  @override
  Future<void> saveWorkout(WorkoutSessionModel model) async {
    _store[model.id] = model;
  }

  @override
  Future<WorkoutSessionModel?> getWorkout(String id) async => _store[id];

  @override
  Future<void> markPendingSync(String id) async => _pendingSync.add(id);

  @override
  Future<List<String>> getPendingSyncIds() async => _pendingSync.toList();
}
```

### 12.4 Repository Test Template

```dart
void main() {
  late WorkoutRepositoryImpl sut;
  late FakeWorkoutRemoteDataSource fakeRemote;
  late FakeWorkoutLocalDataSource fakeLocal;
  late MockConnectivityService mockConnectivity;

  setUp(() {
    fakeRemote = FakeWorkoutRemoteDataSource();
    fakeLocal = FakeWorkoutLocalDataSource();
    mockConnectivity = MockConnectivityService();
    sut = WorkoutRepositoryImpl(
      remote: fakeRemote,
      local: fakeLocal,
      connectivity: mockConnectivity,
    );
  });

  group('completeWorkout', () {
    test('persists locally even when offline', () async {
      when(mockConnectivity.isConnected).thenAnswer((_) async => false);
      await fakeLocal.saveWorkout(WorkoutFixtures.activeWorkout);

      final result = await sut.completeWorkout(WorkoutFixtures.activeWorkout.id);

      expect(result.isRight(), isTrue);
      final saved = await fakeLocal.getWorkout(WorkoutFixtures.activeWorkout.id);
      expect(saved!.status, WorkoutStatus.completed);
      expect(fakeRemote.upsertCallCount, 0);  // No remote write when offline
    });

    test('returns NotFoundFailure when workout does not exist', () async {
      final result = await sut.completeWorkout('nonexistent_id');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}
```

---

## 13. Git Workflow

### 13.1 Branch Naming

```
feature/{ticket-id}-short-description     # New feature work
fix/{ticket-id}-short-description         # Bug fix
refactor/{ticket-id}-short-description    # Refactoring without behavior change
chore/{ticket-id}-short-description       # Tooling, deps, CI
docs/{ticket-id}-short-description        # Documentation only
```

Examples:
- `feature/FC-142-workout-rest-timer`
- `fix/FC-188-ios-background-gps-crash`
- `refactor/FC-201-nutrition-repository-offline-first`

### 13.2 Commit Message Format

Follow Conventional Commits:

```
<type>(<scope>): <short summary>

[optional body — what and why, not how]

[optional footer — breaking changes, issue references]
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`  
Scope: feature name or layer (`workout`, `nutrition`, `core`, `auth`)

Examples:
```
feat(workout): add RPE field to set log row

Adds an optional RPE (Rate of Perceived Exertion) input per set.
Field is gated behind the premium entitlement check in the repository layer.

Closes FC-142
```

```
fix(auth): handle Apple Sign-In cancellation without crash

Apple returns an error code when the user cancels the sheet.
Previously this caused an unhandled exception in the auth notifier.
```

### 13.3 Pull Request Requirements

A PR is not mergeable until:

- [ ] All CI checks pass (lint, format, tests, build)
- [ ] Test coverage has not decreased
- [ ] At least one reviewer has approved
- [ ] All conversations are resolved
- [ ] No TODOs added without a corresponding ticket reference (`// TODO(FC-999):`)
- [ ] Generated files (`*.g.dart`, `*.freezed.dart`) are committed and up to date
- [ ] `CHANGELOG.md` updated if the change is user-facing

---

## 14. Anti-Patterns Catalog

The following patterns are explicitly forbidden. Any PR containing them will be rejected.

### AP-01 — Business Logic in Widgets

```dart
// ❌ FORBIDDEN
class NutritionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(nutritionLogsProvider).value ?? [];
    // Business logic in build method
    final totalCalories = logs.fold(0.0, (sum, log) => sum + log.caloriesKcal);
    final deficit = 2500 - totalCalories;
    final isOnTrack = deficit.abs() < 200;
    ...
  }
}
```

**Fix:** Move `totalCalories`, `deficit`, and `isOnTrack` into a derived provider or the notifier's state object.

---

### AP-02 — Firebase in Presentation

```dart
// ❌ FORBIDDEN
class ActiveWorkoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance  // Firebase in widget!
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .snapshots(),
      ...
    );
  }
}
```

**Fix:** Use a `StreamNotifier` backed by the repository's `watchActiveWorkout()` stream.

---

### AP-03 — Raw Exception Thrown Across Layer Boundaries

```dart
// ❌ FORBIDDEN
class WorkoutRepositoryImpl implements WorkoutRepository {
  @override
  Future<WorkoutSession> completeWorkout(String id) async {
    // Throws FirebaseException across the boundary — presentation must catch Firebase types
    final doc = await FirebaseFirestore.instance.doc(path).get();
    return WorkoutMapper.fromFirestore(doc.data()!);
  }
}
```

**Fix:** Return `Either<Failure, WorkoutSession>` and catch the `FirebaseException` inside the repository.

---

### AP-04 — Hardcoded Firestore Path Strings

```dart
// ❌ FORBIDDEN
await db.collection('users').doc(uid).collection('workouts').doc(id).set(data);
await db.doc('users/$uid/workouts/$id').set(data);
```

**Fix:** Use `FirestorePaths.workout(uid, id)`.

---

### AP-05 — Model Used as Domain Entity

```dart
// ❌ FORBIDDEN — model passed to widget
class WorkoutCard extends StatelessWidget {
  final WorkoutSessionModel workout;  // Model in presentation layer
  ...
}
```

**Fix:** Map to `WorkoutSession` entity in the repository. Pass `WorkoutSession` to the widget.

---

### AP-06 — Multiple Responsibilities in a Use Case

```dart
// ❌ FORBIDDEN
class WorkoutUseCase {
  Future<Either<Failure, WorkoutSession>> startWorkout() { ... }
  Future<Either<Failure, WorkoutSession>> completeWorkout(String id) { ... }
  Future<Either<Failure, List<WorkoutSession>>> getHistory() { ... }
}
```

**Fix:** One class per use case: `StartWorkoutUseCase`, `CompleteWorkoutUseCase`, `GetWorkoutHistoryUseCase`.

---

### AP-07 — Direct Repository Access in a Widget

```dart
// ❌ FORBIDDEN
class WorkoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = await ref.read(workoutRepositoryProvider).getHistory();
    ...
  }
}
```

**Fix:** Call `ref.read(workoutHistoryProvider.notifier).loadNextPage()` and read state via `ref.watch(workoutHistoryProvider)`.

---

### AP-08 — `ref.watch` Inside an Event Handler

```dart
// ❌ FORBIDDEN
void _onSavePressed(WidgetRef ref) {
  ref.watch(userProfileProvider);  // watch creates a subscription, not a one-time read
}
```

**Fix:** Use `ref.read(userProfileProvider)` inside event handlers.

---

### AP-09 — Nullable Return Instead of `Either`

```dart
// ❌ FORBIDDEN
abstract class WorkoutRepository {
  Future<WorkoutSession?> getWorkout(String id);  // null = not found OR error? Ambiguous.
}
```

**Fix:** `Future<Either<Failure, WorkoutSession?>>` where `Right(null)` = not found, `Left(failure)` = error.

---

### AP-10 — Stateful Logic in `StatefulWidget`

If a widget needs state that persists across rebuilds and is not purely ephemeral animation state, that state belongs in a Riverpod notifier — not `setState`.

```dart
// ❌ FORBIDDEN for business state
class ActiveWorkoutScreen extends StatefulWidget {
  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  List<SetLog> _sets = [];       // Business state in widget
  double _totalVolume = 0.0;     // Derived value in widget

  void _addSet(SetLog set) {
    setState(() {
      _sets.add(set);
      _totalVolume += set.weightKg * set.reps;  // Business logic in widget
    });
  }
}
```

**Fix:** Move `_sets` and `_totalVolume` to `ActiveWorkoutNotifier`. `StatefulWidget` is permitted only for animation controllers, scroll controllers, focus nodes, and other purely visual ephemeral state.

---

*These guidelines are living documentation. Propose changes via PR to `docs/coding_guidelines.md`. Breaking changes to guidelines require team consensus and a migration period of at least one sprint.*
