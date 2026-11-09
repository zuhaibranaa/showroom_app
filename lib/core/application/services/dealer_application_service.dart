import '../../domain/entities/dealer.dart';
import '../../domain/repositories/dealer_repository.dart';

/// Application service for dealer use cases.
class DealerApplicationService {
  final IDealerRepository _repository;

  DealerApplicationService(this._repository);

  Future<String> create(DealerEntity dealer) => _repository.create(dealer);
  Future<void> update(String id, DealerEntity dealer) =>
      _repository.update(id, dealer);
  Future<void> delete(String id) => _repository.delete(id);
  Future<void> linkToUser(String dealerId, String userId) =>
      _repository.linkToUser(dealerId, userId);

  Future<List<DealerEntity>> getAll() => _repository.getAll();
  Future<List<DealerEntity>> getByAgency(String agencyId) =>
      _repository.getByAgency(agencyId);
  Future<DealerEntity?> getById(String id) => _repository.getById(id);
  Future<DealerEntity?> getByEmail(String email) =>
      _repository.getByEmail(email);
  Future<DealerEntity?> getByUserId(String userId) =>
      _repository.getByUserId(userId);

  Stream<List<DealerEntity>> streamAll() => _repository.streamAll();
  Stream<List<DealerEntity>> streamByAgency(String agencyId) =>
      _repository.streamByAgency(agencyId);
  Stream<DealerEntity?> streamByUserId(String userId) =>
      _repository.streamByUserId(userId);
}
