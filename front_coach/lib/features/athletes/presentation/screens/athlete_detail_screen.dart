import 'package:flutter/material.dart';

import '../../../../shared/widgets/adaptive_scaffold.dart';
import '../../../../shared/widgets/app_drawer.dart';

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
    return AdaptiveScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(athleteName),
      appBarBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
      drawerContent: const AppDrawerContent(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Athlete details coming soon',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $athleteId',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
