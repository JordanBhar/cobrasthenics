import 'package:flutter/material.dart';

import '../features/dashboard/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/skill/presentation/skills_screen.dart';
import '../features/workout/presentation/screens/exercise_detail_screen.dart';
import '../features/workout/presentation/screens/library_screen.dart';
import '../features/workout/presentation/screens/train_screen.dart';
import '../shared/models/models.dart';
import 'theme/app_theme.dart';

class CobrasthenicsApp extends StatelessWidget {
  const CobrasthenicsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cobrasthenics',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const CobrasthenicsShell(),
      );
}

// ─── CobrasthenicsShell ─────────────────────────────────────────────────────────
// Bottom-nav shell that owns top-level tab state.
// Each tab receives its data from a "provider" / service layer that you wire up
// (Riverpod, Provider, BLoC — this file is agnostic to that choice).
// Replace the placeholder _DataProvider calls with real async sources.

class CobrasthenicsShell extends StatefulWidget {
  const CobrasthenicsShell({super.key});

  @override
  State<CobrasthenicsShell> createState() => _CobrasthenicsShellState();
}

class _CobrasthenicsShellState extends State<CobrasthenicsShell> {
  int _tab = 0;

  // ── Navigation for Library drill-through ────────────────────────────────────
  ExerciseCategory? _selectedCategory;
  // Navigate to category exercise list
  void _openCategory(ExerciseCategory cat) =>
      setState(() => _selectedCategory = cat);
  // Navigate back to category grid
  void _closeCategory() => setState(() => _selectedCategory = null);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _tab,
            children: [
              // ── HOME ────────────────────────────────────────────────────────────
              HomeScreen(
                user: _sampleUser,
                weekDays: _sampleWeekDays,
                activeProgram: _sampleProgram,
                featuredSkill: _sampleSkills.first,
                recentWorkouts: _sampleRecent,
                streakDays: 14,
              ),

              // ── TRAIN ───────────────────────────────────────────────────────────
              const TrainScreen(
                activeProgram: _sampleProgram,
                workouts: _sampleWorkouts,
              ),

              // ── LIBRARY ─────────────────────────────────────────────────────────
              // 2-level navigation: grid → category list.
              // A real app would use Navigator / GoRouter here.
              _selectedCategory == null
                  ? LibraryScreen(
                      categories: _sampleCategories,
                      onCategoryTap: _openCategory,
                    )
                  : CategoryScreen(
                      category: _selectedCategory!,
                      exercises: _sampleExercisesFor(_selectedCategory!.id),
                      onBack: _closeCategory,
                      onExerciseTap: (ex) {
                        // Push ExerciseDetailScreen via navigator
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(
                              exercise: ex,
                              history: const [],
                            ),
                          ),
                        );
                      },
                    ),

              // ── SKILLS ──────────────────────────────────────────────────────────
              SkillsScreen(
                skills: _sampleSkills,
                onSkillTap: (skill) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SkillDetailScreen(skill: skill, history: const [
                        SkillSessionEntry(
                            dateLabel: 'Today',
                            valueDisplay: '8.2s',
                            isPr: true),
                        SkillSessionEntry(
                            dateLabel: 'May 12', valueDisplay: '7.1s'),
                        SkillSessionEntry(
                            dateLabel: 'May 10', valueDisplay: '6.8s'),
                        SkillSessionEntry(
                            dateLabel: 'May 8', valueDisplay: '5.5s'),
                        SkillSessionEntry(
                            dateLabel: 'May 6', valueDisplay: '4.9s'),
                      ]),
                    ),
                  );
                },
              ),

              // ── PROFILE / PROGRESS ───────────────────────────────────────────────
              ProfileScreen(
                user: _sampleUser,
                settingGroups: _sampleSettingGroups,
                heatmapGrid: _sampleHeatmap,
                weeklyVolume: const [18, 24, 20, 31, 28, 35, 30],
                personalRecords: _samplePRs,
                muscleBreakdown: _sampleMuscles,
                skillTrends: _sampleTrends,
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNav(
            current: _tab,
            onSelect: (i) => setState(() {
                  _tab = i;
                  // Reset library drill-down when tab is tapped again
                  if (i == 2) _selectedCategory = null;
                })),
      );
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onSelect;

  const _BottomNav({required this.current, required this.onSelect});

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.calendar_month_rounded, label: 'Train'),
    (icon: Icons.menu_book_rounded, label: 'Library'),
    (icon: Icons.auto_graph_rounded, label: 'Skills'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xF00A0A0A),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              children: _tabs.asMap().entries.map((e) {
                final i = e.key;
                final tab = e.value;
                final on = i == current;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: on ? AppColors.brandDim : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            tab.icon,
                            size: 22,
                            color: on ? AppColors.brand : AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: AppTextStyles.caption.copyWith(
                            color: on ? AppColors.brand : AppColors.textHint,
                            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
}

// ─── Sample data ─────────────────────────────────────────────────────────────
// This is PLACEHOLDER data only — replace every reference here with your actual
// Firestore / Riverpod / BLoC data sources.
// The screens themselves contain zero hardcoded data.

const _sampleUser = UserProfile(
  uid: 'sample-uid',
  displayName: 'Jordan Bhar',
  username: 'alexcarter',
  level: 12,
  levelTitle: 'Bar Warrior',
  currentXp: 2340,
  xpToNextLevel: 3000,
  workoutCount: 47,
  streakDays: 14,
  activeSkills: 3,
  prCount: 12,
  isPremium: true,
  bio: 'Calisthenics athlete · Chasing planche & front lever.',
  achievements: [
    Achievement(id: '1', emoji: '🔥', name: 'On Fire', isEarned: true),
    Achievement(id: '2', emoji: '💪', name: 'Iron Grip', isEarned: true),
    Achievement(id: '3', emoji: '🎯', name: 'Skill Master', isEarned: true),
    Achievement(id: '4', emoji: '🏋️', name: '50 Club', isEarned: false),
    Achievement(id: '5', emoji: '⭐', name: 'Milestone', isEarned: false),
    Achievement(id: '6', emoji: '🔒', name: 'Locked', isEarned: false),
  ],
);

final _sampleWeekDays = [
  const WeekDay(label: 'M', completed: true),
  const WeekDay(label: 'T', completed: true),
  const WeekDay(label: 'W', completed: true),
  const WeekDay(label: 'T', completed: false),
  const WeekDay(label: 'F', completed: false),
  const WeekDay(label: 'S', completed: false),
  const WeekDay(label: 'S', completed: false),
];

const _sampleProgram = ActiveProgram(
  id: 'prog-1',
  name: 'Beginner Calisthenics',
  currentWeek: 3,
  totalWeeks: 8,
  currentDay: 2,
  totalDays: 5,
  adherencePct: 35,
  level: 'Beginner',
  colors: [Color(0xFF001530), Color(0xFF002860)],
  accent: AppColors.brand,
);

const _sampleRecent = [
  RecentWorkout(
      id: 'w1',
      name: 'Push Day',
      dateLabel: 'Yesterday',
      setCount: 28,
      duration: '38m',
      bgColor: Color(0xFF001D42),
      accent: AppColors.brand),
  RecentWorkout(
      id: 'w2',
      name: 'L-Sit Session',
      dateLabel: '2 days ago',
      setCount: 6,
      duration: '12m',
      isSkillSession: true,
      bgColor: Color(0xFF3A0808),
      accent: AppColors.red),
  RecentWorkout(
      id: 'w3',
      name: 'Leg Day',
      dateLabel: '3 days ago',
      setCount: 24,
      duration: '41m',
      bgColor: Color(0xFF2E2000),
      accent: AppColors.gold),
];

const _sampleWorkouts = [
  Workout(
      id: 'w1',
      name: 'Pull Day',
      duration: '45 min',
      exerciseCount: 6,
      muscles: ['Back', 'Biceps'],
      level: 'Intermediate',
      colors: [Color(0xFF0A2E1A), Color(0xFF0E5C30)],
      accent: AppColors.green,
      category: WorkoutCategory.strength),
  Workout(
      id: 'w2',
      name: 'Push Day',
      duration: '40 min',
      exerciseCount: 7,
      muscles: ['Chest', 'Triceps'],
      level: 'Intermediate',
      colors: [Color(0xFF001D42), Color(0xFF003E8A)],
      accent: AppColors.brand,
      category: WorkoutCategory.strength),
  Workout(
      id: 'w3',
      name: 'Core Foundations',
      duration: '25 min',
      exerciseCount: 5,
      muscles: ['Core'],
      level: 'Beginner',
      colors: [Color(0xFF3A0808), Color(0xFF7A1010)],
      accent: AppColors.red,
      category: WorkoutCategory.strength),
  Workout(
      id: 'w4',
      name: 'Leg Power',
      duration: '35 min',
      exerciseCount: 6,
      muscles: ['Quads', 'Glutes'],
      level: 'Advanced',
      colors: [Color(0xFF2E2000), Color(0xFF614400)],
      accent: AppColors.gold,
      category: WorkoutCategory.strength),
  Workout(
      id: 'w5',
      name: 'Ring Strength',
      duration: '50 min',
      exerciseCount: 8,
      muscles: ['Chest', 'Back'],
      level: 'Advanced',
      colors: [Color(0xFF2B0A4F), Color(0xFF5A1A99)],
      accent: AppColors.purple,
      category: WorkoutCategory.rings),
];

const _sampleCategories = [
  ExerciseCategory(
      id: 'chest',
      name: 'Chest',
      tag: 'Push',
      exerciseCount: 8,
      colors: [Color(0xFF001D42), Color(0xFF003E8A)],
      accent: AppColors.brand),
  ExerciseCategory(
      id: 'back',
      name: 'Back',
      tag: 'Pull',
      exerciseCount: 8,
      colors: [Color(0xFF0A2E1A), Color(0xFF0E5C30)],
      accent: AppColors.green),
  ExerciseCategory(
      id: 'shoulders',
      name: 'Shoulders',
      tag: 'Press',
      exerciseCount: 6,
      colors: [Color(0xFF2B0A4F), Color(0xFF5A1A99)],
      accent: AppColors.purple),
  ExerciseCategory(
      id: 'arms',
      name: 'Arms',
      tag: 'Curl/Ext',
      exerciseCount: 7,
      colors: [Color(0xFF3A1200), Color(0xFF7A2800)],
      accent: AppColors.orange),
  ExerciseCategory(
      id: 'core',
      name: 'Core',
      tag: 'Static',
      exerciseCount: 8,
      colors: [Color(0xFF3A0808), Color(0xFF7A1010)],
      accent: AppColors.red),
  ExerciseCategory(
      id: 'legs',
      name: 'Legs',
      tag: 'Squat',
      exerciseCount: 6,
      colors: [Color(0xFF2E2000), Color(0xFF614400)],
      accent: AppColors.gold),
  ExerciseCategory(
      id: 'full_body',
      name: 'Full Body',
      tag: 'Compound',
      exerciseCount: 6,
      colors: [Color(0xFF001830), Color(0xFF003366)],
      accent: AppColors.teal),
  ExerciseCategory(
      id: 'mobility',
      name: 'Mobility',
      tag: 'Stretch',
      exerciseCount: 8,
      colors: [Color(0xFF002222), Color(0xFF004444)],
      accent: Color(0xFF4DD0E1)),
];

// Return exercises for a given category ID.
// In production, this is an async Firestore query filtered by category.
List<Exercise> _sampleExercisesFor(String catId) {
  // Placeholder: return an empty list; real app calls repository.getExercises(category: catId)
  return [];
}

const _sampleSkills = [
  Skill(
      name: 'Front Lever',
      family: 'pull',
      currentTier: 'Tuck',
      nextTier: 'Adv. Tuck',
      tierIndex: 2,
      totalTiers: 5,
      bestDisplay: '8s',
      target: '10s',
      progressPct: 80,
      colors: [Color(0xFF0A2E1A), Color(0xFF0E5C30)],
      accent: AppColors.green,
      status: SkillStatus.active,
      isStaticHold: true,
      instructions: [
        "Hang from bar with overhand grip.",
        "Depress and retract scapulae.",
        "Push bar toward hips to raise body horizontal.",
        "Hold — hips must stay level.",
        "Build to 10-second holds before advancing."
      ],
      primaryMuscles: ['Lats', 'Core', 'Rear Deltoids'],
      secondaryMuscles: ['Biceps', 'Rhomboids']),
  Skill(
      name: 'Handstand',
      family: 'push',
      currentTier: 'Wall Supported',
      nextTier: 'Kick-Up',
      tierIndex: 2,
      totalTiers: 6,
      bestDisplay: '42s',
      target: '60s',
      progressPct: 70,
      colors: [Color(0xFF2B0A4F), Color(0xFF5A1A99)],
      accent: AppColors.purple,
      status: SkillStatus.active,
      isStaticHold: true,
      instructions: [
        "Hands 6–8cm from wall.",
        "Kick up — chest toward wall.",
        "Stack wrists, shoulders, hips, ankles.",
        "Push the floor away actively.",
        "Squeeze glutes, hollow body, point toes."
      ],
      primaryMuscles: ['Shoulders', 'Triceps', 'Core'],
      secondaryMuscles: ['Wrists', 'Forearms', 'Traps']),
  Skill(
      name: 'L-Sit',
      family: 'core',
      currentTier: 'Tuck L-Sit',
      nextTier: 'Full L-Sit',
      tierIndex: 2,
      totalTiers: 4,
      bestDisplay: '12s',
      target: '15s',
      progressPct: 80,
      colors: [Color(0xFF3A0808), Color(0xFF7A1010)],
      accent: AppColors.red,
      status: SkillStatus.active,
      isStaticHold: true,
      instructions: [
        "Grip parallel bars and press to straight-arm support.",
        "Depress scapulae — shoulders away from ears.",
        "Extend legs forward until parallel to ground.",
        "Lean forward over hands for compression.",
        "Point toes, squeeze quads, maximum tension."
      ],
      primaryMuscles: ['Core', 'Hip Flexors', 'Triceps'],
      secondaryMuscles: ['Shoulders', 'Quads']),
  Skill(
      name: 'Planche',
      family: 'push',
      currentTier: 'Planche Lean',
      nextTier: 'Tuck Planche',
      tierIndex: 1,
      totalTiers: 6,
      bestDisplay: null,
      target: '30s',
      progressPct: 15,
      colors: [Color(0xFF001D42), Color(0xFF003E8A)],
      accent: AppColors.brand,
      status: SkillStatus.started,
      isStaticHold: true,
      instructions: [
        "Begin with planche lean — shift shoulders over wrists.",
        "Keep arms fully locked.",
        "Protract scapulae — round upper back slightly.",
        "Elevate hips until body is parallel to ground.",
        "Build lean progressively."
      ],
      primaryMuscles: ['Shoulders', 'Serratus Anterior'],
      secondaryMuscles: ['Core', 'Triceps']),
  Skill(
      name: 'Muscle-Up',
      family: 'pull',
      currentTier: 'Locked',
      nextTier: 'Scapular Pull',
      tierIndex: 0,
      totalTiers: 5,
      bestDisplay: null,
      target: '1 rep',
      progressPct: 0,
      colors: [Color(0xFF1A1A00), Color(0xFF3A3A00)],
      accent: AppColors.gold,
      status: SkillStatus.locked,
      isStaticHold: false,
      instructions: [
        "Use a false grip — wrists over bar.",
        "Initiate with explosive pull.",
        "As chest reaches bar, lean forward and transition.",
        "Lock out arms in straight-arm support.",
        "Lower back to dead hang with full control."
      ],
      primaryMuscles: ['Lats', 'Chest', 'Triceps'],
      secondaryMuscles: ['Biceps', 'Core', 'Shoulders']),
];

final _sampleHeatmap = [
  [2, 0, 2, 2, 0, 1, 2],
  [2, 2, 0, 2, 2, 0, 0],
  [1, 2, 2, 0, 2, 2, 1],
  [0, 2, 2, 2, 0, 2, 2],
];

final _sampleSettingGroups = [
  const SettingGroup(label: 'Account', items: [
    SettingItem(
        iconData: Icons.edit_outlined,
        color: AppColors.brand,
        label: 'Edit Profile'),
    SettingItem(
        iconData: Icons.shield_outlined,
        color: AppColors.green,
        label: 'Security'),
    SettingItem(
        iconData: Icons.notifications_outlined,
        color: AppColors.orange,
        label: 'Notifications'),
  ]),
  const SettingGroup(label: 'App', items: [
    SettingItem(
        iconData: Icons.palette_outlined,
        color: AppColors.purple,
        label: 'Appearance'),
    SettingItem(
        iconData: Icons.sensors_rounded,
        color: AppColors.teal,
        label: 'Connected Apps'),
    SettingItem(
        iconData: Icons.star_outline_rounded,
        color: AppColors.gold,
        label: 'Subscription',
        badge: 'PREMIUM'),
  ]),
  const SettingGroup(label: 'Support', items: [
    SettingItem(
        iconData: Icons.favorite_outline_rounded,
        color: AppColors.red,
        label: 'Help & FAQ'),
    SettingItem(
        iconData: Icons.logout_rounded,
        color: AppColors.red,
        label: 'Log Out',
        destructive: true),
  ]),
];

const _samplePRs = [
  PrEntry(
      exerciseName: 'Pull-Up',
      valueDisplay: '20 reps',
      accent: AppColors.green),
  PrEntry(
      exerciseName: 'Tuck Front Lever',
      valueDisplay: '8s',
      accent: AppColors.green),
  PrEntry(
      exerciseName: 'Weighted Dip',
      valueDisplay: '+20kg',
      accent: AppColors.brand),
];

const _sampleMuscles = [
  MuscleStat(name: 'Back', pct: 30),
  MuscleStat(name: 'Chest', pct: 24),
  MuscleStat(name: 'Core', pct: 20),
  MuscleStat(name: 'Shoulders', pct: 13),
  MuscleStat(name: 'Arms', pct: 8),
  MuscleStat(name: 'Legs', pct: 5),
];

final _sampleTrends = [
  const SkillTrend(
      skillName: 'Front Lever Hold',
      values: [3, 5, 5, 6, 7, 7, 8],
      unit: 's',
      color: AppColors.green),
  const SkillTrend(
      skillName: 'Handstand Hold',
      values: [15, 18, 20, 25, 28, 38, 42],
      unit: 's',
      color: AppColors.purple),
  const SkillTrend(
      skillName: 'Pull-Up Reps',
      values: [8, 10, 10, 12, 14, 14, 15],
      unit: '',
      color: AppColors.brand),
];
