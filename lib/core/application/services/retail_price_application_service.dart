import '../../domain/entities/retail_price.dart';
import '../../domain/repositories/retail_price_repository.dart';

/// Application service for retail price use cases.
///
/// Enforces agency scoping on every operation.
class RetailPriceApplicationService {
  final IRetailPriceRepository _repository;

  RetailPriceApplicationService(this._repository);

  Future<String> create(RetailPriceEntity price) => _repository.create(price);

  Future<void> update(String id, RetailPriceEntity price) =>
      _repository.update(id, price);

  Future<void> delete(String id) => _repository.delete(id);

  Future<List<RetailPriceEntity>> getAll() => _repository.getAll();
  Future<List<RetailPriceEntity>> getByAgency(String agencyId) =>
      _repository.getByAgency(agencyId);
  Future<RetailPriceEntity?> getById(String id) => _repository.getById(id);
  Future<RetailPriceEntity?> getByMakeModel(
          String agencyId, String make, String model) =>
      _repository.getByMakeModel(agencyId, make, model);

  Stream<List<RetailPriceEntity>> streamAll() => _repository.streamAll();
  Stream<List<RetailPriceEntity>> streamByAgency(String agencyId) =>
      _repository.streamByAgency(agencyId);
}
