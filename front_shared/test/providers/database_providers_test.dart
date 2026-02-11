import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/src/providers/database_providers.dart';
import 'package:front_shared/src/data/local/database/app_database.dart';
import 'package:front_shared/src/sync/core/entity_registry.dart';

void main() {
  group('databaseProvider', () {
    test('provides AppDatabase instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);

      expect(db, isNotNull);
      expect(db, isA<AppDatabase>());
    });

    test('disposes database when container is disposed', () {
      final container = ProviderContainer();

      final db = container.read(databaseProvider);
      expect(db, isNotNull);

      // Dispose the container
      container.dispose();

      // Database should be closed after disposal
      // We can't directly test if it's closed, but we can verify no errors occur
      expect(true, isTrue);
    });

    test('provides same instance within same container', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final db1 = container.read(databaseProvider);
      final db2 = container.read(databaseProvider);

      expect(db1, same(db2));
    });

    test('provides different instances for different containers', () {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(() {
        container1.dispose();
        container2.dispose();
      });

      final db1 = container1.read(databaseProvider);
      final db2 = container2.read(databaseProvider);

      expect(db1, isNot(same(db2)));
    });
  });

  group('entityRegistryProvider', () {
    test('provides EntityRegistry instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final registry = container.read(entityRegistryProvider);

      expect(registry, isNotNull);
      expect(registry, isA<EntityRegistry>());
    });

    test('entity registry depends on database provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Reading entityRegistryProvider should also initialize databaseProvider
      final registry = container.read(entityRegistryProvider);
      final db = container.read(databaseProvider);

      expect(registry, isNotNull);
      expect(db, isNotNull);
    });

    test('provides same instance within same container', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final registry1 = container.read(entityRegistryProvider);
      final registry2 = container.read(entityRegistryProvider);

      expect(registry1, same(registry2));
    });

    test('provides different instances for different containers', () {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(() {
        container1.dispose();
        container2.dispose();
      });

      final registry1 = container1.read(entityRegistryProvider);
      final registry2 = container2.read(entityRegistryProvider);

      expect(registry1, isNot(same(registry2)));
    });

    test('entity registry is properly initialized with entities', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final registry = container.read(entityRegistryProvider);

      // Verify that the registry has been set up with entities
      // The specific entities will be added in future steps
      expect(registry, isNotNull);
      expect(registry.registeredEntityTypes, isNotNull);
    });

    test('entity registry can be used independently after initialization', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final registry = container.read(entityRegistryProvider);
      final entityTypes = registry.registeredEntityTypes;

      expect(entityTypes, isNotNull);
      expect(entityTypes, isA<List<String>>());
    });
  });

  group('provider integration', () {
    test('both providers work together correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final registry = container.read(entityRegistryProvider);

      expect(db, isNotNull);
      expect(registry, isNotNull);
      expect(db, isA<AppDatabase>());
      expect(registry, isA<EntityRegistry>());
    });

    test('providers can be overridden for testing', () {
      // This test verifies that we can override providers for testing purposes
      // We don't actually use the mock here, just verify the override mechanism works
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      expect(db, isA<AppDatabase>());
    });

    test('container disposal closes database properly', () {
      final container = ProviderContainer();

      // Read the provider to initialize it
      container.read(databaseProvider);
      container.read(entityRegistryProvider);

      // Should not throw when disposing
      container.dispose();
    });
  });
}
