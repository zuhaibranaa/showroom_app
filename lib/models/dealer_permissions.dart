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
    this.view = false,
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
  final ModulePermission expenses;
  final ModulePermission registrationTransfer;
  final ModulePermission reports;
  final ModulePermission documents;
  final ModulePermission biometrics;
  final ModulePermission pendingPayments;
  final ModulePermission retailPrices;

  const DealerPermissions({
    this.vehicles = const ModulePermission(),
    this.sales = const ModulePermission(),
    this.dealers = const ModulePermission(),
    this.expenses = const ModulePermission(),
    this.registrationTransfer = const ModulePermission(),
    this.reports = const ModulePermission(),
    this.documents = const ModulePermission(),
    this.biometrics = const ModulePermission(),
    this.pendingPayments = const ModulePermission(),
    this.retailPrices = const ModulePermission(),
  });

  factory DealerPermissions.defaults() =>
      const DealerPermissions(vehicles: ModulePermission(), sales: ModulePermission(), dealers: ModulePermission(), expenses: ModulePermission(), registrationTransfer: ModulePermission(), reports: ModulePermission(), documents: ModulePermission(), biometrics: ModulePermission(), pendingPayments: ModulePermission(), retailPrices: ModulePermission());

  factory DealerPermissions.fromJson(Map<String, dynamic> json) =>
      _$DealerPermissionsFromJson(json);

  Map<String, dynamic> toJson() => _$DealerPermissionsToJson(this);

  DealerPermissions copyWith({
    ModulePermission? vehicles,
    ModulePermission? sales,
    ModulePermission? dealers,
    ModulePermission? expenses,
    ModulePermission? registrationTransfer,
    ModulePermission? reports,
    ModulePermission? documents,
    ModulePermission? biometrics,
    ModulePermission? pendingPayments,
    ModulePermission? retailPrices,
  }) {
    return DealerPermissions(
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
