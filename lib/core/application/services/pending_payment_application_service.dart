import '../../domain/entities/pending_payment.dart';
import '../../domain/repositories/pending_payment_repository.dart';

/// Application service for pending payment use cases.
///
/// Enforces agency scoping on every operation.
class PendingPaymentApplicationService {
  final IPendingPaymentRepository _repository;

  PendingPaymentApplicationService(this._repository);

  Future<String> create(PendingPaymentEntity payment) =>
      _repository.create(payment);

  Future<void> update(String id, PendingPaymentEntity payment) =>
      _repository.update(id, payment);

  Future<void> delete(String id) => _repository.delete(id);

  Future<List<PendingPaymentEntity>> getAll() => _repository.getAll();
  Future<List<PendingPaymentEntity>> getByAgency(String agencyId) =>
      _repository.getByAgency(agencyId);
  Future<List<PendingPaymentEntity>> getBySale(String saleId) =>
      _repository.getBySale(saleId);
  Future<List<PendingPaymentEntity>> getByVehicle(String vehicleId) =>
      _repository.getByVehicle(vehicleId);
  Future<PendingPaymentEntity?> getById(String id) => _repository.getById(id);

  Stream<List<PendingPaymentEntity>> streamAll() => _repository.streamAll();
  Stream<List<PendingPaymentEntity>> streamByAgency(String agencyId) =>
      _repository.streamByAgency(agencyId);
}
