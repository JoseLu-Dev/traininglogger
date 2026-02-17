import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import 'package:go_router/go_router.dart';
import '../providers/exercise_providers.dart';
import 'confirmation_dialog.dart';

class ExerciseListTile extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseListTile({
    super.key,
    required this.exercise,
  });

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'sport specific':
        return Icons.sports;
      case 'balance':
        return Icons.accessibility_new;
      case 'plyometric':
        return Icons.sports_gymnastics;
      default:
        return Icons.sports_martial_arts;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        _getCategoryIcon(exercise.category),
        size: 32,
      ),
      title: Text(
        exercise.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: exercise.category != null
          ? Text(exercise.category!)
          : null,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) async {
          if (value == 'edit') {
            context.go('/exercises/${exercise.id}/edit');
          } else if (value == 'delete') {
            final confirmed = await showConfirmationDialog(
              context,
              title: 'Delete Exercise?',
              message:
                  'Are you sure you want to delete "${exercise.name}"? This action cannot be undone.',
            );

            if (confirmed == true && context.mounted) {
              await ref
                  .read(exerciseListNotifierProvider.notifier)
                  .deleteExercise(exercise.id);
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
