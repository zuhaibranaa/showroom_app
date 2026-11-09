import '../entities/agency.dart';

/// Read-side contract for agency data.
abstract class IAgencyReadRepository {
  Future<List<AgencyEntity>> getAll();
  Future<List<AgencyEntity>> getByIds(List<String> ids);
  Future<AgencyEntity?> getById(String id);
}

/// Write-side contract for agency data.
abstract class IAgencyWriteRepository {
  Future<String> create(AgencyEntity agency);
  Future<void> update(String id, AgencyEntity agency);
  Future<void> delete(String id);
}

/// Full agency repository contract (read + write).
abstract class IAgencyRepository
    implements IAgencyReadRepository, IAgencyWriteRepository {}
