import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_drawer.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Exercise library coming soon',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
