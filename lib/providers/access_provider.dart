import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/access_service_compat.dart';
import '../compat/model_converters.dart';
import '../core/domain/entities/agency.dart';
import '../core/domain/entities/dealer.dart';
import '../core/domain/entities/sale.dart';
import '../core/domain/entities/user.dart';
import '../core/domain/entities/vehicle.dart';
import '../core/domain/services/access_service.dart';
import '../models/agency_model.dart';
import '../models/dealer_model.dart';
import '../models/dealer_permissions.dart';
import '../models/sale_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import 'agency_provider.dart';
import 'auth_provider.dart';
import 'dealer_provider.dart';
import 'sale_provider.dart';
import 'vehicle_provider.dart';

/// Access service provider (DIP: depend on [IAccessService] abstraction).
final accessServiceProvider = Provider<IAccessService>((ref) {
  return AccessServiceAdapter();
});

/// Combines one stream per agency into a single list stream.
/// Results are deduplicated by document ID so a record that appears under
/// more than one agency is never listed twice.
Stream<List<T>> _mergeAgencyStreams<T>(
  List<String> agencyIds,
  Stream<List<T>> Function(String agencyId) streamFor,
  String Function(T) idOf,
) {
  if (agencyIds.isEmpty) return Stream.value(const []);
  late StreamController<List<T>> controller;
  final state = <String, List<T>>{};
  final subs = <StreamSubscription<void>>[];
  controller = StreamController<List<T>>(
    onListen: () {
      for (final id in agencyIds) {
        final sub = streamFor(id).listen(
          (list) {
            state[id] = list;
            final seen = <String>{};
            final merged = <T>[];
            for (final agencyList in state.values) {
              for (final item in agencyList) {
                if (seen.add(idOf(item))) merged.add(item);
              }
            }
            controller.add(merged);
          },
          onError: controller.addError,
        );
        subs.add(sub);
      }
    },
    onCancel: () async {
      for (final sub in subs) {
        await sub.cancel();
      }
      subs.clear();
    },
  );
  return controller.stream;
}

/// Agencies the current user is allowed to work with:
/// all agencies for a super admin, only their own for an admin.
final accessibleAgenciesProvider = FutureProvider<List<AgencyModel>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return const [];
  final agencyService = ref.watch(agencyApplicationServiceProvider);
  final accessService = ref.watch(accessServiceProvider);
  if (accessService.isSuperAdmin(userModelToEntity(user))) {
    final entities = await agencyService.getAll();
    return entities.map(agencyEntityToModel).toList();
  }
  final entities = await agencyService.getByIds(user.agencyIds);
  return entities.map(agencyEntityToModel).toList();
});

/// Vehicles visible to the signed-in staff user.
final accessibleVehiclesProvider = StreamProvider<List<VehicleModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  final accessService = ref.watch(accessServiceProvider);
  if (accessService.isSuperAdmin(userModelToEntity(user))) {
    return vehicleService.streamAll().map((entities) =>
        entities.map(vehicleEntityToModel).toList());
  }
  return _mergeAgencyStreams(
    user.agencyIds,
    (id) => vehicleService.streamByAgency(id).map((entities) =>
        entities.map(vehicleEntityToModel).toList()),
    (v) => v.id,
  );
});

/// Sales visible to the signed-in staff user.
final accessibleSalesProvider = StreamProvider<List<SaleModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  final saleService = ref.watch(saleApplicationServiceProvider);
  final accessService = ref.watch(accessServiceProvider);
  if (accessService.isSuperAdmin(userModelToEntity(user))) {
    return saleService.streamAll().map((entities) =>
        entities.map(saleEntityToModel).toList());
  }
  return _mergeAgencyStreams(
    user.agencyIds,
    (id) => saleService.streamByAgency(id).map((entities) =>
        entities.map(saleEntityToModel).toList()),
    (s) => s.id,
  );
});

/// Dealers visible to the signed-in staff user.
final accessibleDealersProvider = StreamProvider<List<DealerModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  final accessService = ref.watch(accessServiceProvider);
  if (accessService.isSuperAdmin(userModelToEntity(user))) {
    return dealerService.streamAll().map((entities) =>
        entities.map(dealerEntityToModel).toList());
  }
  return _mergeAgencyStreams(
    user.agencyIds,
    (id) => dealerService.streamByAgency(id).map((entities) =>
        entities.map(dealerEntityToModel).toList()),
    (d) => d.id,
  );
});

/// Backward-compatible static access service for screens.
/// Delegates to [AccessServiceCompat] which uses [IAccessService] internally.
class AccessService {
  static bool isSuperAdmin(UserModel? user) =>
      AccessServiceCompat.isSuperAdmin(user);
  static bool isAdmin(UserModel? user) => AccessServiceCompat.isAdmin(user);
  static bool isDealer(UserModel? user) => AccessServiceCompat.isDealer(user);
  static bool isStaff(UserModel? user) => AccessServiceCompat.isStaff(user);
  static bool isAgencyOwner(UserModel? user) =>
      AccessServiceCompat.isAgencyOwner(user);
  static bool canInviteAgencyAdmin(UserModel? user) =>
      AccessServiceCompat.canInviteAgencyAdmin(user);

  static bool dealerCanView(DealerModel? dealer, String module) {
    if (dealer == null) return false;
    switch (module) {
      case 'vehicles':
        return dealer.permissions.vehicles.view;
      case 'sales':
        return dealer.permissions.sales.view;
      case 'dealers':
        return dealer.permissions.dealers.view;
      case 'expenses':
        return dealer.permissions.expenses.view;
      case 'registrationTransfer':
        return dealer.permissions.registrationTransfer.view;
      case 'reports':
        return dealer.permissions.reports.view;
      case 'documents':
        return dealer.permissions.documents.view;
      case 'biometrics':
        return dealer.permissions.biometrics.view;
      case 'pendingPayments':
        return dealer.permissions.pendingPayments.view;
      case 'retailPrices':
        return dealer.permissions.retailPrices.view;
      default:
        return false;
    }
  }

  static bool dealerCanCreate(DealerModel? dealer, String module) {
    if (dealer == null) return false;
    switch (module) {
      case 'vehicles':
        return dealer.permissions.vehicles.create;
      case 'sales':
        return dealer.permissions.sales.create;
      case 'dealers':
        return dealer.permissions.dealers.create;
      case 'expenses':
        return dealer.permissions.expenses.create;
      case 'registrationTransfer':
        return dealer.permissions.registrationTransfer.create;
      case 'reports':
        return dealer.permissions.reports.create;
      case 'documents':
        return dealer.permissions.documents.create;
      case 'biometrics':
        return dealer.permissions.biometrics.create;
      case 'pendingPayments':
        return dealer.permissions.pendingPayments.create;
      case 'retailPrices':
        return dealer.permissions.retailPrices.create;
      default:
        return false;
    }
  }

  static bool dealerCanEdit(DealerModel? dealer, String module) {
    if (dealer == null) return false;
    switch (module) {
      case 'vehicles':
        return dealer.permissions.vehicles.edit;
      case 'sales':
        return dealer.permissions.sales.edit;
      case 'dealers':
        return dealer.permissions.dealers.edit;
      case 'expenses':
        return dealer.permissions.expenses.edit;
      case 'registrationTransfer':
        return dealer.permissions.registrationTransfer.edit;
      case 'reports':
        return dealer.permissions.reports.edit;
      case 'documents':
        return dealer.permissions.documents.edit;
      case 'biometrics':
        return dealer.permissions.biometrics.edit;
      case 'pendingPayments':
        return dealer.permissions.pendingPayments.edit;
      case 'retailPrices':
        return dealer.permissions.retailPrices.edit;
      default:
        return false;
    }
  }

  static bool dealerCanDelete(DealerModel? dealer, String module) {
    if (dealer == null) return false;
    switch (module) {
      case 'vehicles':
        return dealer.permissions.vehicles.edit; // reuse edit as delete
      case 'sales':
        return dealer.permissions.sales.edit;
      case 'dealers':
        return dealer.permissions.dealers.edit;
      case 'expenses':
        return dealer.permissions.expenses.edit;
      case 'registrationTransfer':
        return dealer.permissions.registrationTransfer.edit;
      case 'reports':
        return dealer.permissions.reports.edit;
      case 'documents':
        return dealer.permissions.documents.edit;
      case 'biometrics':
        return dealer.permissions.biometrics.edit;
      case 'pendingPayments':
        return dealer.permissions.pendingPayments.edit;
      case 'retailPrices':
        return dealer.permissions.retailPrices.edit;
      default:
        return false;
    }
  }

  /// Whether [user] can manage [agencyId] (super admin or agency owner of that agency).
  static bool canManageAgency(UserModel? user, String agencyId) {
    if (user == null) return false;
    return AccessServiceCompat.canManageAgency(user, agencyId);
  }

  /// Whether [user] can access [module] within [agencyId].
  static bool canAccessModule(UserModel? user, String module, String agencyId) {
    if (user == null) return false;
    return AccessServiceCompat.canAccessModule(user, module, agencyId);
  }
}

/// Resolves a dealer's actual module permissions from their stored
/// [DealerModel]. Returns a map of module name -> ModulePermission.
final dealerRbacProvider =
    Provider.family<Map<String, ModulePermission>, String>((ref, dealerId) {
  final dealerAsync = ref.watch(dealerByIdProvider(dealerId));
  final p = dealerAsync.value?.permissions;
  return {
    'vehicles': p?.vehicles ?? const ModulePermission(),
    'sales': p?.sales ?? const ModulePermission(),
    'dealers': p?.dealers ?? const ModulePermission(),
    'expenses': p?.expenses ?? const ModulePermission(),
    'registrationTransfer':
        p?.registrationTransfer ?? const ModulePermission(),
    'reports': p?.reports ?? const ModulePermission(),
    'documents': p?.documents ?? const ModulePermission(),
    'biometrics': p?.biometrics ?? const ModulePermission(),
    'pendingPayments': p?.pendingPayments ?? const ModulePermission(),
    'retailPrices': p?.retailPrices ?? const ModulePermission(),
  };
});

/// The agency the currently signed-in user belongs to.
///
/// - Super admin: returns the first agency (or null if none exist).
/// - Agency owner / admin: returns their own agency.
/// - Dealer: returns their agencyId.
final currentAgencyProvider = FutureProvider<AgencyModel?>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return null;
  final accessService = ref.watch(accessServiceProvider);
  final agencyService = ref.watch(agencyApplicationServiceProvider);
  if (accessService.isSuperAdmin(userModelToEntity(user))) {
    final all = await agencyService.getAll();
    return all.isNotEmpty ? agencyEntityToModel(all.first) : null;
  }
  // Agency owner or dealer: resolve their single agency.
  final agencyId = user.agencyId;
  if (agencyId != null && agencyId.isNotEmpty) {
    final entity = await agencyService.getById(agencyId);
    return entity != null ? agencyEntityToModel(entity) : null;
  }
  // Admin with multiple agencyIds: return the first.
  if (user.agencyIds.isNotEmpty) {
    final entity = await agencyService.getById(user.agencyIds.first);
    return entity != null ? agencyEntityToModel(entity) : null;
  }
  return null;
});

/// Whether the current user can access [module] within their own agency.
///
/// Convenience provider that combines [currentUserProvider],
/// [currentAgencyProvider], and [AccessService].
final currentUserCanAccessModuleProvider =
    FutureProvider.family<bool, String>((ref, module) async {
  final user = ref.watch(currentUserProvider).value;
  final agency = await ref.watch(currentAgencyProvider.future);
  if (user == null || agency == null) return false;
  return AccessService.canAccessModule(user, module, agency.id);
});

/// Whether the current user can manage their own agency.
final currentUserCanManageAgencyProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  final agency = await ref.watch(currentAgencyProvider.future);
  if (user == null || agency == null) return false;
  return AccessService.canManageAgency(user, agency.id);
});
