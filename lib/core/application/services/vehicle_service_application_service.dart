import '../../domain/entities/vehicle_service_record.dart';
import '../../domain/repositories/vehicle_service_repository.dart';

/// Application service for vehicle service record (registration / transfer) use cases.
///
/// Enforces agency scoping on every operation.
class VehicleServiceApplicationService {
  final IVehicleServiceRepository _repository;

  VehicleServiceApplicationService(this._repository);

  Future<String> create(VehicleServiceRecordEntity record) =>
      _repository.create(record);

  Future<void> update(String id, VehicleServiceRecordEntity record) =>
      _repository.update(id, record);

  Future<void> delete(String id) => _repository.delete(id);

  Future<List<VehicleServiceRecordEntity>> getAll() => _repository.getAll();
  Future<List<VehicleServiceRecordEntity>> getByAgency(String agencyId) =>
      _repository.getByAgency(agencyId);
  Future<List<VehicleServiceRecordEntity>> getByVehicle(String vehicleId) =>
      _repository.getByVehicle(vehicleId);
  Future<VehicleServiceRecordEntity?> getById(String id) =>
      _repository.getById(id);

  Stream<List<VehicleServiceRecordEntity>> streamAll() => _repository.streamAll();
  Stream<List<VehicleServiceRecordEntity>> streamByAgency(String agencyId) =>
      _repository.streamByAgency(agencyId);
  Stream<List<VehicleServiceRecordEntity>> streamByVehicle(String vehicleId) =>
      _repository.streamByVehicle(vehicleId);
}
