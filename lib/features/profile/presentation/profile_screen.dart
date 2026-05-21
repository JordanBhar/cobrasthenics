import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

// ─── SettingItem ──────────────────────────────────────────────────────────────
// Kept local to this file — it's purely a UI config object with no Firestore
// representation. Pass a list of SettingGroups in from whatever layer owns nav.

class SettingItem {
  final IconData iconData;
  final Color color;
  final String label;
  final String? badge;
  final bool destructive;
  final VoidCallback? onTap;

  const SettingItem({
    required this.iconData,
    required this.color,
    required this.label,
    this.badge,
    this.destructive = false,
    this.onTap,
  });
}

class SettingGroup {
  final String label;
  final List<SettingItem> items;
  const SettingGroup({required this.label, required this.items});
}

// ─── ProfileScreen ────────────────────────────────────────────────────────────
// Accepts the shared UserProfile, Achievement, PrEntry, MuscleStat and
// SkillTrend models from models.dart and renders them with tokens from
// app_theme.dart and components from shared widgets.

class ProfileScreen extends StatefulWidget {
  // ── Profile data ──────────────────────────────────────────────────────────
  final UserProfile user;
  final List<SettingGroup> settingGroups;

  // ── Progress data ─────────────────────────────────────────────────────────
  final List<List<int>> heatmapGrid; // row × col, values 0–3
  final List<double> weeklyVolume;
  final List<PrEntry> personalRecords;
  final List<MuscleStat> muscleBreakdown;
  final List<SkillTrend> skillTrends;

  // ── Callbacks ─────────────────────────────────────────────────────────────
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSeeAllAchievements;
  final VoidCallback? onSeeAllPRs;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.settingGroups,
    this.heatmapGrid = const [
      [2, 0, 2, 2, 0, 1, 2],
      [2, 2, 0, 2, 2, 0, 0],
      [1, 2, 2, 0, 2, 2, 1],
      [0, 2, 2, 2, 0, 2, 2],
    ],
    this.weeklyVolume = const [18, 24, 20, 31, 28, 35, 30],
    this.personalRecords = const [],
    this.muscleBreakdown = const [
      MuscleStat(name: 'Back', pct: 30),
      MuscleStat(name: 'Chest', pct: 24),
      MuscleStat(name: 'Core', pct: 20),
      MuscleStat(name: 'Shoulders', pct: 13),
      MuscleStat(name: 'Arms', pct: 8),
      MuscleStat(name: 'Legs', pct: 5),
    ],
    this.skillTrends = const [],
    this.onSettingsTap,
    this.onSeeAllAchievements,
    this.onSeeAllPRs,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _progressTab = 0; // 0 = Overview  |  1 = Analytics

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HERO ──────────────────────────────────────────────────────────
            _ProfileHero(
              user: widget.user,
              onSettingsTap: widget.onSettingsTap,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── XP BAR ──────────────────────────────────────────────────
                  _XpBar(user: widget.user),
                  const SizedBox(height: AppSpacing.xl),

                  // ── ACHIEVEMENTS ────────────────────────────────────────────
                  SectionHeader(
                    label: 'Achievements',
                    actionLabel: 'See All',
                    onAction: widget.onSeeAllAchievements,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _AchievementGrid(achievements: widget.user.achievements),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── PROGRESS ────────────────────────────────────────────────
                  const SectionHeader(label: 'Progress'),
                  const SizedBox(height: AppSpacing.sm),
                  _ProgressTabBar(
                    selected: _progressTab,
                    onSelect: (i) => setState(() => _progressTab = i),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _progressTab == 0
                        ? _ProgressOverview(
                            key: const ValueKey(0),
                            user: widget.user,
                            heatmapGrid: widget.heatmapGrid,
                            weeklyVolume: widget.weeklyVolume,
                            personalRecords: widget.personalRecords,
                            onSeeAllPRs: widget.onSeeAllPRs,
                          )
                        : _ProgressAnalytics(
                            key: const ValueKey(1),
                            muscleBreakdown: widget.muscleBreakdown,
                            skillTrends: widget.skillTrends,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── SETTINGS ────────────────────────────────────────────────
                  ...widget.settingGroups.map(
                    (g) => _SettingGroupCard(group: g),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE HERO
// ═══════════════════════════════════════════════════════════════════════════

class _ProfileHero extends StatelessWidget {
  final UserProfile user;
  final VoidCallback? onSettingsTap;

  const _ProfileHero({required this.user, this.onSettingsTap});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A14), Color(0xFF12122A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Stack(
          children: [
            // Radial glow orb
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.brand.withValues(alpha: 0.12),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onSettingsTap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: AppRadii.smBr,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Avatar + name row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar with level badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF001D42), Color(0xFF003E8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            border: Border.all(
                              color: AppColors.brand.withValues(alpha: 0.25),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            user.avatarUrl != null ? '' : '💪',
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        Positioned(
                          bottom: -6,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gold, AppColors.orange],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.background, width: 2),
                            ),
                            child: Text(
                              'Lv.${user.level}',
                              style: AppTextStyles.pill.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),

                    // Name / username / premium
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName, style: AppTextStyles.h2),
                          const SizedBox(height: 3),
                          Text(
                            '@${user.username} · ${user.levelTitle}',
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 8),
                          if (user.isPremium)
                            const AccentPill(
                                label: 'Premium', accent: AppColors.gold),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Bio
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(user.bio!, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),

                // Stats grid — 4 equal columns
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: AppRadii.mdBr,
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      _statCell('${user.workoutCount}', 'Workouts',
                          border: true),
                      _statCell('${user.streakDays}', 'Streak', border: true),
                      _statCell('${user.activeSkills}', 'Skills', border: true),
                      _statCell('${user.prCount}', 'PRs', border: false),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _statCell(String value, String label, {required bool border}) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: border
                ? Border(
                    right:
                        BorderSide(color: Colors.white.withValues(alpha: 0.06)))
                : null,
          ),
          child: Column(
            children: [
              Text(value, style: AppTextStyles.monoLarge),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// XP BAR
// ═══════════════════════════════════════════════════════════════════════════

class _XpBar extends StatelessWidget {
  final UserProfile user;
  const _XpBar({required this.user});

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) => AppCard(
        radius: 18,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Level title + sub-label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${user.level} · ${user.levelTitle}',
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_fmt(user.currentXp)} XP · ${_fmt(user.xpToNextLevel - user.currentXp)} to Level ${user.level + 1}',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),

                // Level badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.orange],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${user.level}',
                    style: AppTextStyles.monoLarge.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Gold gradient progress bar with glow
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: user.xpProgress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gold, AppColors.orange],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Labels below bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_fmt(user.currentXp)} XP',
                    style: AppTextStyles.caption),
                Text(
                  '${(user.xpProgress * 100).toStringAsFixed(0)}% · ${_fmt(user.xpToNextLevel - user.currentXp)} XP to go',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('${_fmt(user.xpToNextLevel)} XP',
                    style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// ACHIEVEMENTS GRID
// ═══════════════════════════════════════════════════════════════════════════

class _AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementGrid({required this.achievements});

  // Map static accent colours by position since Achievement has no color field
  static const List<Color> _accentPalette = [
    AppColors.gold,
    AppColors.brand,
    AppColors.green,
    AppColors.purple,
    AppColors.orange,
    AppColors.textSecondary,
  ];

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text('No achievements yet', style: AppTextStyles.body),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.88,
      children: achievements.asMap().entries.map((e) {
        final accent = _accentPalette[e.key % _accentPalette.length];
        return _AchievementCard(item: e.value, accent: accent);
      }).toList(),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement item;
  final Color accent;
  const _AchievementCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: item.isEarned ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
          decoration: BoxDecoration(
            color:
                item.isEarned ? accent.withValues(alpha: 0.1) : AppColors.card,
            borderRadius: AppRadii.mdBr,
            border: Border.all(
              color: item.isEarned
                  ? accent.withValues(alpha: 0.25)
                  : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: item.isEarned
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!item.isEarned) ...[
                const SizedBox(height: 6),
                const Icon(Icons.lock_outline_rounded,
                    color: AppColors.textHint, size: 10),
              ],
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS — TAB BAR
// ═══════════════════════════════════════════════════════════════════════════

class _ProgressTabBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _ProgressTabBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadii.smBr,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: ['Overview', 'Analytics'].asMap().entries.map((e) {
            final on = e.key == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? AppColors.elevated2 : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    e.value,
                    style: AppTextStyles.label.copyWith(
                      color: on ? AppColors.textPrimary : AppColors.textHint,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS OVERVIEW TAB
// ═══════════════════════════════════════════════════════════════════════════

class _ProgressOverview extends StatelessWidget {
  final UserProfile user;
  final List<List<int>> heatmapGrid;
  final List<double> weeklyVolume;
  final List<PrEntry> personalRecords;
  final VoidCallback? onSeeAllPRs;

  const _ProgressOverview({
    super.key,
    required this.user,
    required this.heatmapGrid,
    required this.weeklyVolume,
    required this.personalRecords,
    this.onSeeAllPRs,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stat cards
          Row(
            children: [
              _MiniStatCard(
                value: '${user.workoutCount}',
                label: 'Workouts',
                icon: Icons.fitness_center_rounded,
                color: AppColors.brand,
              ),
              const SizedBox(width: 10),
              _MiniStatCard(
                value: '${user.streakDays}d',
                label: 'Streak',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.gold,
              ),
              const SizedBox(width: 10),
              _MiniStatCard(
                value: '${user.prCount}',
                label: 'PRs Set',
                icon: Icons.emoji_events_rounded,
                color: AppColors.orange,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Consistency heatmap
          AppCard(
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consistency', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                HeatmapGrid(grid: heatmapGrid, color: AppColors.brand),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Weekly volume bar chart
          AppCard(
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weekly Volume', style: AppTextStyles.h3),
                    if (weeklyVolume.isNotEmpty)
                      Text(
                        '${weeklyVolume.last.toInt()}',
                        style: AppTextStyles.monoLarge
                            .copyWith(color: AppColors.brand),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (weeklyVolume.isNotEmpty)
                  MiniBarChart(
                      values: weeklyVolume, color: AppColors.brand, height: 60),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // PR board
          SectionHeader(
            label: 'Personal Records',
            actionLabel: 'See All',
            onAction: onSeeAllPRs,
          ),
          const SizedBox(height: 10),

          if (personalRecords.isEmpty)
            const AppCard(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text('No PRs yet — start training!',
                    style: AppTextStyles.body),
              ),
            )
          else
            ...personalRecords.map(
              (pr) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: AppCard(
                  radius: 16,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.gold,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pr.exerciseName,
                          style: AppTextStyles.bodyLarge.copyWith(fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: pr.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          pr.valueDisplay,
                          style: AppTextStyles.mono.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: pr.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS ANALYTICS TAB
// ═══════════════════════════════════════════════════════════════════════════

class _ProgressAnalytics extends StatelessWidget {
  final List<MuscleStat> muscleBreakdown;
  final List<SkillTrend> skillTrends;

  const _ProgressAnalytics({
    super.key,
    required this.muscleBreakdown,
    required this.skillTrends,
  });

  Color _colorFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('back')) return AppColors.green;
    if (n.contains('chest')) return AppColors.brand;
    if (n.contains('core')) return AppColors.red;
    if (n.contains('shoulder')) return AppColors.purple;
    if (n.contains('arm')) return AppColors.orange;
    return AppColors.gold;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle breakdown
          AppCard(
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Muscle Breakdown', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xxs),
                const Text(
                  'This week · based on logged sets',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                ...muscleBreakdown.map((m) {
                  final color = _colorFor(m.name);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: Text(m.name,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                              )),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppProgressBar(
                            pct: m.pct / 100,
                            color: color,
                            height: 6,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${m.pct}%',
                            style: AppTextStyles.mono.copyWith(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Skill trends
          const SectionHeader(label: 'Skill Trends', actionLabel: 'Details'),
          const SizedBox(height: 10),

          if (skillTrends.isEmpty)
            const AppCard(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text('No skill data yet', style: AppTextStyles.body),
              ),
            )
          else
            ...skillTrends.map(
              (trend) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  radius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            trend.skillName,
                            style:
                                AppTextStyles.bodyLarge.copyWith(fontSize: 13),
                          ),
                          Text(
                            '${trend.latest.toStringAsFixed(1)}${trend.unit}',
                            style: AppTextStyles.monoLarge.copyWith(
                              fontSize: 16,
                              color: trend.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      MiniBarChart(
                        values: trend.values,
                        color: trend.color,
                        height: 48,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '↑ +${trend.gain.toStringAsFixed(1)}${trend.unit} overall',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════════════════

class _SettingGroupCard extends StatelessWidget {
  final SettingGroup group;
  const _SettingGroupCard({required this.group});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group label
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                group.label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // Card
            AppCard(
              radius: 18,
              padding: EdgeInsets.zero,
              child: Column(
                children: group.items.asMap().entries.map((e) {
                  final i = e.key;
                  final item = e.value;
                  return Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(i == 0 ? 18 : 0),
                          topRight: Radius.circular(i == 0 ? 18 : 0),
                          bottomLeft: Radius.circular(
                              i == group.items.length - 1 ? 18 : 0),
                          bottomRight: Radius.circular(
                              i == group.items.length - 1 ? 18 : 0),
                        ),
                        onTap: item.onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              // Icon container
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: item.color.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Icon(item.iconData,
                                    color: item.color, size: 16),
                              ),
                              const SizedBox(width: 14),

                              // Label
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontSize: 14,
                                    color: item.destructive
                                        ? AppColors.red
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),

                              // Optional badge
                              if (item.badge != null) ...[
                                AccentPill(
                                    label: item.badge!, accent: AppColors.gold),
                                const SizedBox(width: 8),
                              ],

                              // Chevron (skip for destructive items)
                              if (!item.destructive)
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: AppColors.textHint,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Divider between items
                      if (i < group.items.length - 1)
                        const AppDivider(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// MINI STAT CARD  (local — not in shared_widgets)
// ═══════════════════════════════════════════════════════════════════════════

class _MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: AppTextStyles.monoLarge),
              const SizedBox(height: 3),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      );
}
