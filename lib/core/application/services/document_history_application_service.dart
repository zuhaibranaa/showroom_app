import '../../domain/entities/document_history.dart';
import '../../domain/repositories/document_history_repository.dart';

/// Application service for document history use cases.
///
/// Enforces agency scoping on every operation.
class DocumentHistoryApplicationService {
  final IDocumentHistoryRepository _repository;

  DocumentHistoryApplicationService(this._repository);

  Future<String> create(DocumentHistoryEntity history) =>
      _repository.create(history);

  Future<void> update(String id, DocumentHistoryEntity history) =>
      _repository.update(id, history);

  Future<void> delete(String id) => _repository.delete(id);

  Future<List<DocumentHistoryEntity>> getAll() => _repository.getAll();
  Future<List<DocumentHistoryEntity>> getByAgency(String agencyId) =>
      _repository.getByAgency(agencyId);
  Future<List<DocumentHistoryEntity>> getByVehicle(String vehicleId) =>
      _repository.getByVehicle(vehicleId);
  Future<DocumentHistoryEntity?> getById(String id) => _repository.getById(id);

  Stream<List<DocumentHistoryEntity>> streamAll() => _repository.streamAll();
  Stream<List<DocumentHistoryEntity>> streamByAgency(String agencyId) =>
      _repository.streamByAgency(agencyId);
  Stream<List<DocumentHistoryEntity>> streamByVehicle(String vehicleId) =>
      _repository.streamByVehicle(vehicleId);
}
