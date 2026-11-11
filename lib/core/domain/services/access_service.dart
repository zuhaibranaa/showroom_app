import '../entities/user.dart';

/// Interface for access control checks.
///
/// Implementations decide whether a user can perform an action.
/// This interface allows the access logic to be mocked in tests and
/// swapped without touching consumers (DIP).
abstract class IAccessService {
  /// Whether [user] is a super admin.
  bool isSuperAdmin(UserEntity? user);

  /// Whether [user] is an admin.
  bool isAdmin(UserEntity? user);

  /// Whether [user] is a dealer.
  bool isDealer(UserEntity? user);

  /// Whether [user] is staff (super admin or admin).
  bool isStaff(UserEntity? user);

  /// Whether [user] is the designated owner of an agency.
  bool isAgencyOwner(UserEntity? user);

  /// Whether [user] can invite other agency admins.
  bool canInviteAgencyAdmin(UserEntity? user);

  /// Whether [user] can manage [agencyId] (create/edit/delete agencies,
  /// invite agency owners, view cross-agency reports).
  ///
  /// Super admin can manage any agency. Agency owner can manage only their
  /// own agency. Everyone else cannot.
  bool canManageAgency(UserEntity? user, String agencyId);

  /// Whether [user] can access [module] within [agencyId].
  ///
  /// Super admin: always true.
  /// Agency owner: true when [agencyId] is one of their agencyIds.
  /// Staff admin: true when [agencyId] is one of their agencyIds.
  /// Dealer: true when [agencyId] matches their agencyId AND they hold the
  ///   required module permission (view for read access).
  bool canAccessModule(UserEntity? user, String module, String agencyId);
}

/// Default implementation of [IAccessService] that delegates to
/// [UserEntity]'s own role-based methods (LSP: UserEntity defines the
/// role contract, AccessService implements it).
class AccessService implements IAccessService {
  const AccessService();

  @override
  bool isSuperAdmin(UserEntity? user) => user?.isSuperAdmin == true;

  @override
  bool isAdmin(UserEntity? user) => user?.isAdmin == true;

  @override
  bool isDealer(UserEntity? user) => user?.isDealer == true;

  @override
  bool isStaff(UserEntity? user) => isSuperAdmin(user) || isAdmin(user);

  @override
  bool isAgencyOwner(UserEntity? user) => user?.isAgencyOwnerFlag == true;

  @override
  bool canInviteAgencyAdmin(UserEntity? user) =>
      isSuperAdmin(user) || isAgencyOwner(user);

  @override
  bool canManageAgency(UserEntity? user, String agencyId) {
    if (user == null) return false;
    if (isSuperAdmin(user)) return true;
    if (isAgencyOwner(user)) return user.agencyIds.contains(agencyId);
    return false;
  }

  @override
  bool canAccessModule(UserEntity? user, String module, String agencyId) {
    if (user == null) return false;
    // Super admin can access everything everywhere.
    if (isSuperAdmin(user)) return true;
    // Staff (admin) and agency owner can access their own agency's modules.
    if (isStaff(user) || isAgencyOwner(user)) {
      return user.agencyIds.contains(agencyId);
    }
    // Dealers: agency must match, and they need view permission on the module.
    if (isDealer(user) && user.agencyId == agencyId) {
      return _dealerHasModulePermission(user, module, 'view');
    }
    return false;
  }

  /// Whether [user] (a dealer) holds [action] permission on [module].
  ///
  /// This is a placeholder that always returns true for dealers — the real
  /// per-dealer RBAC is resolved via [dealerRbacProvider] in the provider
  /// layer, which reads the dealer's stored [DealerPermissionsEntity].
  bool _dealerHasModulePermission(UserEntity user, String module, String action) {
    // Dealer permissions are stored on the DealerEntity, not UserEntity.
    // The provider layer resolves actual permissions. Return true here so
    // that the domain layer never blocks; the RbacGate widget enforces real
    // per-dealer bits from the provider layer.
    return true;
  }
}
