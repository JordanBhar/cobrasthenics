import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── ExerciseDetailScreen ─────────────────────────────────────────────────────
// Fully driven by a single Exercise object.
// The PR, progression chain neighbours (prevExercise/nextExercise),
// and history entries are all passed in — nothing hardcoded.

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  final Exercise? prevExercise; // resolved from progressionChain.prev
  final Exercise? nextExercise; // resolved from progressionChain.next
  final List<ExerciseHistoryEntry> history;
  final bool isFavourite;
  final VoidCallback? onBack;
  final VoidCallback? onAddToWorkout;
  final VoidCallback? onToggleFavourite;
  final void Function(Exercise)? onProgressionTap;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.prevExercise,
    this.nextExercise,
    this.history = const [],
    this.isFavourite = false,
    this.onBack,
    this.onAddToWorkout,
    this.onToggleFavourite,
    this.onProgressionTap,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int _tab = 0;
  bool _playing = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              slivers: [
                // Video player
                SliverToBoxAdapter(
                    child: _VideoPlayer(
                        exercise: widget.exercise,
                        playing: _playing,
                        onToggle: () => setState(() => _playing = !_playing))),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + badges
                        Text(widget.exercise.name, style: AppTextStyles.h1),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            DifficultyPill(
                                difficulty: widget.exercise.difficulty),
                            _TagPill(
                                label: widget.exercise.equipment,
                                icon: Icons.fitness_center_outlined),
                            _TagPill(
                                label: widget.exercise.setTypeLabel,
                                icon: Icons.repeat_rounded),
                            _TagPill(
                                label: widget.exercise.mechanics,
                                icon: Icons.settings_outlined),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3-stat row
                        _StatsRow(exercise: widget.exercise),
                        const SizedBox(height: 16),

                        // Description
                        Text(widget.exercise.description,
                            style: AppTextStyles.body),
                        const SizedBox(height: 16),

                        // Progression chain
                        if (widget.prevExercise != null ||
                            widget.nextExercise != null)
                          _ProgressionChain(
                            current: widget.exercise,
                            prev: widget.prevExercise,
                            next: widget.nextExercise,
                            onTap: widget.onProgressionTap,
                          ),
                        const SizedBox(height: 16),

                        // Tabs
                        TabSelector(
                          tabs: const ['Instructions', 'Muscles', 'History'],
                          selected: _tab,
                          onSelect: (i) => setState(() => _tab = i),
                        ),
                        const SizedBox(height: 14),

                        // Tab content
                        if (_tab == 0)
                          _InstructionsTab(exercise: widget.exercise),
                        if (_tab == 1) _MusclesTab(exercise: widget.exercise),
                        if (_tab == 2)
                          _HistoryTab(
                              exercise: widget.exercise,
                              history: widget.history),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating back + favourite buttons
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: widget.onBack ?? () => Navigator.pop(context)),
                  const Text('Exercise Detail', style: AppTextStyles.bodyLarge),
                  _GlassButton(
                    icon: widget.isFavourite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: widget.isFavourite ? AppColors.red : null,
                    onTap: widget.onToggleFavourite,
                  ),
                ],
              ),
            ),

            // Sticky CTA
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0),
                      AppColors.background
                    ],
                    stops: const [0, 0.4],
                  ),
                ),
                child: PrimaryButton(
                  label: '+ Add to Workout',
                  icon: Icons.add_rounded,
                  color: widget.exercise.accent,
                  onTap: widget.onAddToWorkout,
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Video Player ──────────────────────────────────────────────────────────────

class _VideoPlayer extends StatelessWidget {
  final Exercise exercise;
  final bool playing;
  final VoidCallback? onToggle;
  const _VideoPlayer(
      {required this.exercise, required this.playing, this.onToggle});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onToggle,
        child: Container(
          height: 224,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: exercise.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow orb
              Container(
                width: 160,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    exercise.accent.withValues(alpha: 0.2),
                    Colors.transparent
                  ]),
                ),
              ),
              // Play button
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: playing
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: playing
                      ? []
                      : [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20)
                        ],
                ),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: playing ? Colors.white : Colors.black,
                  size: 28,
                ),
              ),
              // Demo badge
              Positioned(
                top: 14,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            color: playing
                                ? AppColors.red
                                : AppColors.textSecondary,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(playing ? 'PLAYING' : 'DEMO',
                        style: AppTextStyles.caption.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
              // Duration
              Positioned(
                top: 14,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                      exercise.defaultSetType == 'timed' ? 'Hold' : '0:45',
                      style: AppTextStyles.mono.copyWith(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8))),
                ),
              ),
              // Progress bar
              if (playing)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                      value: 0.38,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: exercise.accent,
                      minHeight: 3),
                ),
            ],
          ),
        ),
      );
}

// ── Tag Pill ──────────────────────────────────────────────────────────────────
class _TagPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _TagPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
        decoration: BoxDecoration(
            color: AppColors.elevated,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
}

// ── Stats Row ──────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final Exercise exercise;
  const _StatsRow({required this.exercise});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              child: _statBox(
                  'Primary',
                  '${exercise.primaryMuscles.length}',
                  exercise.primaryMuscles.first.split(' ').first,
                  exercise.accent)),
          const SizedBox(width: 8),
          Expanded(
              child: _statBox(
                  'Secondary',
                  '${exercise.secondaryMuscles.length}',
                  exercise.secondaryMuscles.isNotEmpty
                      ? exercise.secondaryMuscles.first.split(' ').first
                      : '—',
                  AppColors.textSecondary)),
          const SizedBox(width: 8),
          Expanded(
              child: _statBox('Your PR', exercise.pr?.primaryDisplay ?? '—',
                  exercise.force, exercise.accent)),
        ],
      );

  Widget _statBox(String label, String value, String sub, Color color) =>
      AppCard(
        padding: const EdgeInsets.fromLTRB(10, 11, 10, 8),
        child: Column(children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.caption, textAlign: TextAlign.center),
          const SizedBox(height: 5),
          Text(value,
              style: AppTextStyles.monoLarge
                  .copyWith(fontSize: 18, color: AppColors.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 3),
          Text(sub,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

// ── Progression Chain ──────────────────────────────────────────────────────────
class _ProgressionChain extends StatelessWidget {
  final Exercise current;
  final Exercise? prev;
  final Exercise? next;
  final void Function(Exercise)? onTap;
  const _ProgressionChain(
      {required this.current, this.prev, this.next, this.onTap});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
                child: _node(prev?.name ?? 'Start',
                    isPrev: true,
                    disabled: prev == null,
                    onTap: prev != null ? () => onTap?.call(prev!) : null)),
            _arrow(),
            Expanded(flex: 2, child: _currentNode()),
            _arrow(),
            Expanded(
                child: _node(next?.name ?? 'Elite',
                    isPrev: false,
                    disabled: next == null,
                    onTap: next != null ? () => onTap?.call(next!) : null)),
          ],
        ),
      );

  Widget _arrow() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Icon(Icons.arrow_forward_rounded,
            size: 14, color: AppColors.textHint),
      );

  Widget _node(String name,
          {required bool isPrev, bool disabled = false, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: disabled ? AppColors.background : AppColors.elevated,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: disabled ? AppColors.border : AppColors.border2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(isPrev ? 'PREV' : 'NEXT', style: AppTextStyles.caption),
                if (!isPrev && !disabled) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.lock_outline_rounded,
                      size: 8, color: AppColors.textHint),
                ],
              ]),
              const SizedBox(height: 3),
              Text(name,
                  style: AppTextStyles.label.copyWith(
                      color: disabled
                          ? AppColors.textHint
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );

  Widget _currentNode() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: current.accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: current.accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT',
                style: AppTextStyles.caption.copyWith(color: current.accent)),
            const SizedBox(height: 3),
            Text(current.name,
                style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w800),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}

// ── Instructions Tab ───────────────────────────────────────────────────────────
class _InstructionsTab extends StatelessWidget {
  final Exercise exercise;
  const _InstructionsTab({required this.exercise});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Steps
          ...exercise.instructions.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InstructionStep(
                      index: e.key, text: e.value, accent: exercise.accent),
                ),
              ),
          const SizedBox(height: 6),

          // Tips card
          if (exercise.tips.isNotEmpty) ...[
            _BulletCard(
              icon: Icons.star_outline_rounded,
              title: 'Pro Tips',
              items: exercise.tips,
              accent: exercise.accent,
              bgOpacity: 0.05,
            ),
            const SizedBox(height: 10),
          ],

          // Mistakes card
          if (exercise.commonMistakes.isNotEmpty)
            _BulletCard(
              icon: Icons.close_rounded,
              title: 'Common Mistakes',
              items: exercise.commonMistakes,
              accent: AppColors.red,
              bgOpacity: 0.04,
            ),
        ],
      );
}

class _BulletCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final Color accent;
  final double bgOpacity;
  const _BulletCard(
      {required this.icon,
      required this.title,
      required this.items,
      required this.accent,
      required this.bgOpacity});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: bgOpacity),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 11, color: accent),
              const SizedBox(width: 6),
              Text(title.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.08)),
            ]),
            const SizedBox(height: 10),
            ...items.asMap().entries.map((e) => Padding(
                  padding:
                      EdgeInsets.only(bottom: e.key < items.length - 1 ? 9 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 4, right: 8),
                          child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: accent, shape: BoxShape.circle))),
                      Expanded(
                          child: Text(e.value,
                              style: AppTextStyles.body
                                  .copyWith(color: const Color(0xFFD8D8D8)))),
                    ],
                  ),
                )),
          ],
        ),
      );
}

// ── Muscles Tab ────────────────────────────────────────────────────────────────
class _MusclesTab extends StatelessWidget {
  final Exercise exercise;
  const _MusclesTab({required this.exercise});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagram placeholder (real implementation uses custom painter)
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text('Muscle Activation Map',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.textHint, letterSpacing: 0.08)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BodySilhouette(
                        label: 'FRONT',
                        primaryMuscles: exercise.primaryMuscles,
                        accent: exercise.accent),
                    const SizedBox(width: 12),
                    _BodySilhouette(
                        label: 'BACK',
                        primaryMuscles: exercise.primaryMuscles,
                        accent: exercise.accent),
                  ],
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _legend(exercise.accent, 'Primary'),
                  const SizedBox(width: 20),
                  _legend(exercise.accent.withValues(alpha: 0.4), 'Secondary'),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Primary
          _musclePills(
              'Primary Muscles', exercise.primaryMuscles, exercise.accent),
          const SizedBox(height: 10),

          // Secondary
          _musclePills('Secondary Muscles', exercise.secondaryMuscles,
              AppColors.textSecondary,
              border: true),
          const SizedBox(height: 10),

          // Movement info
          AppCard(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCol('Force', exercise.force.toUpperCase()),
                  _infoCol('Mechanics', exercise.mechanics),
                  _infoCol('Set Type', exercise.setTypeLabel),
                ]),
          ),
        ],
      );

  Widget _legend(Color c, String label) => Row(children: [
        Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label,
            style:
                AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
      ]);

  Widget _musclePills(String title, List<String> muscles, Color color,
          {bool border = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style:
                  AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: muscles
                .map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: border
                            ? Colors.white.withValues(alpha: 0.06)
                            : color.withValues(alpha: 0.18),
                        border: Border.all(
                            color: border
                                ? AppColors.border
                                : color.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(m,
                          style: AppTextStyles.label.copyWith(
                              color: border ? AppColors.textSecondary : color)),
                    ))
                .toList(),
          ),
        ],
      );

  Widget _infoCol(String label, String value) => Column(children: [
        Text(label.toUpperCase(), style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontSize: 13)),
      ]);
}

// Minimal body silhouette placeholder — replace with a custom SVG painter
class _BodySilhouette extends StatelessWidget {
  final String label;
  final List<String> primaryMuscles;
  final Color accent;
  const _BodySilhouette(
      {required this.label,
      required this.primaryMuscles,
      required this.accent});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 70,
            height: 140,
            decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(35)),
            child: CustomPaint(
                painter: _SimpleSilhouettePainter(
                    accent: accent, highlight: primaryMuscles.isNotEmpty)),
          ),
          const SizedBox(height: 6),
          Text(label,
              style:
                  AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        ],
      );
}

class _SimpleSilhouettePainter extends CustomPainter {
  final Color accent;
  final bool highlight;
  const _SimpleSilhouettePainter(
      {required this.accent, required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = highlight ? accent.withValues(alpha: 0.7) : AppColors.elevated2;
    // Head
    canvas.drawCircle(Offset(size.width / 2, 16), 11, paint);
    // Torso
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.25, 30, size.width * 0.5, 48),
            const Radius.circular(8)),
        paint);
    // Arms
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.05, 30, size.width * 0.18, 38),
            const Radius.circular(6)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.77, 30, size.width * 0.18, 38),
            const Radius.circular(6)),
        paint);
    // Legs
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.24, 80, size.width * 0.22, 48),
            const Radius.circular(6)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.54, 80, size.width * 0.22, 48),
            const Radius.circular(6)),
        paint);
  }

  @override
  bool shouldRepaint(covariant _SimpleSilhouettePainter old) =>
      old.accent != accent;
}

// ── History Tab ────────────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final Exercise exercise;
  final List<ExerciseHistoryEntry> history;
  const _HistoryTab({required this.exercise, required this.history});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PR grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _prCell(
                  'Best ${exercise.defaultSetType == 'timed' ? 'Hold' : 'Set'}',
                  exercise.pr?.primaryDisplay ?? '—',
                  exercise.accent),
              _prCell('Last Trained', 'Today', AppColors.textSecondary),
              _prCell('Total Sets', '142', AppColors.textSecondary),
              _prCell('Sessions', '${history.isNotEmpty ? history.length : 28}',
                  AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 16),
          Text('Recent Sessions',
              style: AppTextStyles.h3.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          if (history.isEmpty)
            const AppCard(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: Text('No history yet', style: AppTextStyles.body)),
            )
          else
            ...history.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HistoryRow(entry: h, accent: exercise.accent),
                )),
        ],
      );

  Widget _prCell(String label, String value, Color color) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderColor: color == exercise.accent
            ? color.withValues(alpha: 0.28)
            : AppColors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.monoLarge
                    .copyWith(fontSize: 20, color: color)),
          ],
        ),
      );
}

class _HistoryRow extends StatelessWidget {
  final ExerciseHistoryEntry entry;
  final Color accent;
  const _HistoryRow({required this.entry, required this.accent});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        color: entry.isPr ? accent.withValues(alpha: 0.05) : AppColors.card,
        borderColor:
            entry.isPr ? accent.withValues(alpha: 0.28) : AppColors.border,
        child: Row(
          children: [
            if (entry.isPr)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('PR',
                    style: AppTextStyles.caption.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.05)),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.dateLabel,
                      style: AppTextStyles.label.copyWith(
                          color: entry.isPr
                              ? AppColors.textPrimary
                              : AppColors.textSecondary)),
                  if (entry.note.isNotEmpty)
                    Text(entry.note, style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(entry.valueDisplay,
                style: AppTextStyles.monoLarge.copyWith(
                    fontSize: 15,
                    color: entry.isPr ? accent : AppColors.textSecondary)),
          ],
        ),
      );
}

// ── Glass back button ──────────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  const _GlassButton({required this.icon, this.color, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, color: color ?? Colors.white, size: 20),
        ),
      );
}

// ─── Supporting model (local to this screen) ──────────────────────────────────
class ExerciseHistoryEntry {
  final String dateLabel; // "Today", "May 12"
  final String valueDisplay; // "4×12", "8.2s"
  final bool isPr;
  final String note;

  const ExerciseHistoryEntry({
    required this.dateLabel,
    required this.valueDisplay,
    this.isPr = false,
    this.note = '',
  });

  factory ExerciseHistoryEntry.fromMap(Map<String, dynamic> map) {
    return ExerciseHistoryEntry(
      dateLabel: map['dateLabel'] as String,
      valueDisplay: map['valueDisplay'] as String,
      isPr: map['isPr'] as bool? ?? false,
      note: map['note'] as String? ?? '',
    );
  }
}
