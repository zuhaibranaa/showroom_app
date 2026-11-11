import '../entities/vehicle_service_record.dart';

/// Read-side contract for vehicle service record data.
abstract class IVehicleServiceReadRepository {
  Future<List<VehicleServiceRecordEntity>> getAll();
  Future<List<VehicleServiceRecordEntity>> getByAgency(String agencyId);
  Future<List<VehicleServiceRecordEntity>> getByVehicle(String vehicleId);
  Future<VehicleServiceRecordEntity?> getById(String id);
  Stream<List<VehicleServiceRecordEntity>> streamAll();
  Stream<List<VehicleServiceRecordEntity>> streamByAgency(String agencyId);
  Stream<List<VehicleServiceRecordEntity>> streamByVehicle(String vehicleId);
}

/// Write-side contract for vehicle service record data.
abstract class IVehicleServiceWriteRepository {
  Future<String> create(VehicleServiceRecordEntity record);
  Future<void> update(String id, VehicleServiceRecordEntity record);
  Future<void> delete(String id);
}

/// Full vehicle service record repository contract (read + write).
abstract class IVehicleServiceRepository
    implements IVehicleServiceReadRepository, IVehicleServiceWriteRepository {}
