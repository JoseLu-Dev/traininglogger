import 'package:flutter/material.dart';
import '../notifiers/trainings_calendar_notifier.dart';

/// Shows an "Add Training" dialog for an empty day cell.
Future<void> showAddTrainingMenu(
  BuildContext context,
  String date,
  TrainingsCalendarNotifier notifier,
) async {
  final parts = date.split('-');
  final label = '${_monthName(int.parse(parts[1]))} ${int.parse(parts[2])}, ${parts[0]}';

  final controller = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(label),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Training name'),
        onSubmitted: (_) => Navigator.of(ctx).pop(true),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Add'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final name = controller.text.trim();
    if (name.isNotEmpty) {
      notifier.addTraining(date, name);
    }
  }

  controller.dispose();
}

String _monthName(int month) => const [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month];
