import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../core/application/services/retail_price_application_service.dart';
import '../core/domain/entities/retail_price.dart';
import '../core/domain/repositories/retail_price_repository.dart';
import '../infrastructure/repositories/firestore_retail_price_repository.dart';
import '../models/operations_models.dart';

// Repository provider (DIP: depends on abstraction)
final retailPriceRepositoryProvider =
    Provider<IRetailPriceRepository>((ref) {
  return FirestoreRetailPriceRepository(FirebaseFirestore.instance);
});

// Application service provider (depends on repository abstraction)
final retailPriceApplicationServiceProvider =
    Provider<RetailPriceApplicationService>((ref) {
  return RetailPriceApplicationService(ref.watch(retailPriceRepositoryProvider));
});

// Retail price model providers (agency-scoped)
final retailPricesByAgencyProvider =
    FutureProvider.family<List<RetailPriceModel>, String>((ref, agencyId) async {
  final service = ref.watch(retailPriceApplicationServiceProvider);
  final entities = await service.getByAgency(agencyId);
  return entities.map(retailPriceEntityToModel).toList();
});

final retailPricesStreamByAgencyProvider =
    StreamProvider.family<List<RetailPriceModel>, String>((ref, agencyId) {
  final service = ref.watch(retailPriceApplicationServiceProvider);
  return service.streamByAgency(agencyId).map((entities) =>
      entities.map(retailPriceEntityToModel).toList());
});

final retailPriceByIdProvider =
    FutureProvider.family<RetailPriceModel?, String>((ref, id) async {
  final service = ref.watch(retailPriceApplicationServiceProvider);
  final entity = await service.getById(id);
  return entity != null ? retailPriceEntityToModel(entity) : null;
});

final retailPriceByMakeModelProvider =
    FutureProvider.family<RetailPriceModel?, Map<String, String>>(
  (ref, params) async {
    final service = ref.watch(retailPriceApplicationServiceProvider);
    final agencyId = params['agencyId']!;
    final make = params['make']!;
    final model = params['model']!;
    final entity = await service.getByMakeModel(agencyId, make, model);
    return entity != null ? retailPriceEntityToModel(entity) : null;
  },
);

// Create retail price state
final createRetailPriceProvider =
    StateNotifierProvider<CreateRetailPriceNotifier, AsyncValue<String>>(
  (ref) {
    final service = ref.watch(retailPriceApplicationServiceProvider);
    return CreateRetailPriceNotifier(service);
  },
);

class CreateRetailPriceNotifier extends StateNotifier<AsyncValue<String>> {
  final RetailPriceApplicationService _service;

  CreateRetailPriceNotifier(this._service)
      : super(const AsyncValue.data(''));

  Future<void> createRetailPrice(RetailPriceModel price) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.create(retailPriceModelToEntity(price)),
    );
  }
}

// Update retail price state
final updateRetailPriceProvider =
    StateNotifierProvider<UpdateRetailPriceNotifier, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(retailPriceApplicationServiceProvider);
    return UpdateRetailPriceNotifier(service);
  },
);

class UpdateRetailPriceNotifier extends StateNotifier<AsyncValue<void>> {
  final RetailPriceApplicationService _service;

  UpdateRetailPriceNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> updateRetailPrice(String id, RetailPriceModel price) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.update(id, retailPriceModelToEntity(price)),
    );
  }
}

// Delete retail price state
final deleteRetailPriceProvider =
    StateNotifierProvider<DeleteRetailPriceNotifier, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(retailPriceApplicationServiceProvider);
    return DeleteRetailPriceNotifier(service);
  },
);

class DeleteRetailPriceNotifier extends StateNotifier<AsyncValue<void>> {
  final RetailPriceApplicationService _service;

  DeleteRetailPriceNotifier(this._service)
      : super(const AsyncValue.data(null));

  Future<void> deleteRetailPrice(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.delete(id));
  }
}
