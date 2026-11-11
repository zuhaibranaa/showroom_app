import '../entities/pending_payment.dart';

/// Read-side contract for pending payment data.
abstract class IPendingPaymentReadRepository {
  Future<List<PendingPaymentEntity>> getAll();
  Future<List<PendingPaymentEntity>> getByAgency(String agencyId);
  Future<List<PendingPaymentEntity>> getBySale(String saleId);
  Future<List<PendingPaymentEntity>> getByVehicle(String vehicleId);
  Future<PendingPaymentEntity?> getById(String id);
  Stream<List<PendingPaymentEntity>> streamAll();
  Stream<List<PendingPaymentEntity>> streamByAgency(String agencyId);
}

/// Write-side contract for pending payment data.
abstract class IPendingPaymentWriteRepository {
  Future<String> create(PendingPaymentEntity payment);
  Future<void> update(String id, PendingPaymentEntity payment);
  Future<void> delete(String id);
}

/// Full pending payment repository contract (read + write).
abstract class IPendingPaymentRepository
    implements IPendingPaymentReadRepository, IPendingPaymentWriteRepository {}
