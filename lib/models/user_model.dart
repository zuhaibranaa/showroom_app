import 'package:json_annotation/json_annotation.dart';
import 'user_role.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? profileImageUrl;
  final String role; // super_admin, admin, dealer
  final List<String> agencyIds; // agencies an admin belongs to
  final String? agencyId; // single agency a dealer belongs to
  final bool isActive;
  final bool mustChangePassword; // dealer must change temp password on login
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserRole get userRole => UserRoleExtension.fromString(role);

  UserModel copyWith({
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
