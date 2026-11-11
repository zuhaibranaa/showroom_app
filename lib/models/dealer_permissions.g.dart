// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dealer_permissions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModulePermission _$ModulePermissionFromJson(Map<String, dynamic> json) =>
    ModulePermission(
      create: json['create'] as bool? ?? false,
      edit: json['edit'] as bool? ?? false,
      view: json['view'] as bool? ?? true,
    );

Map<String, dynamic> _$ModulePermissionToJson(ModulePermission instance) =>
    <String, dynamic>{
      'create': instance.create,
      'edit': instance.edit,
      'view': instance.view,
    };

DealerPermissions _$DealerPermissionsFromJson(Map<String, dynamic> json) =>
    DealerPermissions(
      vehicles: json['vehicles'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['vehicles'] as Map<String, dynamic>),
      sales: json['sales'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['sales'] as Map<String, dynamic>),
      dealers: json['dealers'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['dealers'] as Map<String, dynamic>),
      expenses: json['expenses'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['expenses'] as Map<String, dynamic>),
      registrationTransfer: json['registrationTransfer'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['registrationTransfer'] as Map<String, dynamic>),
      reports: json['reports'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['reports'] as Map<String, dynamic>),
      documents: json['documents'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['documents'] as Map<String, dynamic>),
      biometrics: json['biometrics'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['biometrics'] as Map<String, dynamic>),
      pendingPayments: json['pendingPayments'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['pendingPayments'] as Map<String, dynamic>),
      retailPrices: json['retailPrices'] == null
          ? const ModulePermission()
          : ModulePermission.fromJson(json['retailPrices'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DealerPermissionsToJson(DealerPermissions instance) =>
    <String, dynamic>{
      'vehicles': instance.vehicles.toJson(),
      'sales': instance.sales.toJson(),
      'dealers': instance.dealers.toJson(),
      'expenses': instance.expenses.toJson(),
      'registrationTransfer': instance.registrationTransfer.toJson(),
      'reports': instance.reports.toJson(),
      'documents': instance.documents.toJson(),
      'biometrics': instance.biometrics.toJson(),
      'pendingPayments': instance.pendingPayments.toJson(),
      'retailPrices': instance.retailPrices.toJson(),
    };
