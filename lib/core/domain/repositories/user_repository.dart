import '../entities/user.dart';

/// Read-side contract for user data.
abstract class IUserReadRepository {
  Future<UserEntity?> getById(String uid);
  Future<List<UserEntity>> getByRole(String role);
  Stream<UserEntity?> streamById(String uid);
}

/// Write-side contract for user data.
abstract class IUserWriteRepository {
  Future<void> create(String uid, UserEntity user);
  Future<void> update(String uid, UserEntity user);
}

/// Full user repository contract (read + write).
abstract class IUserRepository
    implements IUserReadRepository, IUserWriteRepository {}
