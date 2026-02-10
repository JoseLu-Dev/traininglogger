import '../models/user.dart';

abstract class UserRepository {
  Future<User?> findById(String id);
  Future<List<User>> findAllActive();
  Future<User?> findByEmail(String email);
  Future<String> create(User entity);
  Future<void> update(User entity);
  Future<void> delete(String id);
}
