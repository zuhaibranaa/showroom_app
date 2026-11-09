import '../entities/dealer.dart';

/// Read-side contract for dealer data.
abstract class IDealerReadRepository {
  Future<List<DealerEntity>> getAll();
  Future<List<DealerEntity>> getByAgency(String agencyId);
  Future<DealerEntity?> getById(String id);
  Future<DealerEntity?> getByEmail(String email);
  Future<DealerEntity?> getByUserId(String userId);
  Stream<List<DealerEntity>> streamAll();
  Stream<List<DealerEntity>> streamByAgency(String agencyId);
  Stream<DealerEntity?> streamByUserId(String userId);
}

/// Write-side contract for dealer data.
abstract class IDealerWriteRepository {
  Future<String> create(DealerEntity dealer);
  Future<void> update(String id, DealerEntity dealer);
  Future<void> delete(String id);
  Future<void> linkToUser(String dealerId, String userId);
}

/// Full dealer repository contract (read + write).
abstract class IDealerRepository
    implements IDealerReadRepository, IDealerWriteRepository {}
