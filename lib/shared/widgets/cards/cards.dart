import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../models/models.dart';
import '../charts/charts.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;
  final bool hasBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = 16,
    this.color = AppColors.card,
    this.borderColor = AppColors.border,
    this.onTap,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: hasBorder ? Border.all(color: borderColor) : null,
            ),
            padding: padding,
            child: child,
          ),
        ),
      );
}

class DifficultyPill extends StatelessWidget {
  final String difficulty;

  const DifficultyPill({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.difficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: AppTextStyles.pill.copyWith(color: color),
      ),
    );
  }
}

class AccentPill extends StatelessWidget {
  final String label;
  final Color accent;

  const AccentPill({super.key, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.pill.copyWith(color: accent),
        ),
      );
}

class StatCard extends StatelessWidget {
  final Widget icon;
  final String value;
  final String label;
  final Color accent;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accent = AppColors.brand,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              icon,
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.monoLarge
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class GradientCard extends StatelessWidget {
  final List<Color> colors;
  final Color accent;
  final Widget child;
  final double radius;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const GradientCard({
    super.key,
    required this.colors,
    required this.accent,
    required this.child,
    this.radius = 20,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      gradient: RadialGradient(
                        center: const Alignment(0.6, -0.6),
                        radius: 0.8,
                        colors: [
                          accent.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      );
}

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;

  const ExerciseTile({super.key, required this.exercise, this.onTap});

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: exercise.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border:
                    Border.all(color: exercise.accent.withValues(alpha: 0.25)),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white.withValues(alpha: 0.75),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    children: [
                      DifficultyPill(difficulty: exercise.difficulty),
                      Text(exercise.equipment, style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    children: [
                      ...exercise.primaryMuscles.take(2).map(
                            (m) => Text(
                              m,
                              style: AppTextStyles.caption.copyWith(
                                color: exercise.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      if (exercise.secondaryMuscles.isNotEmpty)
                        Text(
                          '+${exercise.secondaryMuscles.first}',
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 15, color: AppColors.textHint),
          ],
        ),
      );
}

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback? onTrain;
  final VoidCallback? onAnalyse;
  final VoidCallback? onTap;

  const SkillCard({
    super.key,
    required this.skill,
    this.onTrain,
    this.onAnalyse,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = skill.status == SkillStatus.locked;
    return AppCard(
      onTap: locked ? null : onTap,
      padding: EdgeInsets.zero,
      borderColor:
          locked ? AppColors.border : skill.accent.withValues(alpha: 0.22),
      child: Opacity(
        opacity: locked ? 0.55 : 1.0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: skill.colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: skill.accent.withValues(alpha: 0.25)),
                        ),
                        child: Center(
                          child: Text(
                            locked
                                ? String.fromCharCode(0x1F512)
                                : skill.status == SkillStatus.active
                                    ? String.fromCharCode(0x1F3AF)
                                    : String.fromCharCode(0x1F331),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    skill.name,
                                    style: AppTextStyles.bodyLarge
                                        .copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                if (!locked)
                                  const Icon(Icons.chevron_right,
                                      size: 15, color: AppColors.textHint),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              locked
                                  ? 'Complete prerequisites to unlock'
                                  : 'Tier ${skill.tierIndex} of ${skill.totalTiers} '
                                      '${String.fromCharCode(0x00B7)} ${skill.currentTier}',
                              style: AppTextStyles.caption.copyWith(
                                color: locked
                                    ? AppColors.textHint
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TierDotsRow(
                              current: skill.tierIndex,
                              total: skill.totalTiers,
                              accent: skill.accent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!locked) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _statBox(
                                'Best',
                                skill.bestDisplay ??
                                    String.fromCharCode(0x2014),
                                skill.accent)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _statBox(
                                'Target', skill.target, AppColors.textSecondary)),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.elevated,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Progress',
                                    style: AppTextStyles.caption),
                                const SizedBox(height: 6),
                                AppProgressBar(
                                    pct: skill.progressPct / 100,
                                    color: skill.accent),
                                const SizedBox(height: 4),
                                Text(
                                  '${skill.progressPct}%',
                                  style: AppTextStyles.mono.copyWith(
                                    fontSize: 11,
                                    color: skill.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!locked) ...[
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Train',
                        icon: Icons.play_arrow_rounded,
                        color: skill.accent,
                        filled: true,
                        onTap: onTrain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _ActionButton(
                        label: 'Analyse Form',
                        icon: Icons.camera_alt_outlined,
                        color: skill.accent,
                        filled: false,
                        onTap: onAnalyse,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.elevated, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(value,
                style:
                    AppTextStyles.monoLarge.copyWith(fontSize: 16, color: color)),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: filled ? color : color.withValues(alpha: 0.14),
            border: filled
                ? null
                : Border.all(color: color.withValues(alpha: 0.32)),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: filled ? Colors.white : color, size: 15),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: filled ? Colors.white : color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
}

class WorkoutTile extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutTile({super.key, required this.workout, this.onTap});

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: workout.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border:
                    Border.all(color: workout.accent.withValues(alpha: 0.25)),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: Colors.white.withValues(alpha: 0.75),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.exerciseCount} exercises '
                    '${String.fromCharCode(0x00B7)} ${workout.duration}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    children: workout.muscles
                        .take(3)
                        .map(
                          (m) => Text(
                            m,
                            style: AppTextStyles.caption.copyWith(
                              color: workout.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            DifficultyPill(difficulty: workout.level),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                size: 15, color: AppColors.textHint),
          ],
        ),
      );
}

class InstructionStep extends StatelessWidget {
  final int index;
  final String text;
  final Color accent;

  const InstructionStep({
    super.key,
    required this.index,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                (index + 1).toString().padLeft(2, '0'),
                style: AppTextStyles.pill.copyWith(color: accent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  text,
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      );
}
