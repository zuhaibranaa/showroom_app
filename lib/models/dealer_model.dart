import 'package:json_annotation/json_annotation.dart';

import 'dealer_permissions.dart';

part 'dealer_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DealerModel {
  final String id;
  final String agencyId;
  final String? userId; // Firebase UID linked to this dealer, if registered
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String? licenseNumber;
  final double? commissionPercent;
  final DealerPermissions permissions;
  final double totalCommission;
  final int totalSales;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DealerModel({
    required this.id,
    this.agencyId = '',
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.licenseNumber,
    this.commissionPercent,
    this.permissions = const DealerPermissions(),
    this.totalCommission = 0.0,
    this.totalSales = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) =>
      _$DealerModelFromJson(json);

  Map<String, dynamic> toJson() => _$DealerModelToJson(this);

  DealerModel copyWith({
    String? id,
    String? agencyId,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? licenseNumber,
    double? commissionPercent,
    DealerPermissions? permissions,
    double? totalCommission,
    int? totalSales,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DealerModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      permissions: permissions ?? this.permissions,
      totalCommission: totalCommission ?? this.totalCommission,
      totalSales: totalSales ?? this.totalSales,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
