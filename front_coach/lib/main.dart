import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:front_shared/front_shared.dart';

// Hardcoded credentials for POC testing
const _hardcodedEmail = 'coach@example.com';
const _hardcodedPassword = 'password123';

void main() async {
  // MarionetteBinding handles WidgetsFlutterBinding initialization
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  runApp(const ProviderScope(child: CoachApp()));
}

class CoachApp extends ConsumerWidget {
  const CoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auto-sync service
    ref.watch(autoSyncServiceProvider);

    return MaterialApp(
      title: 'LiftLogger Coach - POC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Auth gate - automatically attempts login with hardcoded credentials
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Auto-login with hardcoded credentials on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptAutoLogin();
    });
  }

  Future<void> _attemptAutoLogin() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.login(_hardcodedEmail, _hardcodedPassword);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      initial: () => _buildLoadingScreen('Initializing...'),
      loading: () => _buildLoadingScreen('Logging in...'),
      authenticated: (id, email, role, coachId, isOffline) {
        return HomePage(
          userId: id,
          email: email,
          role: UserRole.COACH,
          isOffline: isOffline,
        );
      },
      unauthenticated: () => _buildErrorScreen(
        'Authentication required',
        'Failed to login with hardcoded credentials',
      ),
      error: (message) => _buildErrorScreen('Authentication Error', message),
    );
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'Email: $_hardcodedEmail',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String title, String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Hardcoded credentials:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'Email: $_hardcodedEmail',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Password: $_hardcodedPassword',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _attemptAutoLogin(),
                child: const Text('Retry Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Home page - shown after successful authentication
class HomePage extends StatelessWidget {
  final String userId;
  final String email;
  final UserRole role;
  final bool isOffline;

  const HomePage({
    super.key,
    required this.userId,
    required this.email,
    required this.role,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LiftLogger Coach - POC'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const [
          // These are the front_shared UI widgets
          OfflineIndicator(),
          SizedBox(width: 8),
          SyncButton(),
          SizedBox(width: 8),
          SyncIndicator(),
          SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'LiftLogger Coach',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Proof of Concept',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Auth info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Authenticated',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('User ID', userId),
                      _buildInfoRow('Email', email),
                      _buildInfoRow('Role', role.name),
                      _buildInfoRow(
                        'Mode',
                        isOffline ? 'Offline' : 'Online',
                        valueColor: isOffline ? Colors.orange : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Widgets info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Integrated Widgets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWidgetInfo(
                        'OfflineIndicator',
                        'Shows when app is offline',
                        Icons.cloud_off,
                      ),
                      const SizedBox(height: 12),
                      _buildWidgetInfo(
                        'SyncButton',
                        'Manually trigger sync',
                        Icons.sync,
                      ),
                      const SizedBox(height: 12),
                      _buildWidgetInfo(
                        'SyncIndicator',
                        'Shows sync status and progress',
                        Icons.info_outline,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Check the AppBar to see the sync widgets!\nTry tapping the sync button or toggling airplane mode.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetInfo(String name, String description, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
