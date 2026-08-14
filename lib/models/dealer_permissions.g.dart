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
    );

Map<String, dynamic> _$DealerPermissionsToJson(DealerPermissions instance) =>
    <String, dynamic>{
      'vehicles': instance.vehicles.toJson(),
      'sales': instance.sales.toJson(),
      'dealers': instance.dealers.toJson(),
    };
