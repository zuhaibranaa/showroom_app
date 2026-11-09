import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../core/application/services/vehicle_application_service.dart';
import '../core/domain/entities/vehicle.dart';
import '../core/domain/repositories/vehicle_repository.dart';
import '../infrastructure/repositories/firestore_vehicle_repository.dart';
import '../models/vehicle_model.dart';

// Repository provider (DIP: depends on abstraction)
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) {
  return FirestoreVehicleRepository(FirebaseFirestore.instance);
});

// Application service provider (depends on repository abstraction)
final vehicleApplicationServiceProvider =
    Provider<VehicleApplicationService>((ref) {
  return VehicleApplicationService(ref.watch(vehicleRepositoryProvider));
});

// Vehicle model providers (backward compatible with screens)
final vehiclesProvider = FutureProvider<List<VehicleModel>>((ref) async {
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  final entities = await vehicleService.getAll();
  return entities.map(vehicleEntityToModel).toList();
});

final vehiclesStreamProvider = StreamProvider<List<VehicleModel>>((ref) {
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  return vehicleService.streamAll().map((entities) =>
      entities.map(vehicleEntityToModel).toList());
});

final vehiclesByAgencyProvider =
    FutureProvider.family<List<VehicleModel>, String>((ref, agencyId) async {
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  final entities = await vehicleService.getByAgency(agencyId);
  return entities.map(vehicleEntityToModel).toList();
});

final vehiclesStreamByAgencyProvider =
    StreamProvider.family<List<VehicleModel>, String>((ref, agencyId) {
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  return vehicleService.streamByAgency(agencyId).map((entities) =>
      entities.map(vehicleEntityToModel).toList());
});

final vehicleByIdProvider =
    FutureProvider.family<VehicleModel?, String>((ref, id) async {
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  final entity = await vehicleService.getById(id);
  return entity != null ? vehicleEntityToModel(entity) : null;
});

/// Vehicle lookup that resolves to `null` for an empty/missing id instead of
/// throwing, for screens that reference an optional related record.
final vehicleByIdOrNullProvider =
    FutureProvider.family<VehicleModel?, String>((ref, id) async {
  if (id.isEmpty) return null;
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  final entity = await vehicleService.getById(id);
  return entity != null ? vehicleEntityToModel(entity) : null;
});

// Create vehicle state
final createVehicleProvider =
    StateNotifierProvider<CreateVehicleNotifier, AsyncValue<String>>((ref) {
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  return CreateVehicleNotifier(vehicleService);
});

class CreateVehicleNotifier extends StateNotifier<AsyncValue<String>> {
  final VehicleApplicationService _vehicleService;

  CreateVehicleNotifier(this._vehicleService)
      : super(const AsyncValue.data(''));

  Future<void> createVehicle(VehicleModel vehicle) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _vehicleService.create(vehicleModelToEntity(vehicle)),
    );
  }
}

// Update vehicle state
final updateVehicleProvider =
    StateNotifierProvider<UpdateVehicleNotifier, AsyncValue<void>>((ref) {
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  return UpdateVehicleNotifier(vehicleService);
});

class UpdateVehicleNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleApplicationService _vehicleService;

  UpdateVehicleNotifier(this._vehicleService)
      : super(const AsyncValue.data(null));

  Future<void> updateVehicle(String id, VehicleModel vehicle) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _vehicleService.update(id, vehicleModelToEntity(vehicle)),
    );
  }
}

// Delete vehicle state
final deleteVehicleProvider =
    StateNotifierProvider<DeleteVehicleNotifier, AsyncValue<void>>((ref) {
  final vehicleService = ref.watch(vehicleApplicationServiceProvider);
  return DeleteVehicleNotifier(vehicleService);
});

class DeleteVehicleNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleApplicationService _vehicleService;

  DeleteVehicleNotifier(this._vehicleService)
      : super(const AsyncValue.data(null));

  Future<void> deleteVehicle(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _vehicleService.delete(id),
    );
  }
}
