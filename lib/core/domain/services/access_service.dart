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
}
