import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── LibraryScreen ────────────────────────────────────────────────────────────
// Shows the 2-column category grid.
// categories are injected — count + colours come from whatever source (Firestore,
// local cache, etc.) — this widget doesn't care.

class LibraryScreen extends StatefulWidget {
  final List<ExerciseCategory> categories;
  final void Function(ExerciseCategory)? onCategoryTap;

  const LibraryScreen({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _search = '';

  List<ExerciseCategory> get _filtered => widget.categories
      .where((c) =>
          c.name.toLowerCase().contains(_search.toLowerCase()) ||
          c.tag.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Header + search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cobrasthenics', style: AppTextStyles.label),
                const SizedBox(height: 4),
                const Text('Exercise Library', style: AppTextStyles.h1),
                const SizedBox(height: 20),
                AppSearchBar(
                    hint: 'Search muscles, movements...',
                    onChanged: (v) => setState(() => _search = v)),
                const SizedBox(height: 12),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_filtered.length} categories',
                          style: AppTextStyles.caption
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text(
                          '${widget.categories.fold(0, (s, c) => s + c.exerciseCount)}+ exercises',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ]),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Grid — scrollable
          Expanded(
            child: _filtered.isEmpty
                ? _EmptyState(query: _search)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _CategoryCard(
                      category: _filtered[i],
                      onTap: () => widget.onCategoryTap?.call(_filtered[i]),
                    ),
                  ),
          ),
        ],
      );
}

class _CategoryCard extends StatelessWidget {
  final ExerciseCategory category;
  final VoidCallback? onTap;
  const _CategoryCard({required this.category, this.onTap});

  @override
  Widget build(BuildContext context) => GradientCard(
        colors: category.colors,
        accent: category.accent,
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            // count badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${category.exerciseCount}',
                    style: AppTextStyles.label
                        .copyWith(color: Colors.white.withValues(alpha: 0.7))),
              ),
            ),
            // tag pill
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: category.accent.withValues(alpha: 0.2),
                  border: Border.all(
                      color: category.accent.withValues(alpha: 0.44)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(category.tag.toUpperCase(),
                    style: AppTextStyles.pill.copyWith(color: category.accent)),
              ),
            ),
            // bottom gradient + name
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7)
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name,
                        style: AppTextStyles.h2
                            .copyWith(fontSize: 22, letterSpacing: -0.8)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                              color: category.accent, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('${category.exerciseCount} exercises',
                          style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.55))),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                color: AppColors.textHint, size: 44),
            const SizedBox(height: 12),
            Text('No results for "$query"',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
}

// ─── CategoryScreen ───────────────────────────────────────────────────────────
// Shows the exercise list within a category.
// exercises: full list for this category. Screen handles local search + filter.

class CategoryScreen extends StatefulWidget {
  final ExerciseCategory category;
  final List<Exercise> exercises;
  final void Function(Exercise)? onExerciseTap;
  final VoidCallback? onBack;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.exercises,
    this.onExerciseTap,
    this.onBack,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _search = '';
  String _diffFilter = 'all';

  List<Exercise> get _filtered {
    var list = widget.exercises;
    if (_search.isNotEmpty) {
      list = list
          .where((e) => e.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    if (_diffFilter != 'all') {
      list = list.where((e) => e.difficulty == _diffFilter).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Hero header
            _CategoryHero(category: widget.category, onBack: widget.onBack),

            // Search + filters
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: AppSearchBar(
                hint: 'Search ${widget.category.name}...',
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilterChips<String>(
                options: const [
                  'all',
                  'beginner',
                  'intermediate',
                  'advanced',
                  'elite'
                ],
                selected: _diffFilter,
                labelOf: (s) =>
                    s == 'all' ? 'All' : s[0].toUpperCase() + s.substring(1),
                onSelect: (v) => setState(() => _diffFilter = v),
              ),
            ),
            const SizedBox(height: 4),

            // Count label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filtered.length} exercise${_filtered.length != 1 ? 's' : ''}',
                  style: AppTextStyles.caption
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Exercise list
            Expanded(
              child: _filtered.isEmpty
                  ? _CategoryEmpty(query: _search)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => ExerciseTile(
                        exercise: _filtered[i],
                        onTap: () => widget.onExerciseTap?.call(_filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      );
}

class _CategoryHero extends StatelessWidget {
  final ExerciseCategory category;
  final VoidCallback? onBack;
  const _CategoryHero({required this.category, this.onBack});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 28,
          top: MediaQuery.of(context).padding.top + 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Row(children: [
              GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Text('Library',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white)),
            ]),
            const SizedBox(height: 20),
            Text(
              '${category.tag.toUpperCase()} · ${category.exerciseCount} Exercises',
              style: AppTextStyles.pill
                  .copyWith(color: category.accent, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Text(category.name,
                style: AppTextStyles.h1.copyWith(
                    fontSize: 32, letterSpacing: -1.6, color: Colors.white)),
          ],
        ),
      );
}

class _CategoryEmpty extends StatelessWidget {
  final String query;
  const _CategoryEmpty({required this.query});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded,
                  color: AppColors.textHint, size: 36),
              const SizedBox(height: 12),
              Text(
                query.isEmpty
                    ? 'No exercises match the selected filter'
                    : 'No results for "$query"',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
