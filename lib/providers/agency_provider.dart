import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../core/application/services/agency_application_service.dart';
import '../core/domain/entities/agency.dart';
import '../core/domain/repositories/agency_repository.dart';
import '../infrastructure/repositories/firestore_agency_repository.dart';
import '../models/agency_model.dart';

// Repository provider (DIP: depends on abstraction)
final agencyRepositoryProvider = Provider<IAgencyRepository>((ref) {
  return FirestoreAgencyRepository(FirebaseFirestore.instance);
});

// Application service provider (depends on repository abstraction)
final agencyApplicationServiceProvider =
    Provider<AgencyApplicationService>((ref) {
  return AgencyApplicationService(ref.watch(agencyRepositoryProvider));
});

// Agency model providers (backward compatible with screens)
final agenciesProvider = FutureProvider<List<AgencyModel>>((ref) async {
  final agencyService = ref.watch(agencyApplicationServiceProvider);
  final entities = await agencyService.getAll();
  return entities.map(agencyEntityToModel).toList();
});

final agenciesStreamProvider = StreamProvider<List<AgencyModel>>((ref) {
  final agencyService = ref.watch(agencyApplicationServiceProvider);
  return agencyService.getAll().asStream().map((entities) =>
      entities.map(agencyEntityToModel).toList());
});

final agencyByIdProvider =
    FutureProvider.family<AgencyModel?, String>((ref, id) async {
  final agencyService = ref.watch(agencyApplicationServiceProvider);
  final entity = await agencyService.getById(id);
  return entity != null ? agencyEntityToModel(entity) : null;
});

// Create agency state
final createAgencyProvider =
    StateNotifierProvider<CreateAgencyNotifier, AsyncValue<String>>((ref) {
  final agencyService = ref.watch(agencyApplicationServiceProvider);
  return CreateAgencyNotifier(agencyService);
});

class CreateAgencyNotifier extends StateNotifier<AsyncValue<String>> {
  final AgencyApplicationService _agencyService;

  CreateAgencyNotifier(this._agencyService)
      : super(const AsyncValue.data(''));

  Future<void> createAgency(AgencyModel agency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _agencyService.create(agencyModelToEntity(agency)),
    );
  }
}

// Update agency state
final updateAgencyProvider =
    StateNotifierProvider<UpdateAgencyNotifier, AsyncValue<void>>((ref) {
  final agencyService = ref.watch(agencyApplicationServiceProvider);
  return UpdateAgencyNotifier(agencyService);
});

class UpdateAgencyNotifier extends StateNotifier<AsyncValue<void>> {
  final AgencyApplicationService _agencyService;

  UpdateAgencyNotifier(this._agencyService)
      : super(const AsyncValue.data(null));

  Future<void> updateAgency(String id, AgencyModel agency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _agencyService.update(id, agencyModelToEntity(agency)),
    );
  }
}

// Delete agency state
final deleteAgencyProvider =
    StateNotifierProvider<DeleteAgencyNotifier, AsyncValue<void>>((ref) {
  final agencyService = ref.watch(agencyApplicationServiceProvider);
  return DeleteAgencyNotifier(agencyService);
});

class DeleteAgencyNotifier extends StateNotifier<AsyncValue<void>> {
  final AgencyApplicationService _agencyService;

  DeleteAgencyNotifier(this._agencyService)
      : super(const AsyncValue.data(null));

  Future<void> deleteAgency(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _agencyService.delete(id),
    );
  }
}
