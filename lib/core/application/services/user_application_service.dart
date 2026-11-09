import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Application service for user profile use cases.
class UserApplicationService {
  final IUserRepository _repository;

  UserApplicationService(this._repository);

  Future<void> create(String uid, UserEntity user) =>
      _repository.create(uid, user);
  Future<void> update(String uid, UserEntity user) =>
      _repository.update(uid, user);
  Future<UserEntity?> getById(String uid) => _repository.getById(uid);
  Future<List<UserEntity>> getByRole(String role) =>
      _repository.getByRole(role);
}
