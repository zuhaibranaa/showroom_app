// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dealer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DealerModel _$DealerModelFromJson(Map<String, dynamic> json) => DealerModel(
      id: json['id'] as String,
      agencyId: json['agencyId'] as String? ?? '',
      userId: json['userId'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      licenseNumber: json['licenseNumber'] as String?,
      commissionPercent: (json['commissionPercent'] as num?)?.toDouble(),
      permissions: json['permissions'] == null
          ? const DealerPermissions()
          : DealerPermissions.fromJson(
              json['permissions'] as Map<String, dynamic>),
      totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0.0,
      totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DealerModelToJson(DealerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agencyId': instance.agencyId,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'licenseNumber': instance.licenseNumber,
      'commissionPercent': instance.commissionPercent,
      'permissions': instance.permissions.toJson(),
      'totalCommission': instance.totalCommission,
      'totalSales': instance.totalSales,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
