import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import 'package:table_calendar/table_calendar.dart';

import '../notifiers/training_detail_notifier.dart';
import '../notifiers/trainings_calendar_notifier.dart';
import '../providers/training_detail_providers.dart';
import '../providers/trainings_calendar_providers.dart';
import 'training_day_context_menu.dart';

class TrainingCalendarPanel extends ConsumerStatefulWidget {
  final String athleteId;
  const TrainingCalendarPanel({super.key, required this.athleteId});

  @override
  ConsumerState<TrainingCalendarPanel> createState() =>
      _TrainingCalendarPanelState();
}

class _TrainingCalendarPanelState extends ConsumerState<TrainingCalendarPanel> {
  DateTime _focusedDay = DateTime.now();

  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingsCalendarProvider(widget.athleteId));
    final notifier = ref.read(
      trainingsCalendarProvider(widget.athleteId).notifier,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;
        // Cap rowHeight so 6 rows + header (~56) + DOW row always fit
        final dowH = max(20.0, cellWidth * 0.35);
        const headerH = 56.0;
        final maxRowH = constraints.maxHeight.isFinite
            ? (constraints.maxHeight - headerH - dowH) / 6
            : double.infinity;
        final rowHeight = max(40.0, min(cellWidth * 1.5, maxRowH));

        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (msg) => Center(child: Text('Error: $msg')),
          loaded: (plansByDate, sessionsByDate, focusedMonth, selectedDate) {
            final detailNotifier = ref.read(
              trainingDetailProvider(widget.athleteId).notifier,
            );
            return _buildCalendar(
              context,
              notifier,
              detailNotifier,
              plansByDate,
              selectedDate,
              cellWidth,
              rowHeight,
            );
          },
        );
      },
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    TrainingsCalendarNotifier notifier,
    TrainingDetailNotifier detailNotifier,
    Map<String, TrainingPlan> plansByDate,
    String? selectedDate,
    double cellWidth,
    double rowHeight,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayNumFontSize = (cellWidth * 0.28).clamp(10.0, 18.0);
    final headerFontSize = (cellWidth * 0.35).clamp(12.0, 20.0);
    final dowFontSize = (cellWidth * 0.22).clamp(9.0, 13.0);

    return Column(
      children: [
        TableCalendar<TrainingPlan>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => selectedDate == _dateKey(day),
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: rowHeight,
      daysOfWeekHeight: max(20.0, cellWidth * 0.35),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: headerFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: dowFontSize),
        weekendStyle: TextStyle(
          fontSize: dowFontSize,
          color: colorScheme.error,
        ),
      ),
      calendarStyle: const CalendarStyle(
        markerDecoration: BoxDecoration(color: Colors.transparent),
      ),
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
        notifier.loadMonth(focusedDay);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => _focusedDay = focusedDay);
        final key = _dateKey(selectedDay);
        final plan = plansByDate[key];
        if (plan == null) {
          showAddTrainingMenu(context, key, notifier);
        } else {
          notifier.selectDate(key);
        }
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (ctx, day, _) => _DayCell(
          day: day,
          plan: plansByDate[_dateKey(day)],
          isToday: false,
          isSelected: selectedDate == _dateKey(day),
          isOutside: false,
          notifier: notifier,
          colorScheme: colorScheme,
          dateKey: _dateKey(day),
          cellWidth: cellWidth,
          dayNumFontSize: dayNumFontSize,
        ),
        todayBuilder: (ctx, day, _) => _DayCell(
          day: day,
          plan: plansByDate[_dateKey(day)],
          isToday: true,
          isSelected: selectedDate == _dateKey(day),
          isOutside: false,
          notifier: notifier,
          colorScheme: colorScheme,
          dateKey: _dateKey(day),
          cellWidth: cellWidth,
          dayNumFontSize: dayNumFontSize,
        ),
        selectedBuilder: (ctx, day, _) => _DayCell(
          day: day,
          plan: plansByDate[_dateKey(day)],
          isToday: isSameDay(day, DateTime.now()),
          isSelected: true,
          isOutside: false,
          notifier: notifier,
          colorScheme: colorScheme,
          dateKey: _dateKey(day),
          cellWidth: cellWidth,
          dayNumFontSize: dayNumFontSize,
        ),
        outsideBuilder: (ctx, day, _) => _DayCell(
          day: day,
          plan: plansByDate[_dateKey(day)],
          isToday: false,
          isSelected: false,
          isOutside: true,
          notifier: notifier,
          colorScheme: colorScheme,
          dateKey: _dateKey(day),
          cellWidth: cellWidth,
          dayNumFontSize: dayNumFontSize,
        ),
      ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              label: const Text('Copy week'),
              onPressed: selectedDate == null
                  ? null
                  : () => _showCopyWeekDialog(
                        context,
                        selectedDate,
                        detailNotifier,
                        notifier,
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Copy week dialog
// ---------------------------------------------------------------------------

String _mondayKey(String dateKey) {
  final p = dateKey.split('-');
  final dt = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  final monday = dt.subtract(Duration(days: dt.weekday - 1));
  return '${monday.year.toString().padLeft(4, '0')}-'
      '${monday.month.toString().padLeft(2, '0')}-'
      '${monday.day.toString().padLeft(2, '0')}';
}

String _friendlyDate(String dateKey) {
  final p = dateKey.split('-');
  final dt = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${days[dt.weekday - 1]} ${months[dt.month - 1]} ${dt.day}';
}

Future<void> _showCopyWeekDialog(
  BuildContext context,
  String selectedDate,
  TrainingDetailNotifier detailNotifier,
  TrainingsCalendarNotifier calendarNotifier,
) async {
  final sourceMonday = _mondayKey(selectedDate);
  final sourceMondayDt = DateTime.parse(sourceMonday);
  final defaultTargetDt = sourceMondayDt.add(const Duration(days: 7));

  DateTime targetMondayDt = defaultTargetDt;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final targetMonday = _mondayKey(
          '${targetMondayDt.year.toString().padLeft(4, '0')}-'
          '${targetMondayDt.month.toString().padLeft(2, '0')}-'
          '${targetMondayDt.day.toString().padLeft(2, '0')}',
        );
        final targetSunday = DateTime.parse(targetMonday)
            .add(const Duration(days: 6));
        final targetSundayKey =
            '${targetSunday.year.toString().padLeft(4, '0')}-'
            '${targetSunday.month.toString().padLeft(2, '0')}-'
            '${targetSunday.day.toString().padLeft(2, '0')}';

        final sourceSundayKey = (() {
          final dt = DateTime.parse(sourceMonday).add(const Duration(days: 6));
          return '${dt.year.toString().padLeft(4, '0')}-'
              '${dt.month.toString().padLeft(2, '0')}-'
              '${dt.day.toString().padLeft(2, '0')}';
        })();
        return AlertDialog(
          title: const Text('Copy week'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Source: ${_friendlyDate(sourceMonday)} – '
                '${_friendlyDate(sourceSundayKey)}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Target: ${_friendlyDate(targetMonday)} – '
                      '${_friendlyDate(targetSundayKey)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: targetMondayDt,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          // Snap to Monday of picked week
                          targetMondayDt =
                              picked.subtract(Duration(days: picked.weekday - 1));
                        });
                      }
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Copy'),
            ),
          ],
        );
      },
    ),
  );

  if (confirmed != true) return;

  final targetMondayKey =
      '${targetMondayDt.year.toString().padLeft(4, '0')}-'
      '${targetMondayDt.month.toString().padLeft(2, '0')}-'
      '${targetMondayDt.day.toString().padLeft(2, '0')}';

  final result = await detailNotifier.copyWeek(sourceMonday, targetMondayKey);

  switch (result.status) {
    case CopyWeekStatus.success:
      await calendarNotifier.loadMonth(targetMondayDt);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Week copied successfully')),
        );
      }
    case CopyWeekStatus.empty:
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No trainings found in this week')),
        );
      }
    case CopyWeekStatus.conflict:
      if (context.mounted) {
        final dateList = result.conflictingDates.map(_friendlyDate).join(', ');
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cannot copy week'),
            content: Text(
              'The target week already has trainings on: $dateList.\n\n'
              'Remove them first, then try again.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
  }
}

// ---------------------------------------------------------------------------
// Single day cell with scaled layout and drag-and-drop support
// ---------------------------------------------------------------------------

class _DayCell extends StatelessWidget {
  final DateTime day;
  final TrainingPlan? plan;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;
  final TrainingsCalendarNotifier notifier;
  final ColorScheme colorScheme;
  final String dateKey;
  final double cellWidth;
  final double dayNumFontSize;

  const _DayCell({
    required this.day,
    required this.plan,
    required this.isToday,
    required this.isSelected,
    required this.isOutside,
    required this.notifier,
    required this.colorScheme,
    required this.dateKey,
    required this.cellWidth,
    required this.dayNumFontSize,
  });

  @override
  Widget build(BuildContext context) {
    // ── Colors ──────────────────────────────────────────────────────────────
    Color? cellBg;
    Color textColor = isOutside
        ? colorScheme.onSurface.withAlpha(70)
        : colorScheme.onSurface;

    if (isToday) {
      cellBg = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    }
    if (isSelected && !isToday) {
      cellBg = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    }

    // ── Chip ────────────────────────────────────────────────────────────────
    final chipFontSize = (cellWidth * 0.18).clamp(7.0, 11.0);
    final chipHPad = max(4.0, cellWidth * 0.07);
    final bool isLocked = plan?.isLocked ?? false;
    final Color chipBg;
    final Color chipText;
    if (isSelected && !isToday) {
      // selected cell has primary (dark) bg → light chip, tinted by type
      chipBg = colorScheme.surface.withAlpha(220);
      chipText = isLocked ? colorScheme.tertiary : colorScheme.secondary;
    } else if (isLocked) {
      chipBg = colorScheme.tertiaryContainer;
      chipText = colorScheme.onTertiaryContainer;
    } else {
      chipBg = colorScheme.secondaryContainer;
      chipText = colorScheme.onSecondaryContainer;
    }
    final IconData chipIcon = isLocked
        ? Icons.check
        : Icons.radio_button_unchecked;

    // ── Visual widget (pure, no gestures) ───────────────────────────────────
    Widget visual = Container(
      width: double.infinity,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cellBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontSize: dayNumFontSize,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (plan != null)
            Container(
              margin: EdgeInsets.only(top: cellWidth * 0.04, left: 3, right: 3),
              padding: EdgeInsets.symmetric(
                horizontal: chipHPad,
                vertical: 1.5,
              ),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(100),
              ),
              constraints: BoxConstraints(maxWidth: cellWidth - 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(chipIcon, size: chipFontSize + 1, color: chipText),
                  SizedBox(width: chipHPad * 0.5),
                  Flexible(
                    child: Text(
                      plan!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: chipFontSize,
                        color: chipText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    // ── Draggable wrapper (only when plan exists) ────────────────────────────
    Widget draggable = plan != null && !plan!.isLocked
        ? Draggable<TrainingPlan>(
            data: plan!,
            feedback: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan!.name,
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                ),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: visual),
            child: visual,
          )
        : visual;

    // ── DragTarget (every cell can receive a drop) ───────────────────────────
    return DragTarget<TrainingPlan>(
      onWillAcceptWithDetails: (details) => details.data.date != dateKey,
      onAcceptWithDetails: (details) =>
          notifier.moveTraining(details.data, dateKey),
      builder: (ctx, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isDragOver
                ? colorScheme.primaryContainer.withAlpha(120)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: draggable,
        );
      },
    );
  }
}
