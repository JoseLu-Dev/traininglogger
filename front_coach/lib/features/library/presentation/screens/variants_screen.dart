import 'package:flutter/material.dart';

import '../../../../shared/widgets/adaptive_scaffold.dart';
import '../../../../shared/widgets/app_drawer.dart';

class VariantsScreen extends StatelessWidget {
  const VariantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Variants'),
      appBarBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
      drawerContent: const AppDrawerContent(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alt_route, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Variants library coming soon',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
