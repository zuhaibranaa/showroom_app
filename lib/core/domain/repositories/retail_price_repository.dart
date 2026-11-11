import '../entities/retail_price.dart';

/// Read-side contract for retail price data.
abstract class IRetailPriceReadRepository {
  Future<List<RetailPriceEntity>> getAll();
  Future<List<RetailPriceEntity>> getByAgency(String agencyId);
  Future<RetailPriceEntity?> getById(String id);
  Future<RetailPriceEntity?> getByMakeModel(String agencyId, String make, String model);
  Stream<List<RetailPriceEntity>> streamAll();
  Stream<List<RetailPriceEntity>> streamByAgency(String agencyId);
}

/// Write-side contract for retail price data.
abstract class IRetailPriceWriteRepository {
  Future<String> create(RetailPriceEntity price);
  Future<void> update(String id, RetailPriceEntity price);
  Future<void> delete(String id);
}

/// Full retail price repository contract (read + write).
abstract class IRetailPriceRepository
    implements IRetailPriceReadRepository, IRetailPriceWriteRepository {}
