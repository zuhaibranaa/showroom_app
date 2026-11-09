import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../core/application/services/dealer_application_service.dart';
import '../core/domain/entities/dealer.dart';
import '../core/domain/repositories/dealer_repository.dart';
import '../infrastructure/repositories/firestore_dealer_repository.dart';
import '../models/dealer_model.dart';

// Repository provider (DIP: depends on abstraction)
final dealerRepositoryProvider = Provider<IDealerRepository>((ref) {
  return FirestoreDealerRepository(FirebaseFirestore.instance);
});

// Application service provider (depends on repository abstraction)
final dealerApplicationServiceProvider =
    Provider<DealerApplicationService>((ref) {
  return DealerApplicationService(ref.watch(dealerRepositoryProvider));
});

// Dealer model providers (backward compatible with screens)
final dealersProvider = FutureProvider<List<DealerModel>>((ref) async {
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  final entities = await dealerService.getAll();
  return entities.map(dealerEntityToModel).toList();
});

final dealersStreamProvider = StreamProvider<List<DealerModel>>((ref) {
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  return dealerService.streamAll().map((entities) =>
      entities.map(dealerEntityToModel).toList());
});

final dealersByAgencyProvider =
    FutureProvider.family<List<DealerModel>, String>((ref, agencyId) async {
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  final entities = await dealerService.getByAgency(agencyId);
  return entities.map(dealerEntityToModel).toList();
});

final dealersStreamByAgencyProvider =
    StreamProvider.family<List<DealerModel>, String>((ref, agencyId) {
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  return dealerService.streamByAgency(agencyId).map((entities) =>
      entities.map(dealerEntityToModel).toList());
});

final dealerByIdProvider =
    FutureProvider.family<DealerModel?, String>((ref, id) async {
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  final entity = await dealerService.getById(id);
  return entity != null ? dealerEntityToModel(entity) : null;
});

/// Dealer lookup that resolves to `null` for an empty/missing id instead of
/// throwing, for screens that reference an optional related record.
final dealerByIdOrNullProvider =
    FutureProvider.family<DealerModel?, String>((ref, id) async {
  if (id.isEmpty) return null;
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  final entity = await dealerService.getById(id);
  return entity != null ? dealerEntityToModel(entity) : null;
});

// Create dealer state
final createDealerProvider =
    StateNotifierProvider<CreateDealerNotifier, AsyncValue<String>>((ref) {
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  return CreateDealerNotifier(dealerService);
});

class CreateDealerNotifier extends StateNotifier<AsyncValue<String>> {
  final DealerApplicationService _dealerService;

  CreateDealerNotifier(this._dealerService)
      : super(const AsyncValue.data(''));

  Future<void> createDealer(DealerModel dealer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _dealerService.create(dealerModelToEntity(dealer)),
    );
  }
}

// Update dealer state
final updateDealerProvider =
    StateNotifierProvider<UpdateDealerNotifier, AsyncValue<void>>((ref) {
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  return UpdateDealerNotifier(dealerService);
});

class UpdateDealerNotifier extends StateNotifier<AsyncValue<void>> {
  final DealerApplicationService _dealerService;

  UpdateDealerNotifier(this._dealerService)
      : super(const AsyncValue.data(null));

  Future<void> updateDealer(String id, DealerModel dealer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _dealerService.update(id, dealerModelToEntity(dealer)),
    );
  }
}

// Delete dealer state
final deleteDealerProvider =
    StateNotifierProvider<DeleteDealerNotifier, AsyncValue<void>>((ref) {
  final dealerService = ref.watch(dealerApplicationServiceProvider);
  return DeleteDealerNotifier(dealerService);
});

class DeleteDealerNotifier extends StateNotifier<AsyncValue<void>> {
  final DealerApplicationService _dealerService;

  DeleteDealerNotifier(this._dealerService)
      : super(const AsyncValue.data(null));

  Future<void> deleteDealer(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _dealerService.delete(id),
    );
  }
}
