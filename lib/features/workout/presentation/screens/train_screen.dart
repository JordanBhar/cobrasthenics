import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

class TrainScreen extends StatefulWidget {
  final ActiveProgram? activeProgram;
  final List<Workout> workouts;
  final List<WorkoutCategory> filterOptions;
  final VoidCallback? onQuickStart;
  final VoidCallback? onCustomBuild;
  final VoidCallback? onCalendar;
  final VoidCallback? onAllPrograms;
  final void Function(Workout)? onWorkoutTap;
  final void Function(ActiveProgram)? onContinueProgram;

  const TrainScreen({
    super.key,
    this.activeProgram,
    required this.workouts,
    this.filterOptions = WorkoutCategory.values,
    this.onQuickStart,
    this.onCustomBuild,
    this.onCalendar,
    this.onAllPrograms,
    this.onWorkoutTap,
    this.onContinueProgram,
  });

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  WorkoutCategory _filter = WorkoutCategory.all;

  List<Workout> get _filteredWorkouts => _filter == WorkoutCategory.all
      ? widget.workouts
      : widget.workouts.where((w) => w.category == _filter).toList();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cobrasthenics', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  const Text('Train', style: AppTextStyles.h1),
                  const SizedBox(height: 20),

                  // Quick actions
                  Row(
                    children: [
                      _QuickAction(
                          label: 'Quick Start',
                          icon: Icons.bolt_rounded,
                          color: AppColors.brand,
                          onTap: widget.onQuickStart),
                      const SizedBox(width: 10),
                      _QuickAction(
                          label: 'Custom Build',
                          icon: Icons.add_rounded,
                          color: AppColors.textSecondary,
                          onTap: widget.onCustomBuild),
                      const SizedBox(width: 10),
                      _QuickAction(
                          label: 'Calendar',
                          icon: Icons.calendar_month_rounded,
                          color: AppColors.textSecondary,
                          onTap: widget.onCalendar),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Active program
                  SectionHeader(
                      label: 'My Program',
                      actionLabel: 'All Programs',
                      onAction: widget.onAllPrograms),
                  const SizedBox(height: 10),
                  if (widget.activeProgram != null)
                    _ActiveProgramHero(
                      program: widget.activeProgram!,
                      onContinue: () =>
                          widget.onContinueProgram?.call(widget.activeProgram!),
                    )
                  else
                    _NoProgramPlaceholder(onBrowse: widget.onAllPrograms),
                  const SizedBox(height: 24),

                  // Filters
                  FilterChips<WorkoutCategory>(
                    options: widget.filterOptions,
                    selected: _filter,
                    labelOf: _filterLabel,
                    onSelect: (f) => setState(() => _filter = f),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Workout list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _filteredWorkouts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => WorkoutTile(
                workout: _filteredWorkouts[i],
                onTap: () => widget.onWorkoutTap?.call(_filteredWorkouts[i]),
              ),
            ),
            if (_filteredWorkouts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AppCard(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No workouts in this category',
                        style: AppTextStyles.body),
                  ),
                ),
              ),
          ],
        ),
      );

  String _filterLabel(WorkoutCategory c) {
    switch (c) {
      case WorkoutCategory.all:
        return 'All Workouts';
      case WorkoutCategory.strength:
        return 'Strength';
      case WorkoutCategory.skill:
        return 'Skill';
      case WorkoutCategory.mobility:
        return 'Mobility';
      case WorkoutCategory.rings:
        return 'Rings';
    }
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _QuickAction(
      {required this.label,
      required this.icon,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: color == AppColors.brand
                  ? AppColors.brandDim
                  : AppColors.elevated,
              border: Border.all(
                  color: color == AppColors.brand
                      ? AppColors.brand.withValues(alpha: 0.28)
                      : AppColors.border),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(height: 4),
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
}

class _ActiveProgramHero extends StatelessWidget {
  final ActiveProgram program;
  final VoidCallback? onContinue;
  const _ActiveProgramHero({required this.program, this.onContinue});

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
                        AccentPill(
                            label: program.level, accent: program.accent),
                        const SizedBox(height: 8),
                        Text(program.name, style: AppTextStyles.h3),
                      ]),
                ),
                RingProgress(
                  pct: program.adherencePct / 100,
                  color: program.accent,
                  size: 50,
                  child: Text('${program.adherencePct}%',
                      style: AppTextStyles.mono.copyWith(
                          fontSize: 11,
                          color: program.accent,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(children: [
              _chip('Week', '${program.currentWeek}/${program.totalWeeks}'),
              const SizedBox(width: 12),
              _chip('Day', '${program.currentDay}/${program.totalDays}'),
            ]),
            const SizedBox(height: 14),
            SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                    label: 'Continue Today\'s Session →',
                    color: program.accent,
                    onTap: onContinue)),
          ],
        ),
      );

  Widget _chip(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.caption
                  .copyWith(color: Colors.white.withValues(alpha: 0.4))),
          Text(value, style: AppTextStyles.monoLarge.copyWith(fontSize: 16)),
        ]),
      );
}

class _NoProgramPlaceholder extends StatelessWidget {
  final VoidCallback? onBrowse;
  const _NoProgramPlaceholder({this.onBrowse});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(children: [
          const Icon(Icons.add_circle_outline_rounded,
              color: AppColors.textHint, size: 36),
          const SizedBox(height: 12),
          Text('No active program',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          PrimaryButton(
              label: 'Browse Programs',
              color: AppColors.brand,
              onTap: onBrowse),
        ]),
      );
}
