import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

// ─── Exercise ─────────────────────────────────────────────────────────────────
// Mirrors Firestore: exercises/{exerciseId}

class Exercise {
  final String id;
  final String name;
  final String
      category; // chest | back | shoulders | arms | core | legs | full_body | mobility
  final String mechanics; // compound | isolation
  final String force; // push | pull | static_hold | hinge | carry
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String equipment;
  final String difficulty; // beginner | intermediate | advanced | elite
  final String defaultSetType; // reps | timed | amrap
  final bool isSkillExercise;
  final ProgressionChain progression;
  final String description;
  final List<String> instructions;
  final List<String> tips;
  final List<String> commonMistakes;
  final PersonalRecord? pr;
  final List<Color> colors; // gradient pair for card backgrounds
  final Color accent;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.mechanics,
    required this.force,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.defaultSetType,
    this.isSkillExercise = false,
    required this.progression,
    required this.description,
    required this.instructions,
    required this.tips,
    required this.commonMistakes,
    this.pr,
    required this.colors,
    required this.accent,
  });

  // Construct from Firestore document map
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      mechanics: map['mechanics'] as String,
      force: map['force'] as String,
      primaryMuscles: List<String>.from(map['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(map['secondaryMuscles'] ?? []),
      equipment: map['equipment'] as String,
      difficulty: map['difficulty'] as String,
      defaultSetType: map['defaultSetType'] as String,
      isSkillExercise: map['isSkillExercise'] as bool? ?? false,
      progression: ProgressionChain.fromMap(map['progressionChain'] ?? {}),
      description: map['description'] as String? ?? '',
      instructions: List<String>.from(map['instructions'] ?? []),
      tips: List<String>.from(map['tips'] ?? []),
      commonMistakes: List<String>.from(map['commonMistakes'] ?? []),
      pr: map['pr'] != null ? PersonalRecord.fromMap(map['pr']) : null,
      colors: _parseColors(map['colors']),
      accent: _parseColor(map['accent'], AppColors.brand),
    );
  }

  static List<Color> _parseColors(dynamic raw) {
    if (raw is List && raw.length >= 2) {
      return [
        _parseColor(raw[0], AppColors.card),
        _parseColor(raw[1], AppColors.elevated)
      ];
    }
    return [AppColors.card, AppColors.elevated];
  }

  static Color _parseColor(dynamic raw, Color fallback) {
    if (raw is String && raw.startsWith('#')) {
      final hex = raw.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    return fallback;
  }

  Color get difficultyColor => AppColors.difficultyColor(difficulty);

  String get setTypeLabel {
    switch (defaultSetType) {
      case 'timed':
        return 'Timed Hold';
      case 'amrap':
        return 'AMRAP';
      default:
        return 'Rep Based';
    }
  }
}

class ProgressionChain {
  final String? prev;
  final String? next; // exercise id

  const ProgressionChain({this.prev, this.next});

  factory ProgressionChain.fromMap(Map<String, dynamic> map) {
    return ProgressionChain(
      prev: map['prev'] as String?,
      next: map['next'] as String?,
    );
  }
}

// ─── Personal Record ─────────────────────────────────────────────────────────
class PersonalRecord {
  final int? bestReps;
  final double? bestHoldSeconds;
  final double? bestWeightKg;

  const PersonalRecord(
      {this.bestReps, this.bestHoldSeconds, this.bestWeightKg});

  factory PersonalRecord.fromMap(Map<String, dynamic> map) {
    return PersonalRecord(
      bestReps: map['reps'] as int?,
      bestHoldSeconds: (map['hold'] as num?)?.toDouble(),
      bestWeightKg: (map['weight'] as num?)?.toDouble(),
    );
  }

  String get primaryDisplay {
    if (bestHoldSeconds != null) {
      return '${bestHoldSeconds!.toStringAsFixed(1)}s';
    }
    if (bestReps != null) return '$bestReps reps';
    if (bestWeightKg != null) return '+${bestWeightKg}kg';
    return '—';
  }
}

// ─── Exercise Category ────────────────────────────────────────────────────────
// Drives the Library grid — the count and display colour come from the DB
// so this is kept lightweight; screens will populate it dynamically.

class ExerciseCategory {
  final String id;
  final String name;
  final String tag;
  final int exerciseCount;
  final List<Color> colors;
  final Color accent;

  const ExerciseCategory({
    required this.id,
    required this.name,
    required this.tag,
    required this.exerciseCount,
    required this.colors,
    required this.accent,
  });

  factory ExerciseCategory.fromMap(Map<String, dynamic> map) {
    return ExerciseCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      tag: map['tag'] as String,
      exerciseCount: map['count'] as int? ?? 0,
      colors: Exercise._parseColors(map['colors']),
      accent: Exercise._parseColor(map['accent'], AppColors.brand),
    );
  }
}

// ─── Skill ────────────────────────────────────────────────────────────────────
class Skill {
  final String name;
  final String family; // push | pull | core | rings
  final String currentTier; // display label e.g. "Tuck"
  final String nextTier; // e.g. "Advanced Tuck"
  final int tierIndex; // 0-based current tier
  final int totalTiers;
  final String? bestDisplay; // "8s" | "12 reps" | null
  final String target;
  final int progressPct; // 0-100
  final List<Color> colors;
  final Color accent;
  final SkillStatus status;
  final bool isStaticHold;
  final List<String> instructions;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;

  const Skill({
    required this.name,
    required this.family,
    required this.currentTier,
    required this.nextTier,
    required this.tierIndex,
    required this.totalTiers,
    this.bestDisplay,
    required this.target,
    required this.progressPct,
    required this.colors,
    required this.accent,
    required this.status,
    required this.isStaticHold,
    required this.instructions,
    required this.primaryMuscles,
    required this.secondaryMuscles,
  });

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] as String,
      family: map['family'] as String,
      currentTier: map['currentTier'] as String,
      nextTier: map['nextTier'] as String,
      tierIndex: map['tierIndex'] as int,
      totalTiers: map['totalTiers'] as int,
      bestDisplay: map['bestDisplay'] as String?,
      target: map['target'] as String,
      progressPct: map['progressPct'] as int,
      colors: Exercise._parseColors(map['colors']),
      accent: Exercise._parseColor(map['accent'], AppColors.brand),
      status: SkillStatus.fromString(map['status'] as String? ?? 'active'),
      isStaticHold: map['isStaticHold'] as bool? ?? false,
      instructions: List<String>.from(map['instructions'] ?? []),
      primaryMuscles: List<String>.from(map['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(map['secondaryMuscles'] ?? []),
    );
  }
}

enum SkillStatus {
  active,
  started,
  locked,
  mastered;

  static SkillStatus fromString(String s) {
    switch (s) {
      case 'started':
        return started;
      case 'locked':
        return locked;
      case 'mastered':
        return mastered;
      default:
        return active;
    }
  }
}

// ─── Workout ──────────────────────────────────────────────────────────────────
class Workout {
  final String id;
  final String name;
  final String duration; // "45 min"
  final int exerciseCount;
  final List<String> muscles;
  final String level;
  final List<Color> colors;
  final Color accent;
  final WorkoutCategory category;

  const Workout({
    required this.id,
    required this.name,
    required this.duration,
    required this.exerciseCount,
    required this.muscles,
    required this.level,
    required this.colors,
    required this.accent,
    required this.category,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      name: map['name'] as String,
      duration: map['duration'] as String,
      exerciseCount: map['exerciseCount'] as int,
      muscles: List<String>.from(map['muscles'] ?? []),
      level: map['level'] as String,
      colors: Exercise._parseColors(map['colors']),
      accent: Exercise._parseColor(map['accent'], AppColors.brand),
      category:
          WorkoutCategory.fromString(map['category'] as String? ?? 'strength'),
    );
  }
}

enum WorkoutCategory {
  all,
  strength,
  skill,
  mobility,
  rings;

  static WorkoutCategory fromString(String s) {
    switch (s) {
      case 'strength':
        return strength;
      case 'skill':
        return skill;
      case 'mobility':
        return mobility;
      case 'rings':
        return rings;
      default:
        return all;
    }
  }
}

// ─── Active Program ───────────────────────────────────────────────────────────
class ActiveProgram {
  final String id;
  final String name;
  final int currentWeek;
  final int totalWeeks;
  final int currentDay;
  final int totalDays;
  final int adherencePct;
  final List<Color> colors;
  final Color accent;
  final String level;

  const ActiveProgram({
    required this.id,
    required this.name,
    required this.currentWeek,
    required this.totalWeeks,
    required this.currentDay,
    required this.totalDays,
    required this.adherencePct,
    required this.colors,
    required this.accent,
    required this.level,
  });

  factory ActiveProgram.fromMap(Map<String, dynamic> map) {
    return ActiveProgram(
      id: map['id'] as String,
      name: map['name'] as String,
      currentWeek: map['currentWeek'] as int,
      totalWeeks: map['totalWeeks'] as int,
      currentDay: map['currentDay'] as int,
      totalDays: map['totalDays'] as int,
      adherencePct: map['adherencePct'] as int,
      colors: Exercise._parseColors(map['colors']),
      accent: Exercise._parseColor(map['accent'], AppColors.brand),
      level: map['level'] as String,
    );
  }
}

// ─── Recent Workout (activity feed) ──────────────────────────────────────────
class RecentWorkout {
  final String id;
  final String name;
  final String dateLabel; // "Yesterday", "2 days ago"
  final int setCount;
  final String duration;
  final bool isSkillSession;
  final Color bgColor;
  final Color accent;

  const RecentWorkout({
    required this.id,
    required this.name,
    required this.dateLabel,
    required this.setCount,
    required this.duration,
    this.isSkillSession = false,
    required this.bgColor,
    required this.accent,
  });

  factory RecentWorkout.fromMap(Map<String, dynamic> map) {
    return RecentWorkout(
      id: map['id'] as String,
      name: map['name'] as String,
      dateLabel: map['dateLabel'] as String,
      setCount: map['setCount'] as int,
      duration: map['duration'] as String,
      isSkillSession: map['isSkillSession'] as bool? ?? false,
      bgColor: Exercise._parseColor(map['bgColor'], AppColors.card),
      accent: Exercise._parseColor(map['accent'], AppColors.brand),
    );
  }
}

// ─── Progress / Analytics ─────────────────────────────────────────────────────
class WeekDay {
  final String label; // "M","T","W"…
  final bool completed;

  const WeekDay({required this.label, required this.completed});
}

class MuscleStat {
  final String name;
  final int pct;

  const MuscleStat({required this.name, required this.pct});
}

class SkillTrend {
  final String skillName;
  final List<double> values;
  final String unit;
  final Color color;

  const SkillTrend({
    required this.skillName,
    required this.values,
    required this.unit,
    required this.color,
  });

  double get latest => values.isNotEmpty ? values.last : 0;
  double get gain => values.length > 1 ? values.last - values.first : 0;
}

// ─── User Profile ─────────────────────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final int level;
  final String levelTitle; // "Bar Warrior"
  final int currentXp;
  final int xpToNextLevel;
  final int workoutCount;
  final int streakDays;
  final int activeSkills;
  final int prCount;
  final bool isPremium;
  final String? bio;
  final List<Achievement> achievements;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    required this.level,
    required this.levelTitle,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.workoutCount,
    required this.streakDays,
    required this.activeSkills,
    required this.prCount,
    required this.isPremium,
    this.bio,
    this.achievements = const [],
  });

  double get xpProgress => xpToNextLevel > 0 ? currentXp / xpToNextLevel : 0;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      level: map['level'] as int,
      levelTitle: map['levelTitle'] as String,
      currentXp: map['currentXp'] as int,
      xpToNextLevel: map['xpToNextLevel'] as int,
      workoutCount: map['workoutCount'] as int,
      streakDays: map['streakDays'] as int,
      activeSkills: map['activeSkills'] as int,
      prCount: map['prCount'] as int,
      isPremium: map['isPremium'] as bool? ?? false,
      bio: map['bio'] as String?,
      achievements: (map['achievements'] as List<dynamic>?)
              ?.map((a) => Achievement.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Achievement {
  final String id;
  final String emoji;
  final String name;
  final bool isEarned;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.name,
    required this.isEarned,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      emoji: map['emoji'] as String,
      name: map['name'] as String,
      isEarned: map['isEarned'] as bool? ?? false,
    );
  }
}

// ─── PR Board entry ───────────────────────────────────────────────────────────
class PrEntry {
  final String exerciseName;
  final String valueDisplay; // "15 reps" | "10s" | "+20 kg"
  final Color accent;

  const PrEntry({
    required this.exerciseName,
    required this.valueDisplay,
    required this.accent,
  });

  factory PrEntry.fromMap(Map<String, dynamic> map) {
    return PrEntry(
      exerciseName: map['exerciseName'] as String,
      valueDisplay: map['valueDisplay'] as String,
      accent: Exercise._parseColor(map['accent'], AppColors.brand),
    );
  }
}
