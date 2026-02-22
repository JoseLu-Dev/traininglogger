import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import 'package:table_calendar/table_calendar.dart';

import '../notifiers/trainings_calendar_notifier.dart';
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
            return _buildCalendar(
              context,
              notifier,
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
    Map<String, TrainingPlan> plansByDate,
    String? selectedDate,
    double cellWidth,
    double rowHeight,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayNumFontSize = (cellWidth * 0.28).clamp(10.0, 18.0);
    final headerFontSize = (cellWidth * 0.35).clamp(12.0, 20.0);
    final dowFontSize = (cellWidth * 0.22).clamp(9.0, 13.0);

    return TableCalendar<TrainingPlan>(
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
    );
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
