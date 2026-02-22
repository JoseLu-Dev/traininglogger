import 'package:flutter/material.dart';
import 'trainings/widgets/training_calendar_panel.dart';

class TrainingsTab extends StatelessWidget {
  final String athleteId;
  const TrainingsTab({super.key, required this.athleteId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(flex: 2, child: TrainingCalendarPanel(athleteId: athleteId)),
        const Flexible(flex: 3, child: SizedBox()),
      ],
    );
  }
}
