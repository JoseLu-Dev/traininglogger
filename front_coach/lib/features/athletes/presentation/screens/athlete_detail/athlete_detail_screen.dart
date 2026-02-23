import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_scaffold.dart';
import '../../../../../shared/widgets/app_drawer.dart';
import 'tabs/statistics_tab.dart';
import 'tabs/trainings_tab.dart';

class AthleteDetailScreen extends StatelessWidget {
  final String athleteId;
  final String athleteName;

  const AthleteDetailScreen({
    super.key,
    required this.athleteId,
    required this.athleteName,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AdaptiveScaffold(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(athleteName),
        appBarBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.fitness_center), text: 'Trainings'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Statistics'),
          ],
        ),
        drawerContent: const AppDrawerContent(),
        body: TabBarView(
          children: [
            TrainingsTab(athleteId: athleteId),
            StatisticsTab(),
          ],
        ),
      ),
    );
  }
}
