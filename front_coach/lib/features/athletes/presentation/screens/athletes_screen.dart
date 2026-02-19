import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import 'package:front_shared/src/ui/sync_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/responsive_constants.dart';
import '../../../../shared/widgets/adaptive_scaffold.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../providers/athletes_providers.dart';

class AthletesScreen extends ConsumerStatefulWidget {
  const AthletesScreen({super.key});

  @override
  ConsumerState<AthletesScreen> createState() => _AthletesScreenState();
}

class _AthletesScreenState extends ConsumerState<AthletesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<User> _filterAthletes(List<User> athletes) {
    if (_searchQuery.isEmpty) return athletes;
    return athletes
        .where((a) => a.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _onAthleteCardTap(User athlete) {
    context.goNamed(
      'athlete-detail',
      pathParameters: {'id': athlete.id},
      queryParameters: {'name': athlete.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    final athletesAsync = ref.watch(athletesProvider);

    return AdaptiveScaffold(
      title: const Text('Athletes'),
      appBarBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: const [
        OfflineIndicator(),
        SyncIndicator(),
        SyncButton(),
      ],
      drawerContent: const AppDrawerContent(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search athletes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Athletes grid or loading/empty state
          Expanded(
            child: athletesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading athletes: $e')),
              data: (athletes) {
                final filtered = _filterAthletes(athletes);
                return filtered.isEmpty
                    ? _buildEmptyState()
                    : _buildAthletesGrid(filtered);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No athletes yet' : 'No athletes found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAthletesGrid(List<User> athletes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen =
            ResponsiveConstants.isLargeScreen(constraints.maxWidth);
        final crossAxisCount = isLargeScreen ? 2 : 1;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 90,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: athletes.length,
          itemBuilder: (context, index) {
            final athlete = athletes[index];
            return _AthleteCard(
              athlete: athlete,
              onTap: () => _onAthleteCardTap(athlete),
            );
          },
        );
      },
    );
  }
}

class _AthleteCard extends StatelessWidget {
  final User athlete;
  final VoidCallback onTap;

  const _AthleteCard({
    required this.athlete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                athlete.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                athlete.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
