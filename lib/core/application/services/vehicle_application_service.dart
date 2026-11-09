import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

/// Application service for vehicle use cases.
class VehicleApplicationService {
  final IVehicleRepository _repository;

  VehicleApplicationService(this._repository);

  Future<String> create(VehicleEntity vehicle) => _repository.create(vehicle);
  Future<void> update(String id, VehicleEntity vehicle) =>
      _repository.update(id, vehicle);
  Future<void> delete(String id) => _repository.delete(id);

  Future<List<VehicleEntity>> getAll() => _repository.getAll();
  Future<List<VehicleEntity>> getByAgency(String agencyId) =>
      _repository.getByAgency(agencyId);
  Future<VehicleEntity?> getById(String id) => _repository.getById(id);

  Stream<List<VehicleEntity>> streamAll() => _repository.streamAll();
  Stream<List<VehicleEntity>> streamByAgency(String agencyId) =>
      _repository.streamByAgency(agencyId);
}
