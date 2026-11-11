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

  /// Whether [user] can manage [agencyId] (super admin or agency owner of that agency).
  static bool canManageAgency(UserModel? user, String agencyId) {
    if (user == null) return false;
    return const AccessService().canManageAgency(userModelToEntity(user), agencyId);
  }

  /// Whether [user] can access [module] within [agencyId].
  static bool canAccessModule(UserModel? user, String module, String agencyId) {
    if (user == null) return false;
    return const AccessService().canAccessModule(userModelToEntity(user), module, agencyId);
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

  @override
  bool canManageAgency(UserEntity? user, String agencyId) =>
      _service.canManageAgency(user, agencyId);

  @override
  bool canAccessModule(UserEntity? user, String module, String agencyId) =>
      _service.canAccessModule(user, module, agencyId);
}
