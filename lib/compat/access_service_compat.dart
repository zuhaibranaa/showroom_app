import '../compat/model_converters.dart';
import '../core/domain/entities/user.dart';
import '../core/domain/services/access_service.dart';
import '../models/user_model.dart';

/// Compatibility shim so existing screens can use [AccessService] as a static
/// class with [UserModel] while the core uses [IAccessService] with
/// [UserEntity] (DIP).
class AccessServiceCompat {
  static bool isSuperAdmin(UserModel? user) {
    if (user == null) return false;
    return const AccessService().isSuperAdmin(userModelToEntity(user));
  }

  static bool isAdmin(UserModel? user) {
    if (user == null) return false;
    return const AccessService().isAdmin(userModelToEntity(user));
  }

  static bool isDealer(UserModel? user) {
    if (user == null) return false;
    return const AccessService().isDealer(userModelToEntity(user));
  }

  static bool isStaff(UserModel? user) {
    if (user == null) return false;
    return const AccessService().isStaff(userModelToEntity(user));
  }

  static bool isAgencyOwner(UserModel? user) {
    if (user == null) return false;
    return const AccessService().isAgencyOwner(userModelToEntity(user));
  }

  static bool canInviteAgencyAdmin(UserModel? user) {
    if (user == null) return false;
    return const AccessService().canInviteAgencyAdmin(userModelToEntity(user));
  }
}

/// Adapter that implements [IAccessService] using the domain [AccessService].
/// Used by Riverpod providers (DIP).
class AccessServiceAdapter implements IAccessService {
  final IAccessService _service;

  AccessServiceAdapter() : _service = const AccessService();

  @override
  bool isSuperAdmin(UserEntity? user) => _service.isSuperAdmin(user);

  @override
  bool isAdmin(UserEntity? user) => _service.isAdmin(user);

  @override
  bool isDealer(UserEntity? user) => _service.isDealer(user);

  @override
  bool isStaff(UserEntity? user) => _service.isStaff(user);

  @override
  bool isAgencyOwner(UserEntity? user) => _service.isAgencyOwner(user);

  @override
  bool canInviteAgencyAdmin(UserEntity? user) =>
      _service.canInviteAgencyAdmin(user);
}
