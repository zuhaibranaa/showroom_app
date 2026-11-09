import '../entities/sale.dart';

/// Read-side contract for sale data.
abstract class ISaleReadRepository {
  Future<List<SaleEntity>> getAll();
  Future<List<SaleEntity>> getByAgency(String agencyId);
  Future<List<SaleEntity>> getByVehicle(String vehicleId);
  Future<List<SaleEntity>> getByDealer(String dealerId);
  Future<SaleEntity?> getById(String id);
  Stream<List<SaleEntity>> streamAll();
  Stream<List<SaleEntity>> streamByAgency(String agencyId);
  Stream<List<SaleEntity>> streamByDealer(String dealerId);
}

/// Write-side contract for sale data.
abstract class ISaleWriteRepository {
  Future<String> create(SaleEntity sale);
  Future<void> update(String id, SaleEntity sale);
  Future<void> delete(String id);
}

/// Full sale repository contract (read + write).
abstract class ISaleRepository
    implements ISaleReadRepository, ISaleWriteRepository {}
