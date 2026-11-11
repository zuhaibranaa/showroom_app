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
  final ModulePermissionEntity expenses;
  final ModulePermissionEntity registrationTransfer;
  final ModulePermissionEntity reports;
  final ModulePermissionEntity documents;
  final ModulePermissionEntity biometrics;
  final ModulePermissionEntity pendingPayments;
  final ModulePermissionEntity retailPrices;

  const DealerPermissionsEntity({
    this.vehicles = const ModulePermissionEntity(),
    this.sales = const ModulePermissionEntity(),
    this.dealers = const ModulePermissionEntity(),
    this.expenses = const ModulePermissionEntity(),
    this.registrationTransfer = const ModulePermissionEntity(),
    this.reports = const ModulePermissionEntity(),
    this.documents = const ModulePermissionEntity(),
    this.biometrics = const ModulePermissionEntity(),
    this.pendingPayments = const ModulePermissionEntity(),
    this.retailPrices = const ModulePermissionEntity(),
  });

  @override
  List<Object?> get props => [vehicles, sales, dealers, expenses, registrationTransfer, reports, documents, biometrics, pendingPayments, retailPrices];

  DealerPermissionsEntity copyWith({
    ModulePermissionEntity? vehicles,
    ModulePermissionEntity? sales,
    ModulePermissionEntity? dealers,
    ModulePermissionEntity? expenses,
    ModulePermissionEntity? registrationTransfer,
    ModulePermissionEntity? reports,
    ModulePermissionEntity? documents,
    ModulePermissionEntity? biometrics,
    ModulePermissionEntity? pendingPayments,
    ModulePermissionEntity? retailPrices,
  }) {
    return DealerPermissionsEntity(
      vehicles: vehicles ?? this.vehicles,
      sales: sales ?? this.sales,
      dealers: dealers ?? this.dealers,
      expenses: expenses ?? this.expenses,
      registrationTransfer: registrationTransfer ?? this.registrationTransfer,
      reports: reports ?? this.reports,
      documents: documents ?? this.documents,
      biometrics: biometrics ?? this.biometrics,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      retailPrices: retailPrices ?? this.retailPrices,
    );
  }
}
