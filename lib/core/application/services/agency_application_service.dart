import '../../domain/entities/agency.dart';
import '../../domain/repositories/agency_repository.dart';

/// Application service for agency use cases.
class AgencyApplicationService {
  final IAgencyRepository _repository;

  AgencyApplicationService(this._repository);

  Future<String> create(AgencyEntity agency) => _repository.create(agency);
  Future<void> update(String id, AgencyEntity agency) =>
      _repository.update(id, agency);
  Future<void> delete(String id) => _repository.delete(id);

  Future<List<AgencyEntity>> getAll() => _repository.getAll();
  Future<List<AgencyEntity>> getByIds(List<String> ids) =>
      _repository.getByIds(ids);
  Future<AgencyEntity?> getById(String id) => _repository.getById(id);
}
