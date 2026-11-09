import 'package:equatable/equatable.dart';

/// Permission for a single module (vehicles, sales, dealers).
class ModulePermissionEntity extends Equatable {
  final bool create;
  final bool edit;
  final bool view;

  const ModulePermissionEntity({
    this.create = false,
    this.edit = false,
    this.view = false,
  });

  bool get hasAny => create || edit || view;

  @override
  List<Object?> get props => [create, edit, view];

  ModulePermissionEntity copyWith({bool? create, bool? edit, bool? view}) {
    return ModulePermissionEntity(
      create: create ?? this.create,
      edit: edit ?? this.edit,
      view: view ?? this.view,
    );
  }
}

/// Dealer-level permissions across modules.
class DealerPermissionsEntity extends Equatable {
  final ModulePermissionEntity vehicles;
  final ModulePermissionEntity sales;
  final ModulePermissionEntity dealers;

  const DealerPermissionsEntity({
    this.vehicles = const ModulePermissionEntity(),
    this.sales = const ModulePermissionEntity(),
    this.dealers = const ModulePermissionEntity(),
  });

  @override
  List<Object?> get props => [vehicles, sales, dealers];

  DealerPermissionsEntity copyWith({
    ModulePermissionEntity? vehicles,
    ModulePermissionEntity? sales,
    ModulePermissionEntity? dealers,
  }) {
    return DealerPermissionsEntity(
      vehicles: vehicles ?? this.vehicles,
      sales: sales ?? this.sales,
      dealers: dealers ?? this.dealers,
    );
  }
}
