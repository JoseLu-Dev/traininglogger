import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import 'package:go_router/go_router.dart';

/// Drawer content that can be used directly or wrapped in a Drawer
class AppDrawerContent extends ConsumerWidget {
  const AppDrawerContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Extract email from auth state
    final email = authState.maybeWhen(
      authenticated: (_, email, __, ___, ____) => email,
      orElse: () => 'Unknown',
    );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.fitness_center, size: 48),
              const SizedBox(height: 8),
              Text(
                email.split('@').first, // Display name from email
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                email,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Athletes'),
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context); // Close drawer if modal
            context.go('/athletes');
          },
        ),
        ExpansionTile(
          leading: const Icon(Icons.library_books),
          title: const Text('Library'),
          children: [
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Exercises'),
              contentPadding: const EdgeInsets.only(left: 72, right: 16),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                context.go('/exercises');
              },
            ),
            ListTile(
              leading: const Icon(Icons.alt_route),
              title: const Text('Variants'),
              contentPadding: const EdgeInsets.only(left: 72, right: 16),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                context.go('/variants');
              },
            ),
          ],
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () async {
            if (Navigator.canPop(context)) Navigator.pop(context); // Close drawer if modal
            await ref.read(authNotifierProvider.notifier).logout();
            // GoRouter auto-redirects to /login
          },
        ),
      ],
    );
  }
}

/// Traditional drawer wrapper around AppDrawerContent
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: AppDrawerContent(),
    );
  }
}
