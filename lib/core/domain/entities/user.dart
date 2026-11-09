import 'package:equatable/equatable.dart';

/// Domain entity for a user. Encapsulates user role and agency membership.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? profileImageUrl;
  final String role; // super_admin, admin, dealer
  final List<String> agencyIds;
  final String? agencyId;
  final bool isActive;
  final bool mustChangePassword;
  final bool isAgencyOwner;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.profileImageUrl,
    this.role = 'dealer',
    this.agencyIds = const [],
    this.agencyId,
    this.isActive = true,
    this.mustChangePassword = false,
    this.isAgencyOwner = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this user is a super admin.
  bool get isSuperAdmin => role == 'super_admin';

  /// Whether this user is an admin.
  bool get isAdmin => role == 'admin';

  /// Whether this user is a dealer.
  bool get isDealer => role == 'dealer';

  /// Whether this user is staff (super admin or admin).
  bool get isStaff => isSuperAdmin || isAdmin;

  /// Whether this user is an agency owner.
  bool get isAgencyOwnerFlag => isAgencyOwner;

  /// Whether this user can invite agency admins.
  bool get canInviteAgencyAdmin => isSuperAdmin || isAgencyOwner;

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        fullName,
        profileImageUrl,
        role,
        agencyIds,
        agencyId,
        isActive,
        mustChangePassword,
        isAgencyOwner,
        createdAt,
        updatedAt,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? profileImageUrl,
    String? role,
    List<String>? agencyIds,
    String? agencyId,
    bool? isActive,
    bool? mustChangePassword,
    bool? isAgencyOwner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      agencyIds: agencyIds ?? this.agencyIds,
      agencyId: agencyId ?? this.agencyId,
      isActive: isActive ?? this.isActive,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      isAgencyOwner: isAgencyOwner ?? this.isAgencyOwner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
