import 'package:flutter/material.dart';
import 'trainings/widgets/training_calendar_panel.dart';

class TrainingsTab extends StatelessWidget {
  final String athleteId;
  const TrainingsTab({super.key, required this.athleteId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TrainingCalendarPanel(athleteId: athleteId)),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}
