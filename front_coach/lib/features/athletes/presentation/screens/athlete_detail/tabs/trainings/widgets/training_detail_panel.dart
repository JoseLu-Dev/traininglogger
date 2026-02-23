import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../models/exercise_detail_data.dart';
import '../notifiers/training_detail_notifier.dart';
import '../notifiers/trainings_calendar_notifier.dart';
import '../providers/training_detail_providers.dart';
import '../providers/trainings_calendar_providers.dart';
import 'exercise_autocomplete.dart';

class TrainingDetailPanel extends ConsumerStatefulWidget {
  final String athleteId;
  const TrainingDetailPanel({super.key, required this.athleteId});

  @override
  ConsumerState<TrainingDetailPanel> createState() =>
      _TrainingDetailPanelState();
}

class _TrainingDetailPanelState extends ConsumerState<TrainingDetailPanel> {
  String? _loadedDateKey;

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(
      trainingsCalendarProvider(widget.athleteId),
    );
    final detailNotifier = ref.read(
      trainingDetailProvider(widget.athleteId).notifier,
    );
    final detailState = ref.watch(trainingDetailProvider(widget.athleteId));

    // React to calendar selection changes
    calendarState.maybeWhen(
      loaded: (plansByDate, sessionsByDate, focusedMonth, selectedDate) {
        if (selectedDate != _loadedDateKey) {
          _loadedDateKey = selectedDate;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (selectedDate == null) {
              detailNotifier.reset();
            } else {
              final plan = plansByDate[selectedDate];
              if (plan != null) {
                detailNotifier.loadDate(selectedDate, plan);
              } else {
                detailNotifier.reset();
              }
            }
          });
        }
      },
      orElse: () {},
    );

    return detailState.when(
      empty: () => _EmptyState(),
      loading: () => const Center(child: CircularProgressIndicator()),
      editionMode: (plan, exercises) => _EditionView(
        athleteId: widget.athleteId,
        plan: plan,
        exercises: exercises,
        notifier: detailNotifier,
        calendarNotifier: ref.read(
          trainingsCalendarProvider(widget.athleteId).notifier,
        ),
        onDeleted: () {
          _loadedDateKey = null;
        },
      ),
      seeMode: (plan, session, exercises) => _SeeView(
        athleteId: widget.athleteId,
        plan: plan,
        session: session,
        exercises: exercises,
        notifier: detailNotifier,
        calendarNotifier: ref.read(
          trainingsCalendarProvider(widget.athleteId).notifier,
        ),
        onDeleted: () {
          _loadedDateKey = null;
        },
      ),
      error: (msg) => Center(
        child: Text('Error: $msg', style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a training day\nto view its details',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared header helpers
// ---------------------------------------------------------------------------

String _formatDate(String dateKey) {
  try {
    final parts = dateKey.split('-');
    final dt = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    // weekday: 1=Mon … 7=Sun
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  } catch (_) {
    return dateKey;
  }
}

// ---------------------------------------------------------------------------
// Copy dialog (shared by edition and see views)
// ---------------------------------------------------------------------------

Future<void> _showCopyDialog(
  BuildContext context,
  TrainingDetailNotifier notifier,
  TrainingsCalendarNotifier calendarNotifier, {
  required bool hasSession,
}) async {
  DateTime? selectedDate;
  bool fromSession = true;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final dateLabel = selectedDate == null
            ? 'No date selected'
            : _formatDate(
                '${selectedDate!.year.toString().padLeft(4, '0')}-'
                '${selectedDate!.month.toString().padLeft(2, '0')}-'
                '${selectedDate!.day.toString().padLeft(2, '0')}',
              );
        return AlertDialog(
          title: const Text('Copy training to…'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(dateLabel)),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: const Text('Pick date'),
                  ),
                ],
              ),
              if (hasSession) ...[
                const SizedBox(height: 16),
                const Text('Copy from:'),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Plan targets')),
                    ButtonSegment(value: true, label: Text('Session actuals')),
                  ],
                  selected: {fromSession},
                  onSelectionChanged: (v) =>
                      setDialogState(() => fromSession = v.first),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  selectedDate == null ? null : () => Navigator.pop(ctx, true),
              child: const Text('Copy'),
            ),
          ],
        );
      },
    ),
  );

  if (confirmed != true || selectedDate == null) return;

  final targetDate =
      '${selectedDate!.year.toString().padLeft(4, '0')}-'
      '${selectedDate!.month.toString().padLeft(2, '0')}-'
      '${selectedDate!.day.toString().padLeft(2, '0')}';

  final success = await notifier.copyToDate(
    targetDate,
    fromSession: fromSession,
  );

  await calendarNotifier.loadMonth(selectedDate!);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Training copied successfully'
              : 'A training already exists on that date',
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edition view
// ---------------------------------------------------------------------------

class _EditionView extends StatefulWidget {
  final String athleteId;
  final TrainingPlan plan;
  final List<ExerciseDetailData> exercises;
  final TrainingDetailNotifier notifier;
  final TrainingsCalendarNotifier calendarNotifier;
  final VoidCallback onDeleted;

  const _EditionView({
    required this.athleteId,
    required this.plan,
    required this.exercises,
    required this.notifier,
    required this.calendarNotifier,
    required this.onDeleted,
  });

  @override
  State<_EditionView> createState() => _EditionViewState();
}

class _EditionViewState extends State<_EditionView> {
  bool _editingName = false;
  late TextEditingController _nameCtrl;
  final Set<String> _collapsedIds = {};

  bool get _allCollapsed =>
      widget.exercises.isNotEmpty &&
      widget.exercises.every((e) => _collapsedIds.contains(e.plan.id));

  void _toggleCollapseAll() => setState(() {
        if (_allCollapsed) {
          _collapsedIds.clear();
        } else {
          _collapsedIds.addAll(widget.exercises.map((e) => e.plan.id));
        }
      });

  void _toggleCollapse(String id) => setState(() {
        if (_collapsedIds.contains(id)) {
          _collapsedIds.remove(id);
        } else {
          _collapsedIds.add(id);
        }
      });

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.plan.name);
  }

  @override
  void didUpdateWidget(_EditionView old) {
    super.didUpdateWidget(old);
    if (old.plan.name != widget.plan.name && !_editingName) {
      _nameCtrl.text = widget.plan.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _deletePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete training?'),
        content: Text('Delete "${widget.plan.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onDeleted();
      widget.notifier.reset();
      await widget.calendarNotifier.deleteTraining(widget.plan.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────────
          Row(
            children: [
              Text(
                _formatDate(widget.plan.date),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: colorScheme.outline),
              ),
              const Spacer(),
              IconButton(
                tooltip: _allCollapsed ? 'Expand all' : 'Collapse all',
                icon: Icon(
                  _allCollapsed ? Icons.unfold_more : Icons.unfold_less,
                  size: 20,
                ),
                onPressed: widget.exercises.isEmpty ? null : _toggleCollapseAll,
              ),
              IconButton(
                tooltip: 'Copy training',
                icon: const Icon(Icons.copy_outlined),
                onPressed: () => _showCopyDialog(
                  context,
                  widget.notifier,
                  widget.calendarNotifier,
                  hasSession: false,
                ),
              ),
              IconButton(
                tooltip: 'Delete training',
                onPressed: _deletePlan,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),

          // ── Plan name (editable) ────────────────────────────────────────
          if (_editingName)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                    onSubmitted: (v) async {
                      final trimmed = v.trim();
                      if (trimmed.isNotEmpty) {
                        await widget.notifier.renamePlan(trimmed);
                      }
                      setState(() => _editingName = false);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _editingName = false),
                  icon: const Icon(Icons.close),
                ),
              ],
            )
          else
            InkWell(
              onTap: () => setState(() {
                _nameCtrl.text = widget.plan.name;
                _editingName = true;
              }),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      widget.plan.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),

          const Divider(height: 20),

          // ── Exercise list ──────────────────────────────────────────────
          _ExerciseList(
            exercises: widget.exercises,
            notifier: widget.notifier,
            collapsedIds: _collapsedIds,
            onToggleCollapse: _toggleCollapse,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise list (reorderable)
// ---------------------------------------------------------------------------

class _ExerciseList extends StatelessWidget {
  final List<ExerciseDetailData> exercises;
  final TrainingDetailNotifier notifier;
  final Set<String> collapsedIds;
  final void Function(String) onToggleCollapse;

  const _ExerciseList({
    required this.exercises,
    required this.notifier,
    required this.collapsedIds,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: notifier.reorderExercise,
      footer: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: _AddExerciseButton(notifier: notifier),
      ),
      children: [
        for (int i = 0; i < exercises.length; i++)
          _ExerciseCard(
            key: ValueKey(exercises[i].plan.id),
            data: exercises[i],
            notifier: notifier,
            isCollapsed: collapsedIds.contains(exercises[i].plan.id),
            onToggleCollapse: () => onToggleCollapse(exercises[i].plan.id),
            index: i,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise card
// ---------------------------------------------------------------------------

class _ExerciseCard extends StatefulWidget {
  final ExerciseDetailData data;
  final TrainingDetailNotifier notifier;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final int index;

  const _ExerciseCard({
    super.key,
    required this.data,
    required this.notifier,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.index,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  late TextEditingController _countCtrl;

  @override
  void initState() {
    super.initState();
    _countCtrl = TextEditingController(
      text: widget.data.sets.length.toString(),
    );
  }

  @override
  void didUpdateWidget(_ExerciseCard old) {
    super.didUpdateWidget(old);
    if (old.data.sets.length != widget.data.sets.length) {
      _countCtrl.text = widget.data.sets.length.toString();
    }
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  Future<void> _applySetCount() async {
    final newCount = int.tryParse(_countCtrl.text);
    if (newCount == null || newCount < 0) {
      _countCtrl.text = widget.data.sets.length.toString();
      return;
    }
    final current = widget.data.sets.length;
    final epId = widget.data.plan.id;
    if (newCount > current) {
      for (int i = 0; i < newCount - current; i++) {
        await widget.notifier.addSet(epId);
      }
    } else if (newCount < current) {
      final toDelete = widget.data.sets.reversed
          .take(current - newCount)
          .toList();
      for (final s in toDelete) {
        await widget.notifier.deleteSet(s.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = widget.data.plan;
    final notifier = widget.notifier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Exercise header row ──────────────────────────────────────
            Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Icon(Icons.drag_indicator),
                ),
                const SizedBox(width: 8),
                // Set count input
                SizedBox(
                  width: 38,
                  child: TextField(
                    controller: _countCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onEditingComplete: _applySetCount,
                    onTapOutside: (_) => _applySetCount(),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.data.exercise.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                // Variant chips
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children: [
                      ...widget.data.variants.map(
                        (v) => _VariantChip(
                          label: v.name,
                          onRemove: () =>
                              notifier.removeVariantFromExercise(ep.id, v.id),
                        ),
                      ),
                      ActionChip(
                        label: const Text('+↓'),
                        onPressed: () => showExerciseAutocomplete(
                          context,
                          notifier: notifier,
                          initialQuery: widget.data.exercise.name,
                          preselectedExercisePlanId: ep.id,
                          initialVariants: widget.data.variants,
                        ),
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.isCollapsed
                        ? Icons.expand_more
                        : Icons.expand_less,
                    size: 18,
                  ),
                  onPressed: widget.onToggleCollapse,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  tooltip: 'Delete exercise',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete exercise?'),
                        content: Text(
                          'Delete "${widget.data.exercise.name}"? This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      notifier.deleteExercise(ep.id);
                    }
                  },
                ),
              ],
            ),

            if (!widget.isCollapsed) ...[
              const SizedBox(height: 8),

              // ── Set table ───────────────────────────────────────────────
              _SetTable(exerciseData: widget.data, notifier: notifier),

              const SizedBox(height: 8),

              // ── Notes field ─────────────────────────────────────────────
              _NotesField(
                initialValue: ep.notes ?? '',
                onChanged: (v) async {
                  await notifier.updateExerciseNotes(ep.id, v);
                },
              ),
            ],
          ],
        ),
      ),
    ],
    );
  }
}

class _VariantChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _VariantChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onRemove,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

// ---------------------------------------------------------------------------
// Set table (edition mode)
// ---------------------------------------------------------------------------

class _SetTable extends StatelessWidget {
  final ExerciseDetailData exerciseData;
  final TrainingDetailNotifier notifier;

  const _SetTable({required this.exerciseData, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final sets = exerciseData.sets;
    final epId = exerciseData.plan.id;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              const SizedBox(width: 22), // drag handle (18) + gap (4)
              _headerCell('REPS', 60),
              _headerCell('WEIGHT', 70),
              _headerCell('RPE', 50),
              _headerCell('NOTES', 100),
              const SizedBox(width: 64), // copy + delete buttons
            ],
          ),
        ),

        // Reorderable set rows
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (oldIdx, newIdx) =>
              notifier.reorderSet(epId, oldIdx, newIdx),
          children: [
            for (int i = 0; i < sets.length; i++)
              _SetRow(
                key: ValueKey(sets[i].id),
                set: sets[i],
                index: i,
                notifier: notifier,
                onCopyBelow: i < sets.length - 1
                    ? (reps, weight, rpe, notes) {
                        for (int j = i + 1; j < sets.length; j++) {
                          notifier.updateSet(sets[j].copyWith(
                            targetReps: reps,
                            targetWeight: weight,
                            targetRpe: rpe,
                            notes: notes,
                          ));
                        }
                      }
                    : null,
              ),
          ],
        ),

        // Add set button
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => notifier.addSet(epId),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Set'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final SetPlan set;
  final int index;
  final TrainingDetailNotifier notifier;
  final void Function(int? reps, double? weight, double? rpe, String? notes)?
      onCopyBelow;

  const _SetRow({
    super.key,
    required this.set,
    required this.index,
    required this.notifier,
    this.onCopyBelow,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _repsCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _rpeCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _repsCtrl = TextEditingController(
      text: widget.set.targetReps?.toString() ?? '',
    );
    _weightCtrl = TextEditingController(
      text: widget.set.targetWeight?.toString() ?? '',
    );
    _rpeCtrl = TextEditingController(
      text: widget.set.targetRpe?.toString() ?? '',
    );
    _notesCtrl = TextEditingController(text: widget.set.notes ?? '');
  }

  @override
  void didUpdateWidget(_SetRow old) {
    super.didUpdateWidget(old);
    final o = old.set;
    final s = widget.set;
    if (o.id != s.id ||
        o.targetReps != s.targetReps ||
        o.targetWeight != s.targetWeight ||
        o.targetRpe != s.targetRpe ||
        o.notes != s.notes) {
      _repsCtrl.text = s.targetReps?.toString() ?? '';
      _weightCtrl.text = s.targetWeight?.toString() ?? '';
      _rpeCtrl.text = s.targetRpe?.toString() ?? '';
      _notesCtrl.text = s.notes ?? '';
    }
  }

  @override
  void dispose() {
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    _rpeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.notifier.updateSet(
      widget.set.copyWith(
        targetReps: int.tryParse(_repsCtrl.text),
        targetWeight: double.tryParse(_weightCtrl.text),
        targetRpe: double.tryParse(_rpeCtrl.text),
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: const Icon(Icons.drag_indicator, size: 18),
          ),
          const SizedBox(width: 4),
          _numField(_repsCtrl, 60),
          _numField(_weightCtrl, 70),
          _numField(_rpeCtrl, 50),
          SizedBox(width: 100, child: _compactTextField(_notesCtrl, hint: '')),
          IconButton(
            tooltip: 'Copy to sets below',
            icon: const Icon(Icons.content_copy, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: widget.onCopyBelow == null
                ? null
                : () => widget.onCopyBelow!(
                      int.tryParse(_repsCtrl.text),
                      double.tryParse(_weightCtrl.text),
                      double.tryParse(_rpeCtrl.text),
                      _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
                    ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete set?'),
                  content: Text(
                    'Delete set ${widget.index + 1}? This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                widget.notifier.deleteSet(widget.set.id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _compactTextField(ctrl),
      ),
    );
  }

  Widget _compactTextField(TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      onEditingComplete: _save,
      onTapOutside: (_) => _save(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        border: const OutlineInputBorder(),
        hintText: hint,
      ),
      style: const TextStyle(fontSize: 12),
    );
  }
}

// ---------------------------------------------------------------------------
// Notes field (exercise-level)
// ---------------------------------------------------------------------------

class _NotesField extends StatefulWidget {
  final String initialValue;
  final void Function(String) onChanged;

  const _NotesField({required this.initialValue, required this.onChanged});

  @override
  State<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<_NotesField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Notes: ',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: TextField(
            controller: _ctrl,
            onEditingComplete: () => widget.onChanged(_ctrl.text),
            onTapOutside: (_) => widget.onChanged(_ctrl.text),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Add exercise button
// ---------------------------------------------------------------------------

class _AddExerciseButton extends StatelessWidget {
  final TrainingDetailNotifier notifier;

  const _AddExerciseButton({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => showExerciseAutocomplete(context, notifier: notifier),
      icon: const Icon(Icons.add),
      label: const Text('Add exercise…'),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
    );
  }
}

// ---------------------------------------------------------------------------
// See view (locked / session)
// ---------------------------------------------------------------------------

class _SeeView extends StatelessWidget {
  final String athleteId;
  final TrainingPlan plan;
  final TrainingSession? session;
  final List<ExerciseDetailData> exercises;
  final TrainingDetailNotifier notifier;
  final TrainingsCalendarNotifier calendarNotifier;
  final VoidCallback onDeleted;

  const _SeeView({
    required this.athleteId,
    required this.plan,
    required this.session,
    required this.exercises,
    required this.notifier,
    required this.calendarNotifier,
    required this.onDeleted,
  });

  Future<void> _deletePlan(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete training?'),
        content: Text('Delete "${plan.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onDeleted();
      notifier.reset();
      await calendarNotifier.deleteTraining(plan.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                _formatDate(plan.date),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: colorScheme.outline),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Copy training',
                icon: const Icon(Icons.copy_outlined),
                onPressed: () => _showCopyDialog(
                  context,
                  notifier,
                  calendarNotifier,
                  hasSession: session != null,
                ),
              ),
            ],
          ),

          // ── Plan name + locked badge ───────────────────────────────────
          Row(
            children: [
              Text(plan.name, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LOCKED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // ── Body ──────────────────────────────────────────────────────
          session == null && exercises.every((e) => e.session == null)
              ? _NoSessionPlaceholder()
              : _SeeExerciseList(exercises: exercises),
        ],
      ),
    );
  }
}

class _NoSessionPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 48,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No session recorded\nfor this training',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _SeeExerciseList extends StatelessWidget {
  final List<ExerciseDetailData> exercises;

  const _SeeExerciseList({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      itemBuilder: (ctx, i) => _SeeExerciseCard(data: exercises[i]),
    );
  }
}

class _SeeExerciseCard extends StatelessWidget {
  final ExerciseDetailData data;

  const _SeeExerciseCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ep = data.plan;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name + variants
            Row(
              children: [
                Text(
                  '${ep.orderIndex + 1}. ${data.exercise.name}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 4,
                  children: data.variants
                      .map(
                        (v) => Chip(
                          label: Text(
                            v.name,
                            style: const TextStyle(fontSize: 11),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Notes row (plan vs session) if either non-empty
            if ((ep.notes?.isNotEmpty == true) ||
                (data.session?.notes?.isNotEmpty == true))
              _NotesComparisonRow(
                planNote: ep.notes,
                sessionNote: data.session?.notes,
                colorScheme: colorScheme,
              ),

            // Table header
            _TableHeader(colorScheme: colorScheme),

            // Set rows
            ...data.sets.asMap().entries.map((entry) {
              final setPlan = entry.value;
              final setSession = data.sessionSets
                  .where((ss) => ss.setPlanId == setPlan.id)
                  .firstOrNull;
              final hasNote =
                  (setPlan.notes?.isNotEmpty == true) ||
                  (setSession?.notes?.isNotEmpty == true);
              return Column(
                children: [
                  _SetComparisonRow(
                    setNumber: setPlan.setNumber ?? (entry.key + 1),
                    plan: setPlan,
                    session: setSession,
                    colorScheme: colorScheme,
                  ),
                  if (hasNote)
                    _SetNoteRow(
                      planNote: setPlan.notes,
                      sessionNote: setSession?.notes,
                      colorScheme: colorScheme,
                    ),
                ],
              );
            }),

            // Extra session sets without a plan counterpart
            ...data.sessionSets
                .where(
                  (ss) =>
                      ss.setPlanId == null ||
                      !data.sets.any((sp) => sp.id == ss.setPlanId),
                )
                .map(
                  (ss) => _SetComparisonRow(
                    setNumber: ss.setNumber ?? 0,
                    plan: null,
                    session: ss,
                    colorScheme: colorScheme,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _NotesComparisonRow extends StatelessWidget {
  final String? planNote;
  final String? sessionNote;
  final ColorScheme colorScheme;

  const _NotesComparisonRow({
    required this.planNote,
    required this.sessionNote,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: planNote?.isNotEmpty == true
                ? Text(
                    '📝 $planNote',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Container(
            width: 1,
            height: 20,
            color: colorScheme.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: sessionNote?.isNotEmpty == true
                ? Text(
                    '🗣 $sessionNote',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final ColorScheme colorScheme;

  const _TableHeader({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _hCell('#', 30),
          const Expanded(
            flex: 3,
            child: Row(
              children: [
                _HCellFlex('REPS'),
                _HCellFlex('WT'),
                _HCellFlex('RPE'),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 16,
            color: Colors.black54,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const Expanded(
            flex: 3,
            child: Row(
              children: [
                _HCellFlex('REPS'),
                _HCellFlex('WT'),
                _HCellFlex('RPE'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HCellFlex extends StatelessWidget {
  final String text;
  const _HCellFlex(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SetComparisonRow extends StatelessWidget {
  final int setNumber;
  final SetPlan? plan;
  final SetSession? session;
  final ColorScheme colorScheme;

  const _SetComparisonRow({
    required this.setNumber,
    required this.plan,
    required this.session,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    String fmt(num? v) => v?.toString() ?? '—';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$setNumber',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          // Target
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _valueCell(fmt(plan?.targetReps)),
                _valueCell(fmt(plan?.targetWeight)),
                _valueCell(fmt(plan?.targetRpe)),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 20,
            color: colorScheme.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          // Actual
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _valueCell(fmt(session?.actualReps)),
                _valueCell(fmt(session?.actualWeight)),
                _valueCell(fmt(session?.actualRpe)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueCell(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _SetNoteRow extends StatelessWidget {
  final String? planNote;
  final String? sessionNote;
  final ColorScheme colorScheme;

  const _SetNoteRow({
    required this.planNote,
    required this.sessionNote,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: planNote?.isNotEmpty == true
                ? Text(
                    '📝 $planNote',
                    style: TextStyle(fontSize: 11, color: colorScheme.outline),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: sessionNote?.isNotEmpty == true
                ? Text(
                    '🗣 $sessionNote',
                    style: TextStyle(fontSize: 11, color: colorScheme.outline),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
