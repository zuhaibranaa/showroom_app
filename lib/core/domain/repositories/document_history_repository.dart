import '../entities/document_history.dart';

/// Read-side contract for document history data.
abstract class IDocumentHistoryReadRepository {
  Future<List<DocumentHistoryEntity>> getAll();
  Future<List<DocumentHistoryEntity>> getByAgency(String agencyId);
  Future<List<DocumentHistoryEntity>> getByVehicle(String vehicleId);
  Future<DocumentHistoryEntity?> getById(String id);
  Stream<List<DocumentHistoryEntity>> streamAll();
  Stream<List<DocumentHistoryEntity>> streamByAgency(String agencyId);
  Stream<List<DocumentHistoryEntity>> streamByVehicle(String vehicleId);
}

/// Write-side contract for document history data.
abstract class IDocumentHistoryWriteRepository {
  Future<String> create(DocumentHistoryEntity history);
  Future<void> update(String id, DocumentHistoryEntity history);
  Future<void> delete(String id);
}

/// Full document history repository contract (read + write).
abstract class IDocumentHistoryRepository
    implements IDocumentHistoryReadRepository, IDocumentHistoryWriteRepository {}
