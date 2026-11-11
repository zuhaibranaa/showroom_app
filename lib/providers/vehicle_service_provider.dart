import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../core/application/services/vehicle_service_application_service.dart';
import '../core/domain/entities/vehicle_service_record.dart';
import '../core/domain/repositories/vehicle_service_repository.dart';
import '../infrastructure/repositories/firestore_vehicle_service_repository.dart';
import '../models/operations_models.dart';

// Repository provider (DIP: depends on abstraction)
final vehicleServiceRepositoryProvider =
    Provider<IVehicleServiceRepository>((ref) {
  return FirestoreVehicleServiceRepository(FirebaseFirestore.instance);
});

// Application service provider (depends on repository abstraction)
final vehicleServiceApplicationServiceProvider =
    Provider<VehicleServiceApplicationService>((ref) {
  return VehicleServiceApplicationService(
    ref.watch(vehicleServiceRepositoryProvider),
  );
});

// Vehicle service model providers (agency-scoped)
final vehicleServicesByAgencyProvider =
    FutureProvider.family<List<VehicleServiceRecord>, String>((ref, agencyId) async {
  final service = ref.watch(vehicleServiceApplicationServiceProvider);
  final entities = await service.getByAgency(agencyId);
  return entities.map(vehicleServiceRecordEntityToModel).toList();
});

final vehicleServicesStreamByAgencyProvider =
    StreamProvider.family<List<VehicleServiceRecord>, String>((ref, agencyId) {
  final service = ref.watch(vehicleServiceApplicationServiceProvider);
  return service.streamByAgency(agencyId).map((entities) =>
      entities.map(vehicleServiceRecordEntityToModel).toList());
});

final vehicleServiceByIdProvider =
    FutureProvider.family<VehicleServiceRecord?, String>((ref, id) async {
  final service = ref.watch(vehicleServiceApplicationServiceProvider);
  final entity = await service.getById(id);
  return entity != null ? vehicleServiceRecordEntityToModel(entity) : null;
});

// Create vehicle service state
final createVehicleServiceProvider =
    StateNotifierProvider<CreateVehicleServiceNotifier, AsyncValue<String>>(
  (ref) {
    final service = ref.watch(vehicleServiceApplicationServiceProvider);
    return CreateVehicleServiceNotifier(service);
  },
);

class CreateVehicleServiceNotifier
    extends StateNotifier<AsyncValue<String>> {
  final VehicleServiceApplicationService _service;

  CreateVehicleServiceNotifier(this._service)
      : super(const AsyncValue.data(''));

  Future<void> createVehicleService(VehicleServiceRecord record) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.create(vehicleServiceRecordModelToEntity(record)),
    );
  }
}

// Update vehicle service state
final updateVehicleServiceProvider =
    StateNotifierProvider<UpdateVehicleServiceNotifier, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(vehicleServiceApplicationServiceProvider);
    return UpdateVehicleServiceNotifier(service);
  },
);

class UpdateVehicleServiceNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleServiceApplicationService _service;

  UpdateVehicleServiceNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> updateVehicleService(
          String id, VehicleServiceRecord record) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.update(id, vehicleServiceRecordModelToEntity(record)),
    );
  }
}

// Delete vehicle service state
final deleteVehicleServiceProvider =
    StateNotifierProvider<DeleteVehicleServiceNotifier, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(vehicleServiceApplicationServiceProvider);
    return DeleteVehicleServiceNotifier(service);
  },
);

class DeleteVehicleServiceNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleServiceApplicationService _service;

  DeleteVehicleServiceNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> deleteVehicleService(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.delete(id));
  }
}
