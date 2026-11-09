import 'package:equatable/equatable.dart';
import '../entities/dealer_permissions.dart';

/// Domain entity for a dealer. Encapsulates dealer-specific business rules.
class DealerEntity extends Equatable {
  final String id;
  final String agencyId;
  final String? userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String? licenseNumber;
  final double? commissionPercent;
  final DealerPermissionsEntity permissions;
  final double totalCommission;
  final int totalSales;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DealerEntity({
    required this.id,
    required this.agencyId,
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.licenseNumber,
    this.commissionPercent,
    this.permissions = const DealerPermissionsEntity(),
    this.totalCommission = 0.0,
    this.totalSales = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this dealer can view the given module.
  bool canView(String module) {
    switch (module) {
      case 'vehicles':
        return permissions.vehicles.view;
      case 'sales':
        return permissions.sales.view;
      case 'dealers':
        return permissions.dealers.view;
      default:
        return false;
    }
  }

  /// Whether this dealer can create in the given module.
  bool canCreate(String module) {
    switch (module) {
      case 'vehicles':
        return permissions.vehicles.create;
      case 'sales':
        return permissions.sales.create;
      case 'dealers':
        return permissions.dealers.create;
      default:
        return false;
    }
  }

  /// Whether this dealer can edit in the given module.
  bool canEdit(String module) {
    switch (module) {
      case 'vehicles':
        return permissions.vehicles.edit;
      case 'sales':
        return permissions.sales.edit;
      case 'dealers':
        return permissions.dealers.edit;
      default:
        return false;
    }
  }

  @override
  List<Object?> get props => [
        id,
        agencyId,
        userId,
        name,
        email,
        phone,
        address,
        city,
        licenseNumber,
        commissionPercent,
        permissions,
        totalCommission,
        totalSales,
        isActive,
        createdAt,
        updatedAt,
      ];

  DealerEntity copyWith({
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
    DealerPermissionsEntity? permissions,
    double? totalCommission,
    int? totalSales,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DealerEntity(
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
