import 'package:flutter/material.dart';
import 'trainings/widgets/training_calendar_panel.dart';
import 'trainings/widgets/training_detail_panel.dart';

class TrainingsTab extends StatelessWidget {
  final String athleteId;
  const TrainingsTab({super.key, required this.athleteId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Card(
              child: TrainingCalendarPanel(athleteId: athleteId),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: Card(
              child: TrainingDetailPanel(athleteId: athleteId),
            ),
          ),
        ],
      ),
    );
  }
}
