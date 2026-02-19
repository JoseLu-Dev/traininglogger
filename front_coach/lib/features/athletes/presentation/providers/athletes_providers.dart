import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';

final athletesProvider = FutureProvider<List<User>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  final all = await repo.findAllActive();
  return all.where((u) => u.role == UserRole.ATHLETE).toList();
});
