import '../entities/vehicle.dart';

/// Read-side contract for vehicle data. Clients that only need to read
/// vehicles depend on this interface and are not forced to know about writes.
abstract class IVehicleReadRepository {
  Future<List<VehicleEntity>> getAll();
  Future<List<VehicleEntity>> getByAgency(String agencyId);
  Future<VehicleEntity?> getById(String id);
  Stream<List<VehicleEntity>> streamAll();
  Stream<List<VehicleEntity>> streamByAgency(String agencyId);
}

/// Write-side contract for vehicle data.
abstract class IVehicleWriteRepository {
  Future<String> create(VehicleEntity vehicle);
  Future<void> update(String id, VehicleEntity vehicle);
  Future<void> delete(String id);
}

/// Full vehicle repository contract (read + write).
abstract class IVehicleRepository
    implements IVehicleReadRepository, IVehicleWriteRepository {}
