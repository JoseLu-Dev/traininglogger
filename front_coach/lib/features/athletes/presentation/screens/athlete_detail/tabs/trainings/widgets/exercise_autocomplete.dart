import 'package:flutter/material.dart';
import 'package:front_shared/front_shared.dart';
import '../notifiers/training_detail_notifier.dart';

/// Opens a dialog for exercise + variant selection.
///
/// Normal mode  : type to search exercises; once the query is a prefix of an
///                exercise name, variant rows appear below automatically.
///                Continuing to type filters variants by the remaining suffix.
///
/// Variant-only : [preselectedExercise] / [preselectedExercisePlanId] are set.
///                Text field filters variants directly; no exercise search.
Future<void> showExerciseAutocomplete(
  BuildContext context, {
  required TrainingDetailNotifier notifier,
  Exercise? preselectedExercise,
  String? preselectedExercisePlanId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ExerciseAutocompleteDialog(
      notifier: notifier,
      preselectedExercise: preselectedExercise,
      preselectedExercisePlanId: preselectedExercisePlanId,
    ),
  );
}

// ---------------------------------------------------------------------------

class _ExerciseAutocompleteDialog extends StatefulWidget {
  final TrainingDetailNotifier notifier;
  final Exercise? preselectedExercise;
  final String? preselectedExercisePlanId;

  const _ExerciseAutocompleteDialog({
    required this.notifier,
    this.preselectedExercise,
    this.preselectedExercisePlanId,
  });

  @override
  State<_ExerciseAutocompleteDialog> createState() =>
      _ExerciseAutocompleteDialogState();
}

class _ExerciseAutocompleteDialogState
    extends State<_ExerciseAutocompleteDialog> {
  final _queryCtrl = TextEditingController();
  final List<Variant> _selectedVariants = [];

  List<Exercise> _exercises = [];
  List<Variant> _allVariants = [];
  bool _loading = true;

  bool get _isVariantOnly => widget.preselectedExercise != null;

  @override
  void initState() {
    super.initState();
    _loadData();
    _queryCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final exercises = await widget.notifier.searchExercises('');
    final variants = await widget.notifier.allVariants();
    if (!mounted) return;
    setState(() {
      _exercises = exercises;
      _allVariants = variants;
      _loading = false;
    });
  }

  void _onQueryChanged() => setState(() {});

  // ── Derived getters ────────────────────────────────────────────────────────

  /// Longest exercise whose name is a case-insensitive prefix of the query.
  /// Returns the preselected exercise in variant-only mode.
  Exercise? get _matchedExercise {
    if (_isVariantOnly) return widget.preselectedExercise;
    final q = _queryCtrl.text;
    if (q.isEmpty) return null;
    Exercise? best;
    for (final ex in _exercises) {
      if (q.toLowerCase().startsWith(ex.name.toLowerCase())) {
        if (best == null || ex.name.length > best.name.length) {
          best = ex;
        }
      }
    }
    return best;
  }

  /// Text after the matched exercise name — used to filter variants.
  String get _variantFilter {
    if (_isVariantOnly) return _queryCtrl.text.trim();
    final match = _matchedExercise;
    if (match == null) return '';
    return _queryCtrl.text.substring(match.name.length).trim();
  }

  /// Exercise rows to display in the dropdown.
  List<Exercise> get _filteredExercises {
    if (_isVariantOnly) return [];
    final match = _matchedExercise;
    // When there's a prefix match, show only that exercise (not the full list)
    if (match != null) return [match];
    final q = _queryCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _exercises;
    return _exercises.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  /// Variant rows to display — only when an exercise is matched (or variant-only).
  List<Variant> get _filteredVariants {
    if (!_isVariantOnly && _matchedExercise == null) return [];
    final filter = _variantFilter.toLowerCase();
    if (filter.isEmpty) return _allVariants;
    return _allVariants
        .where((v) => v.name.toLowerCase().contains(filter))
        .toList();
  }

  bool _isSelected(Variant v) => _selectedVariants.any((s) => s.id == v.id);

  void _toggleVariant(Variant v) => setState(() {
        if (_isSelected(v)) {
          _selectedVariants.removeWhere((s) => s.id == v.id);
        } else {
          _selectedVariants.add(v);
        }
      });

  /// Clicking an exercise row fills the text field with the exercise name,
  /// which triggers the prefix-match and makes variant rows appear.
  void _pickExercise(Exercise ex) {
    setState(() => _queryCtrl.text = ex.name);
  }

  Future<void> _confirm() async {
    if (_isVariantOnly) {
      for (final v in _selectedVariants) {
        await widget.notifier
            .addVariantToExercise(widget.preselectedExercisePlanId!, v);
      }
    } else {
      final ex = _matchedExercise;
      if (ex == null) return;
      await widget.notifier.addExercise(ex, _selectedVariants);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _createExercise() async {
    final name = _queryCtrl.text.trim();
    if (name.isEmpty) return;
    final ex = await widget.notifier.createExercise(name);
    if (!mounted) return;
    setState(() {
      _exercises.add(ex);
      _queryCtrl.text = ex.name;
    });
  }

  Future<void> _createVariant() async {
    final name = _variantFilter.trim().isNotEmpty
        ? _variantFilter.trim()
        : _queryCtrl.text.trim();
    if (name.isEmpty) return;
    final v = await widget.notifier.createVariant(name);
    if (!mounted) return;
    setState(() {
      _allVariants.add(v);
      _selectedVariants.add(v);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final matchedEx = _matchedExercise;
    final filteredExercises = _filteredExercises;
    final filteredVariants = _filteredVariants;
    final query = _queryCtrl.text.trim();
    final variantFilter = _variantFilter;
    final showVariants = _isVariantOnly || matchedEx != null;

    // Add is enabled once an exercise is identified (variants are optional).
    // In variant-only mode at least one variant must be chosen.
    final canConfirm =
        _isVariantOnly ? _selectedVariants.isNotEmpty : matchedEx != null;

    return AlertDialog(
      title: Text(
        _isVariantOnly
            ? 'Add variant to ${widget.preselectedExercise!.name}'
            : 'Add exercise',
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: 420,
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Selected variant chips ─────────────────────────────────
                  if (_selectedVariants.isNotEmpty) ...[
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _selectedVariants
                          .map((v) => Chip(
                                label: Text(
                                  v.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: colorScheme.tertiaryContainer,
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () => _toggleVariant(v),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // ── Search / filter field ──────────────────────────────────
                  TextField(
                    controller: _queryCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: _isVariantOnly
                          ? 'Filter variants…'
                          : 'Search exercise…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _queryCtrl.clear();
                                _selectedVariants.clear();
                              }),
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Dropdown ───────────────────────────────────────────────
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise rows (normal mode only, hidden once a
                          // prefix match is found and only variants are shown)
                          if (!_isVariantOnly)
                            ...filteredExercises.map(
                              (ex) => _ExerciseRow(
                                exercise: ex,
                                colorScheme: colorScheme,
                                onTap: () => _pickExercise(ex),
                              ),
                            ),

                          // Variant section — appears automatically once the
                          // query matches an exercise prefix
                          if (showVariants) ...[
                            if (!_isVariantOnly &&
                                filteredExercises.isNotEmpty)
                              const Divider(height: 12),
                            if (filteredVariants.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  variantFilter.isNotEmpty
                                      ? 'No variants match "$variantFilter"'
                                      : 'No variants available',
                                  style: TextStyle(
                                    color: colorScheme.outline,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else
                              ...filteredVariants.map(
                                (v) => _VariantRow(
                                  exerciseName: _isVariantOnly
                                      ? widget.preselectedExercise!.name
                                      : matchedEx!.name,
                                  variant: v,
                                  isSelected: _isSelected(v),
                                  colorScheme: colorScheme,
                                  onTap: () => _toggleVariant(v),
                                ),
                              ),
                          ],

                          // Footer: create new exercise (only before a match)
                          if (!_isVariantOnly &&
                              matchedEx == null &&
                              query.isNotEmpty) ...[
                            const Divider(height: 16),
                            _FooterAction(
                              label: '+ Add new exercise "$query"',
                              onTap: _createExercise,
                            ),
                          ],

                          // Footer: create new variant (once exercise matched)
                          if (showVariants && variantFilter.isNotEmpty) ...[
                            const Divider(height: 16),
                            _FooterAction(
                              label: '+ Add new variant "$variantFilter"',
                              onTap: _createVariant,
                            ),
                          ],

                          // Footer: create variant in variant-only mode with no filter
                          if (_isVariantOnly &&
                              variantFilter.isEmpty &&
                              query.isNotEmpty) ...[
                            const Divider(height: 16),
                            _FooterAction(
                              label: '+ Add new variant "$query"',
                              onTap: _createVariant,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canConfirm ? _confirm : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Row widgets
// ---------------------------------------------------------------------------

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ExerciseRow({
    required this.exercise,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'exercise',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(exercise.name)),
          ],
        ),
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final String exerciseName;
  final Variant variant;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _VariantRow({
    required this.exerciseName,
    required this.variant,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                exerciseName,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    variant.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onTertiaryContainer,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check,
                      size: 12,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
