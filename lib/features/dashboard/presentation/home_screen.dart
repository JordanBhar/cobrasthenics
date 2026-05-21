import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

// ─── HomeScreen ───────────────────────────────────────────────────────────────
// All data is passed in via constructor — nothing is hardcoded.
// The parent (router / provider) supplies the data objects.

class HomeScreen extends StatelessWidget {
  final UserProfile user;
  final List<WeekDay> weekDays; // 7 entries for the day strip
  final ActiveProgram? activeProgram;
  final Skill? featuredSkill; // "Skill Focus" widget
  final List<RecentWorkout> recentWorkouts;
  final int streakDays;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onAllSkills;
  final VoidCallback? onHistory;
  final void Function(RecentWorkout)? onWorkoutTap;
  final void Function(Skill)? onSkillTap;

  const HomeScreen({
    super.key,
    required this.user,
    required this.weekDays,
    this.activeProgram,
    this.featuredSkill,
    required this.recentWorkouts,
    required this.streakDays,
    this.onStartWorkout,
    this.onAllSkills,
    this.onHistory,
    this.onWorkoutTap,
    this.onSkillTap,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ──
            _GreetingRow(user: user),
            const SizedBox(height: 16),

            // ── Day Strip ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _DayStrip(days: weekDays),
            ),
            const SizedBox(height: 16),

            // ── Streak + Stats ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _StreakRow(streakDays: streakDays),
            ),
            const SizedBox(height: 20),

            // ── Today's Workout ──
            if (activeProgram != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _ActiveProgramCard(
                    program: activeProgram!, onStart: onStartWorkout),
              ),
              const SizedBox(height: 24),
            ],

            // ── Skill Focus ──
            if (featuredSkill != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SectionHeader(
                    label: 'Skill Focus',
                    actionLabel: 'All Skills',
                    onAction: onAllSkills),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _SkillFocusCard(
                    skill: featuredSkill!,
                    onTap: () => onSkillTap?.call(featuredSkill!)),
              ),
              const SizedBox(height: 24),
            ],

            // ── Recent Activity ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SectionHeader(
                  label: 'Recent Activity',
                  actionLabel: 'History',
                  onAction: onHistory),
            ),
            const SizedBox(height: 10),
            if (recentWorkouts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _EmptyActivity(),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: recentWorkouts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _RecentWorkoutTile(
                  workout: recentWorkouts[i],
                  onTap: () => onWorkoutTap?.call(recentWorkouts[i]),
                ),
              ),
          ],
        ),
      );
}

// ── Sub-widgets (private to this file) ─────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  final UserProfile user;
  const _GreetingRow({required this.user});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning 👋',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(user.displayName, style: AppTextStyles.h1),
                ],
              ),
            ),
            // Notification bell
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.textSecondary, size: 18),
            ),
          ],
        ),
      );
}

class _DayStrip extends StatelessWidget {
  final List<WeekDay> days;
  const _DayStrip({required this.days});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((d) => _DayDot(day: d)).toList(),
        ),
      );
}

class _DayDot extends StatelessWidget {
  final WeekDay day;
  const _DayDot({required this.day});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(day.label,
              style: AppTextStyles.caption.copyWith(
                  color: day.completed ? AppColors.brand : AppColors.textHint,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: day.completed ? AppColors.brand : AppColors.elevated,
              borderRadius: BorderRadius.circular(9),
            ),
            child: day.completed
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
        ],
      );
}

class _StreakRow extends StatelessWidget {
  final int streakDays;
  const _StreakRow({required this.streakDays});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: GradientCard(
              colors: const [Color(0xFF1A0C00), Color(0xFF2E1500)],
              accent: AppColors.gold,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$streakDays',
                          style: AppTextStyles.monoLarge
                              .copyWith(color: AppColors.gold)),
                      const Text('Day Streak', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.fitness_center_rounded,
                        size: 14, color: AppColors.brand),
                    const SizedBox(width: 8),
                    Text('3 / 5 sessions',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary, fontSize: 12)),
                  ]),
                ),
                const SizedBox(height: 6),
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.bar_chart_rounded,
                        size: 14, color: AppColors.green),
                    const SizedBox(width: 8),
                    Text('2,840 total sets',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary, fontSize: 12)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      );
}

class _ActiveProgramCard extends StatelessWidget {
  final ActiveProgram program;
  final VoidCallback? onStart;
  const _ActiveProgramCard({required this.program, this.onStart});

  @override
  Widget build(BuildContext context) => GradientCard(
        colors: program.colors,
        accent: program.accent,
        radius: 22,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccentPill(label: program.level, accent: program.accent),
                      const SizedBox(height: 8),
                      Text(program.name,
                          style:
                              AppTextStyles.h3.copyWith(letterSpacing: -0.6)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                RingProgress(
                  pct: program.adherencePct / 100,
                  color: program.accent,
                  size: 50,
                  child: Text(
                    '${program.adherencePct}%',
                    style: AppTextStyles.mono.copyWith(
                        fontSize: 11,
                        color: program.accent,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _statChip(
                    'Week', '${program.currentWeek}/${program.totalWeeks}'),
                const SizedBox(width: 12),
                _statChip('Day', '${program.currentDay}/${program.totalDays}'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                  label: 'Continue Today\'s Session →',
                  color: program.accent,
                  onTap: onStart),
            ),
          ],
        ),
      );

  Widget _statChip(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(label.toUpperCase(),
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white.withValues(alpha: 0.4))),
            Text(value, style: AppTextStyles.monoLarge.copyWith(fontSize: 16)),
          ],
        ),
      );
}

class _SkillFocusCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback? onTap;
  const _SkillFocusCard({required this.skill, this.onTap});

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: skill.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: skill.accent.withValues(alpha: 0.2)),
              ),
              child: const Center(
                  child: Text('🏋️', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skill.name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.caption,
                      children: [
                        const TextSpan(text: 'Last: '),
                        TextSpan(
                            text: skill.bestDisplay ?? '—',
                            style: AppTextStyles.mono.copyWith(
                                fontSize: 12,
                                color: skill.accent,
                                fontWeight: FontWeight.w700)),
                        const TextSpan(text: '  ·  Target: '),
                        TextSpan(
                            text: skill.target,
                            style: AppTextStyles.mono.copyWith(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppProgressBar(
                      pct: skill.progressPct / 100, color: skill.accent),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: skill.accent.withValues(alpha: 0.12),
                border: Border.all(color: skill.accent.withValues(alpha: 0.25)),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(Icons.play_arrow_rounded, color: skill.accent, size: 18),
            ),
          ],
        ),
      );
}

class _RecentWorkoutTile extends StatelessWidget {
  final RecentWorkout workout;
  final VoidCallback? onTap;
  const _RecentWorkoutTile({required this.workout, this.onTap});

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: workout.bgColor,
                borderRadius: BorderRadius.circular(13),
                border:
                    Border.all(color: workout.accent.withValues(alpha: 0.3)),
              ),
              child: Center(
                  child: Text(workout.isSkillSession ? '🎯' : '💪',
                      style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      '${workout.dateLabel} · ${workout.setCount} sets · ${workout.duration}',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 14, color: AppColors.textHint),
          ],
        ),
      );
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(Icons.fitness_center_rounded,
                color: AppColors.textHint, size: 32),
            const SizedBox(height: 12),
            Text('No workouts yet',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('Start your first session to see your activity here',
                style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      );
}
