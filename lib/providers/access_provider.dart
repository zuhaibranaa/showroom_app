import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Centralized RBAC helpers for the app.
class AccessService {
  static bool isSuperAdmin(UserModel? user) => user?.role == 'super_admin';
  static bool isAdmin(UserModel? user) => user?.role == 'admin';
  static bool isDealer(UserModel? user) => user?.role == 'dealer';
  static bool isStaff(UserModel? user) => isSuperAdmin(user) || isAdmin(user);

  /// Resolves the permission block a dealer has for a module.
  static ModulePermission dealerPermission(DealerModel dealer, String module) {
    switch (module) {
      case 'vehicles':
        return dealer.permissions.vehicles;
      case 'sales':
        return dealer.permissions.sales;
      case 'dealers':
        return dealer.permissions.dealers;
      default:
        return const ModulePermission();
    }
  }

  static bool dealerCanView(DealerModel dealer, String module) =>
      dealerPermission(dealer, module).view;

  static bool dealerCanCreate(DealerModel dealer, String module) =>
      dealerPermission(dealer, module).create;

  static bool dealerCanEdit(DealerModel dealer, String module) =>
      dealerPermission(dealer, module).edit;
}

// Combines one stream per agency into a single list stream.
Stream<List<T>> _mergeAgencyStreams<T>(
  List<String> agencyIds,
  Stream<List<T>> Function(String agencyId) streamFor,
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
            controller.add(state.values.expand((e) => e).toList());
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
  final agencyService = ref.watch(agencyServiceProvider);
  if (AccessService.isSuperAdmin(user)) {
    return agencyService.getAgencies();
  }
  return agencyService.getAgenciesByIds(user.agencyIds);
});

/// Vehicles visible to the signed-in staff user.
final accessibleVehiclesProvider = StreamProvider<List<VehicleModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  final vehicleService = ref.watch(vehicleServiceProvider);
  if (AccessService.isSuperAdmin(user)) {
    return vehicleService.vehiclesStream();
  }
  return _mergeAgencyStreams(user.agencyIds, vehicleService.vehiclesStreamByAgency);
});

/// Sales visible to the signed-in staff user.
final accessibleSalesProvider = StreamProvider<List<SaleModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  final saleService = ref.watch(saleServiceProvider);
  if (AccessService.isSuperAdmin(user)) {
    return saleService.salesStream();
  }
  return _mergeAgencyStreams(user.agencyIds, saleService.salesStreamByAgency);
});

/// Dealers visible to the signed-in staff user.
final accessibleDealersProvider = StreamProvider<List<DealerModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  final dealerService = ref.watch(dealerServiceProvider);
  if (AccessService.isSuperAdmin(user)) {
    return dealerService.dealersStream();
  }
  return _mergeAgencyStreams(user.agencyIds, dealerService.dealersStreamByAgency);
});
