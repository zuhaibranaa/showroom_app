import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle_model.dart';

// Vehicle Service Provider
final vehicleServiceProvider = Provider((ref) => VehicleService());

// Get all vehicles
final vehiclesProvider = FutureProvider<List<VehicleModel>>((ref) async {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.getVehicles();
});

// Stream vehicles
final vehiclesStreamProvider = StreamProvider<List<VehicleModel>>((ref) {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.vehiclesStream();
});

// Get vehicles for an agency (Admin)
final vehiclesByAgencyProvider =
    FutureProvider.family<List<VehicleModel>, String>((ref, agencyId) async {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.getVehiclesByAgency(agencyId);
});

// Stream vehicles for an agency (Admin)
final vehiclesStreamByAgencyProvider =
    StreamProvider.family<List<VehicleModel>, String>((ref, agencyId) {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.vehiclesStreamByAgency(agencyId);
});

// Get vehicle by ID
final vehicleByIdProvider =
    FutureProvider.family<VehicleModel, String>((ref, id) async {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.getVehicleById(id);
});

/// Vehicle lookup that resolves to `null` for an empty/missing id instead of
/// throwing, for screens that reference an optional related record.
final vehicleByIdOrNullProvider =
    FutureProvider.family<VehicleModel?, String>((ref, id) async {
  if (id.isEmpty) return null;
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.getVehicleById(id);
});

// Create vehicle state
final createVehicleProvider =
    StateNotifierProvider<CreateVehicleNotifier, AsyncValue<String>>((ref) {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return CreateVehicleNotifier(vehicleService);
});

class CreateVehicleNotifier extends StateNotifier<AsyncValue<String>> {
  final VehicleService _vehicleService;

  CreateVehicleNotifier(this._vehicleService)
      : super(const AsyncValue.data(''));

  Future<void> createVehicle(VehicleModel vehicle) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _vehicleService.createVehicle(vehicle),
    );
  }
}

// Update vehicle state
final updateVehicleProvider =
    StateNotifierProvider<UpdateVehicleNotifier, AsyncValue<void>>((ref) {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return UpdateVehicleNotifier(vehicleService);
});

class UpdateVehicleNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleService _vehicleService;

  UpdateVehicleNotifier(this._vehicleService) : super(const AsyncValue.data(null));

  Future<void> updateVehicle(String id, VehicleModel vehicle) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _vehicleService.updateVehicle(id, vehicle),
    );
  }
}

// Delete vehicle state
final deleteVehicleProvider =
    StateNotifierProvider<DeleteVehicleNotifier, AsyncValue<void>>((ref) {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return DeleteVehicleNotifier(vehicleService);
});

class DeleteVehicleNotifier extends StateNotifier<AsyncValue<void>> {
  final VehicleService _vehicleService;

  DeleteVehicleNotifier(this._vehicleService) : super(const AsyncValue.data(null));

  Future<void> deleteVehicle(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _vehicleService.deleteVehicle(id),
    );
  }
}
