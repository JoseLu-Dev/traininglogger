import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/responsive_constants.dart';
import '../../../../shared/widgets/adaptive_scaffold.dart';
import '../../../../shared/widgets/app_drawer.dart';

// TODO: Replace with actual User model from front_shared when data layer is ready
class _MockAthlete {
  final String id;
  final String name;
  final String email;

  const _MockAthlete({
    required this.id,
    required this.name,
    required this.email,
  });
}

class AthletesScreen extends StatefulWidget {
  const AthletesScreen({super.key});

  @override
  State<AthletesScreen> createState() => _AthletesScreenState();
}

class _AthletesScreenState extends State<AthletesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // TODO: Replace with actual data from repository/provider
  final List<_MockAthlete> _mockAthletes = const [
    _MockAthlete(id: '1', name: 'John Doe', email: 'john@email.com'),
    _MockAthlete(id: '2', name: 'Jane Smith', email: 'jane@email.com'),
    _MockAthlete(id: '3', name: 'Mike Johnson', email: 'mike@email.com'),
    _MockAthlete(id: '4', name: 'Sarah Williams', email: 'sarah@email.com'),
    _MockAthlete(id: '5', name: 'Tom Brown', email: 'tom@email.com'),
    _MockAthlete(id: '6', name: 'Emily Davis', email: 'emily@email.com'),
  ];

  List<_MockAthlete> get _filteredAthletes {
    if (_searchQuery.isEmpty) {
      return _mockAthletes;
    }
    return _mockAthletes
        .where((athlete) =>
            athlete.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onAthleteCardTap(_MockAthlete athlete) {
    context.goNamed(
      'athlete-detail',
      pathParameters: {'id': athlete.id},
      queryParameters: {'name': athlete.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Athletes'),
      appBarBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          // Athletes grid or empty state
          Expanded(
            child: _filteredAthletes.isEmpty
                ? _buildEmptyState()
                : _buildAthletesGrid(),
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

  Widget _buildAthletesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen =
            ResponsiveConstants.isLargeScreen(constraints.maxWidth);
        final crossAxisCount = isLargeScreen ? 2 : 1;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 90, // Fixed height instead of aspect ratio
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _filteredAthletes.length,
          itemBuilder: (context, index) {
            final athlete = _filteredAthletes[index];
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
  final _MockAthlete athlete;
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
