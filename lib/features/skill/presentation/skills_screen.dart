import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

// ─── SkillsScreen ─────────────────────────────────────────────────────────────
// All skill data injected. Summary counts derived from the list itself so the
// "3 active · 2 locked · 0 mastered" line is always accurate to whatever the DB returns.

class SkillsScreen extends StatefulWidget {
  final List<Skill> skills;
  final void Function(Skill)? onSkillTap;
  final void Function(Skill)? onTrainTap;
  final void Function(Skill)? onAnalyseTap;

  const SkillsScreen({
    super.key,
    required this.skills,
    this.onSkillTap,
    this.onTrainTap,
    this.onAnalyseTap,
  });

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  String _familyFilter = 'all';

  List<String> get _families {
    final fam = {'all'};
    for (final s in widget.skills) {
      fam.add(s.family);
    }
    return fam.toList();
  }

  List<Skill> get _filtered => _familyFilter == 'all'
      ? widget.skills
      : widget.skills.where((s) => s.family == _familyFilter).toList();

  int _count(SkillStatus status) =>
      widget.skills.where((s) => s.status == status).length;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progression', style: AppTextStyles.label),
                const SizedBox(height: 4),
                const Text('Skills', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Text(
                  '${_count(SkillStatus.active)} active  ·  ${_count(SkillStatus.locked)} locked  ·  ${_count(SkillStatus.mastered)} mastered',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(children: [
                  StatCard(
                    icon: const Icon(Icons.bolt_rounded,
                        color: AppColors.brand, size: 14),
                    value: '${_count(SkillStatus.active)}',
                    label: 'Active',
                    accent: AppColors.brand,
                  ),
                  const SizedBox(width: 10),
                  const StatCard(
                    icon: Icon(Icons.calendar_month_rounded,
                        color: AppColors.green, size: 14),
                    value: '47',
                    label: 'Sessions',
                    accent: AppColors.green,
                  ),
                  const SizedBox(width: 10),
                  const StatCard(
                    icon: Icon(Icons.emoji_events_rounded,
                        color: AppColors.gold, size: 14),
                    value: '12',
                    label: 'PRs Set',
                    accent: AppColors.gold,
                  ),
                ]),
                const SizedBox(height: 20),

                // Family filter chips
                FilterChips<String>(
                  options: _families,
                  selected: _familyFilter,
                  labelOf: (f) => f == 'all'
                      ? 'All Skills'
                      : f[0].toUpperCase() + f.substring(1),
                  onSelect: (f) => setState(() => _familyFilter = f),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Skill cards — scrollable
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No skills in this category',
                        style: AppTextStyles.body))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => SkillCard(
                      skill: _filtered[i],
                      onTap: () => widget.onSkillTap?.call(_filtered[i]),
                      onTrain: () => widget.onTrainTap?.call(_filtered[i]),
                      onAnalyse: () => widget.onAnalyseTap?.call(_filtered[i]),
                    ),
                  ),
          ),
        ],
      );
}

// ─── SkillDetailScreen ────────────────────────────────────────────────────────
// Full detail view for a single skill.
// Session history entries are passed in from the DB — the screen renders however
// many entries it receives.

class SkillDetailScreen extends StatefulWidget {
  final Skill skill;
  final List<SkillSessionEntry> history;
  final VoidCallback? onBack;
  final VoidCallback? onTrain;
  final VoidCallback? onAnalyse;

  const SkillDetailScreen({
    super.key,
    required this.skill,
    this.history = const [],
    this.onBack,
    this.onTrain,
    this.onAnalyse,
  });

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
              _SkillHero(
                  skill: skill,
                  onBack: widget.onBack ?? () => Navigator.pop(context)),

              // Scrollable body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      // Stats
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: _SkillStatsRow(skill: skill),
                      ),
                      const SizedBox(height: 14),

                      // Tier progress
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _TierProgressCard(skill: skill),
                      ),
                      const SizedBox(height: 14),

                      // Tab selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TabSelector(
                          tabs: const ['Instructions', 'Muscles', 'History'],
                          selected: _tab,
                          onSelect: (i) => setState(() => _tab = i),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tab content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _tab == 0
                              ? _InstructionsContent(
                                  skill: skill, key: const ValueKey(0))
                              : _tab == 1
                                  ? _MusclesContent(
                                      skill: skill, key: const ValueKey(1))
                                  : _HistoryContent(
                                      skill: skill,
                                      history: widget.history,
                                      key: const ValueKey(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky CTAs
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Train Skill',
                      icon: Icons.play_arrow_rounded,
                      color: skill.accent,
                      onTap: widget.onTrain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OutlineButton(
                        label: 'Analyse Form',
                        icon: Icons.camera_alt_outlined,
                        color: skill.accent,
                        onTap: widget.onAnalyse),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skill Hero ─────────────────────────────────────────────────────────────────
class _SkillHero extends StatelessWidget {
  final Skill skill;
  final VoidCallback onBack;
  const _SkillHero({required this.skill, required this.onBack});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: skill.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 24,
          top: 52,
        ),
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccentPill(
                    label:
                        '${skill.family} · Tier ${skill.tierIndex} of ${skill.totalTiers}',
                    accent: skill.accent,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    skill.name,
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 30,
                      letterSpacing: -1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${skill.currentTier} → ${skill.nextTier}',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Stats Row ──────────────────────────────────────────────────────────────────
class _SkillStatsRow extends StatelessWidget {
  final Skill skill;
  const _SkillStatsRow({required this.skill});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _statCard('Best', skill.bestDisplay ?? '—', skill.accent),
          const SizedBox(width: 10),
          _statCard('Target', skill.target, AppColors.textSecondary),
          const SizedBox(width: 10),
          _statCard('Progress', '${skill.progressPct}%', skill.accent),
        ],
      );

  Widget _statCard(String label, String value, Color color) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(), style: AppTextStyles.caption),
            const SizedBox(height: 3),
            Text(value,
                style: AppTextStyles.monoLarge
                    .copyWith(fontSize: 17, color: color)),
          ]),
        ),
      );
}

// ── Tier Progress Card ─────────────────────────────────────────────────────────
class _TierProgressCard extends StatelessWidget {
  final Skill skill;
  const _TierProgressCard({required this.skill});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Tier Progress  ·  ${skill.tierIndex} of ${skill.totalTiers}',
                    style: AppTextStyles.bodyLarge.copyWith(fontSize: 12)),
                Text(skill.currentTier,
                    style: AppTextStyles.label.copyWith(color: skill.accent)),
              ],
            ),
            const SizedBox(height: 12),
            TierDotsRow(
                current: skill.tierIndex,
                total: skill.totalTiers,
                accent: skill.accent,
                height: 5),
          ],
        ),
      );
}

// ── Instructions Content ───────────────────────────────────────────────────────
class _InstructionsContent extends StatelessWidget {
  final Skill skill;
  const _InstructionsContent({super.key, required this.skill});

  @override
  Widget build(BuildContext context) => Column(
        children: skill.instructions
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InstructionStep(
                    index: e.key, text: e.value, accent: skill.accent),
              ),
            )
            .toList(),
      );
}

// ── Muscles Content ────────────────────────────────────────────────────────────
class _MusclesContent extends StatelessWidget {
  final Skill skill;
  const _MusclesContent({super.key, required this.skill});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pillSection(
              'Primary Muscles', skill.primaryMuscles, skill.accent, false),
          const SizedBox(height: 10),
          _pillSection('Secondary Muscles', skill.secondaryMuscles,
              AppColors.textSecondary, true),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            color: skill.accent.withValues(alpha: 0.1),
            borderColor: skill.accent.withValues(alpha: 0.25),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hold Type',
                  style: AppTextStyles.caption.copyWith(
                      color: skill.accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.08)),
              const SizedBox(height: 8),
              Text(
                skill.isStaticHold
                    ? 'Static isometric hold — sustained position under tension.'
                    : 'Dynamic movement — reps counted through full range of motion.',
                style: AppTextStyles.body,
              ),
            ]),
          ),
        ],
      );

  Widget _pillSection(
          String title, List<String> items, Color color, bool border) =>
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
            children: items
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
}

// ── History Content ────────────────────────────────────────────────────────────
class _HistoryContent extends StatelessWidget {
  final Skill skill;
  final List<SkillSessionEntry> history;
  const _HistoryContent(
      {super.key, required this.skill, required this.history});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (history.isEmpty)
            const AppCard(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                  child: Text('No sessions logged yet',
                      style: AppTextStyles.body)),
            )
          else
            ...history.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  color: h.isPr
                      ? skill.accent.withValues(alpha: 0.05)
                      : AppColors.card,
                  borderColor: h.isPr
                      ? skill.accent.withValues(alpha: 0.28)
                      : AppColors.border,
                  child: Row(children: [
                    if (h.isPr)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            color: skill.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('PR',
                            style: AppTextStyles.caption.copyWith(
                                color: skill.accent,
                                fontWeight: FontWeight.w800)),
                      ),
                    Expanded(
                      child: Text(h.dateLabel,
                          style: AppTextStyles.label.copyWith(
                              color: h.isPr
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary)),
                    ),
                    Text(h.valueDisplay,
                        style: AppTextStyles.monoLarge.copyWith(
                            fontSize: 16,
                            color: h.isPr
                                ? skill.accent
                                : AppColors.textSecondary)),
                  ]),
                ),
              ),
            ),
        ],
      );
}

// ── Outline button ─────────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _OutlineButton(
      {required this.label,
      required this.icon,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            border: Border.all(color: color.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 7),
              Text(label,
                  style: AppTextStyles.bodyLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
            ],
          ),
        ),
      );
}

// ─── Supporting data model ────────────────────────────────────────────────────
class SkillSessionEntry {
  final String dateLabel;
  final String valueDisplay;
  final bool isPr;

  const SkillSessionEntry(
      {required this.dateLabel, required this.valueDisplay, this.isPr = false});

  factory SkillSessionEntry.fromMap(Map<String, dynamic> map) {
    return SkillSessionEntry(
      dateLabel: map['dateLabel'] as String,
      valueDisplay: map['valueDisplay'] as String,
      isPr: map['isPr'] as bool? ?? false,
    );
  }
}
