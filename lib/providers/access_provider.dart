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
      default:
        return false;
    }
  }
}
