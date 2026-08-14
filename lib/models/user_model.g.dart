// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: json['role'] as String? ?? 'dealer',
      agencyIds: (json['agencyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      agencyId: json['agencyId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'fullName': instance.fullName,
      'profileImageUrl': instance.profileImageUrl,
      'role': instance.role,
      'agencyIds': instance.agencyIds,
      'agencyId': instance.agencyId,
      'isActive': instance.isActive,
      'mustChangePassword': instance.mustChangePassword,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
