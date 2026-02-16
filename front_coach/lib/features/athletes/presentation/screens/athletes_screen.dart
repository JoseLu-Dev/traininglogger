import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_drawer.dart';

class AthletesScreen extends StatelessWidget {
  const AthletesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Athletes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Athletes list coming soon',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
