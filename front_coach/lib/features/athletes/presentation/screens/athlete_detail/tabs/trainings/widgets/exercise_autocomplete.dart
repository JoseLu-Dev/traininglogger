import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_shared/front_shared.dart';
import '../notifiers/training_detail_notifier.dart';

/// Opens a dialog for exercise + variant selection.
///
/// If [preselectedExercise] is provided the dialog skips directly to
/// variant-only mode (for the [+↓] button on an existing exercise row).
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
  final _focusNode = FocusNode();

  Exercise? _selectedExercise;
  final List<Variant> _selectedVariants = [];

  List<Exercise> _exercises = [];
  List<Variant> _allVariants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedExercise = widget.preselectedExercise;
    _loadData();
    _queryCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _focusNode.dispose();
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

  void _onQueryChanged() {
    setState(() {}); // rebuild filtered list
  }

  List<Exercise> get _filteredExercises {
    final q = _queryCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _exercises;
    return _exercises.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  Exercise? get _exactMatch {
    final q = _queryCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return null;
    return _exercises
        .where((e) => e.name.toLowerCase() == q)
        .firstOrNull;
  }

  bool _isVariantSelected(Variant v) =>
      _selectedVariants.any((s) => s.id == v.id);

  void _toggleVariant(Variant v) {
    setState(() {
      if (_isVariantSelected(v)) {
        _selectedVariants.removeWhere((s) => s.id == v.id);
      } else {
        _selectedVariants.add(v);
      }
    });
  }

  Future<void> _selectExercise(Exercise ex) async {
    setState(() {
      _selectedExercise = ex;
      _queryCtrl.text = ex.name;
    });
  }

  Future<void> _confirm() async {
    if (_selectedExercise == null) return;
    if (widget.preselectedExercisePlanId != null) {
      // Variant-only mode
      for (final v in _selectedVariants) {
        await widget.notifier.addVariantToExercise(
          widget.preselectedExercisePlanId!,
          v,
        );
      }
    } else {
      await widget.notifier.addExercise(_selectedExercise!, _selectedVariants);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _createAndSelectExercise() async {
    final name = _queryCtrl.text.trim();
    if (name.isEmpty) return;
    final ex = await widget.notifier.createExercise(name);
    if (!mounted) return;
    setState(() {
      _exercises.add(ex);
      _selectedExercise = ex;
      _queryCtrl.text = ex.name;
    });
  }

  Future<void> _createAndAddVariant() async {
    final name = _queryCtrl.text.trim();
    if (name.isEmpty) return;
    final v = await widget.notifier.createVariant(name);
    if (!mounted) return;
    setState(() {
      _allVariants.add(v);
      _selectedVariants.add(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isVariantOnly = widget.preselectedExercise != null;
    final exactMatch = _exactMatch;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title: Text(isVariantOnly
            ? 'Add variant to ${widget.preselectedExercise!.name}'
            : 'Add exercise'),
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
                    // ── Search field ───────────────────────────────────────
                    if (!isVariantOnly) ...[
                      TextField(
                        controller: _queryCtrl,
                        focusNode: _focusNode,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search exercise…',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _queryCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _queryCtrl.clear();
                                    setState(() {
                                      _selectedExercise = null;
                                      _selectedVariants.clear();
                                    });
                                  },
                                )
                              : null,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ── Selected exercise + chosen variants chips ───────────
                    if (_selectedExercise != null) ...[
                      Wrap(
                        spacing: 4,
                        children: [
                          Chip(
                            label: Text(_selectedExercise!.name),
                            backgroundColor: colorScheme.secondaryContainer,
                          ),
                          ..._selectedVariants.map((v) => Chip(
                                label: Text(v.name),
                                backgroundColor: colorScheme.tertiaryContainer,
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () => _toggleVariant(v),
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ── Dropdown results ───────────────────────────────────
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Exercise list (only when not variant-only)
                            if (!isVariantOnly && _selectedExercise == null)
                              ..._filteredExercises.map(
                                (ex) => _ExerciseRow(
                                  exercise: ex,
                                  colorScheme: colorScheme,
                                  onTap: () => _selectExercise(ex),
                                ),
                              ),

                            // Variant list (shown once exercise selected OR in variant-only mode)
                            if (_selectedExercise != null || isVariantOnly) ...[
                              if (!isVariantOnly)
                                const Divider(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'Variants',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: colorScheme.outline),
                                ),
                              ),
                              ..._allVariants.map(
                                (v) => _VariantRow(
                                  exercise: isVariantOnly
                                      ? widget.preselectedExercise!
                                      : _selectedExercise!,
                                  variant: v,
                                  isSelected: _isVariantSelected(v),
                                  colorScheme: colorScheme,
                                  onTap: () => _toggleVariant(v),
                                ),
                              ),
                            ],

                            // Divider + footer actions
                            if (!isVariantOnly && _queryCtrl.text.isNotEmpty) ...[
                              const Divider(height: 16),
                              if (_selectedExercise == null ||
                                  exactMatch == null)
                                _FooterAction(
                                  label:
                                      '+ Add new exercise "${_queryCtrl.text.trim()}"',
                                  onTap: _createAndSelectExercise,
                                ),
                            ],
                            if (_selectedExercise != null &&
                                _queryCtrl.text.isNotEmpty) ...[
                              if (!isVariantOnly) const SizedBox(height: 4),
                              _FooterAction(
                                label:
                                    '+ Add new variant "${_queryCtrl.text.trim()}"',
                                onTap: _createAndAddVariant,
                              ),
                            ],
                            if (isVariantOnly) ...[
                              const Divider(height: 16),
                              _FooterAction(
                                label:
                                    '+ Add new variant "${_queryCtrl.text.trim()}"',
                                onTap: _createAndAddVariant,
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
            onPressed: (_selectedExercise != null || isVariantOnly) &&
                    _selectedVariants.isNotEmpty
                ? _confirm
                : null,
            child: const Text('Add'),
          ),
        ],
      ),
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
  final Exercise exercise;
  final Variant variant;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _VariantRow({
    required this.exercise,
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
                exercise.name,
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
