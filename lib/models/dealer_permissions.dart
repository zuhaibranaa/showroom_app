import 'package:json_annotation/json_annotation.dart';

part 'dealer_permissions.g.dart';

@JsonSerializable()
class ModulePermission {
  final bool create;
  final bool edit;
  final bool view;

  const ModulePermission({
    this.create = false,
    this.edit = false,
    this.view = true,
  });

  factory ModulePermission.fromJson(Map<String, dynamic> json) =>
      _$ModulePermissionFromJson(json);

  Map<String, dynamic> toJson() => _$ModulePermissionToJson(this);

  ModulePermission copyWith({bool? create, bool? edit, bool? view}) {
    return ModulePermission(
      create: create ?? this.create,
      edit: edit ?? this.edit,
      view: view ?? this.view,
    );
  }

  bool get hasAny => create || edit || view;
}

@JsonSerializable(explicitToJson: true)
class DealerPermissions {
  final ModulePermission vehicles;
  final ModulePermission sales;
  final ModulePermission dealers;

  const DealerPermissions({
    this.vehicles = const ModulePermission(),
    this.sales = const ModulePermission(),
    this.dealers = const ModulePermission(),
  });

  factory DealerPermissions.defaults() =>
      const DealerPermissions(vehicles: ModulePermission(), sales: ModulePermission(), dealers: ModulePermission());

  factory DealerPermissions.fromJson(Map<String, dynamic> json) =>
      _$DealerPermissionsFromJson(json);

  Map<String, dynamic> toJson() => _$DealerPermissionsToJson(this);

  DealerPermissions copyWith({
    ModulePermission? vehicles,
    ModulePermission? sales,
    ModulePermission? dealers,
  }) {
    return DealerPermissions(
      vehicles: vehicles ?? this.vehicles,
      sales: sales ?? this.sales,
      dealers: dealers ?? this.dealers,
    );
  }
}
