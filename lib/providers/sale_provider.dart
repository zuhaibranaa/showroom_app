import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../core/application/services/sale_application_service.dart';
import '../core/domain/entities/sale.dart';
import '../core/domain/repositories/sale_repository.dart';
import '../core/domain/repositories/dealer_repository.dart';
import '../infrastructure/repositories/firestore_sale_repository.dart';
import '../infrastructure/repositories/firestore_dealer_repository.dart';
import '../models/sale_model.dart';

// Repository providers (DIP: depend on abstractions)
final saleRepositoryProvider = Provider<ISaleRepository>((ref) {
  return FirestoreSaleRepository(FirebaseFirestore.instance);
});

final dealerReadRepositoryProvider = Provider<IDealerRepository>((ref) {
  return FirestoreDealerRepository(FirebaseFirestore.instance);
});

// Application service providers (depend on repository abstractions)
final saleApplicationServiceProvider =
    Provider<SaleApplicationService>((ref) {
  return SaleApplicationService(
    saleRepository: ref.watch(saleRepositoryProvider),
    dealerRepository: ref.watch(dealerReadRepositoryProvider),
  );
});

// Sale model providers (backward compatible with screens)
final salesProvider = FutureProvider<List<SaleModel>>((ref) async {
  final saleService = ref.watch(saleApplicationServiceProvider);
  final entities = await saleService.getAll();
  return entities.map(saleEntityToModel).toList();
});

final salesStreamProvider = StreamProvider<List<SaleModel>>((ref) {
  final saleService = ref.watch(saleApplicationServiceProvider);
  return saleService.streamAll().map((entities) =>
      entities.map(saleEntityToModel).toList());
});

final salesByAgencyProvider =
    FutureProvider.family<List<SaleModel>, String>((ref, agencyId) async {
  final saleService = ref.watch(saleApplicationServiceProvider);
  final entities = await saleService.getByAgency(agencyId);
  return entities.map(saleEntityToModel).toList();
});

final salesStreamByAgencyProvider =
    StreamProvider.family<List<SaleModel>, String>((ref, agencyId) {
  final saleService = ref.watch(saleApplicationServiceProvider);
  return saleService.streamByAgency(agencyId).map((entities) =>
      entities.map(saleEntityToModel).toList());
});

final totalProfitByAgencyProvider =
    FutureProvider.family<double, String>((ref, agencyId) async {
  final saleService = ref.watch(saleApplicationServiceProvider);
  final sales = await saleService.getByAgency(agencyId);
  return sales.fold<double>(0, (sum, s) => sum + s.profit);
});

final saleByIdProvider =
    FutureProvider.family<SaleModel?, String>((ref, id) async {
  final saleService = ref.watch(saleApplicationServiceProvider);
  final entity = await saleService.getById(id);
  return entity != null ? saleEntityToModel(entity) : null;
});

final salesByVehicleProvider =
    FutureProvider.family<List<SaleModel>, String>((ref, vehicleId) async {
  final saleService = ref.watch(saleApplicationServiceProvider);
  final entities = await saleService.getByVehicle(vehicleId);
  return entities.map(saleEntityToModel).toList();
});

final salesForDealerProvider =
    StreamProvider.family<List<SaleModel>, String>((ref, dealerId) {
  final saleService = ref.watch(saleApplicationServiceProvider);
  return saleService.streamByDealer(dealerId).map((entities) =>
      entities.map(saleEntityToModel).toList());
});

final totalProfitProvider = FutureProvider<double>((ref) async {
  final saleService = ref.watch(saleApplicationServiceProvider);
  final sales = await saleService.getAll();
  return sales.fold<double>(0, (sum, s) => sum + s.profit);
});

// Create sale state
final createSaleProvider =
    StateNotifierProvider<CreateSaleNotifier, AsyncValue<String>>((ref) {
  final saleService = ref.watch(saleApplicationServiceProvider);
  return CreateSaleNotifier(saleService);
});

class CreateSaleNotifier extends StateNotifier<AsyncValue<String>> {
  final SaleApplicationService _saleService;

  CreateSaleNotifier(this._saleService) : super(const AsyncValue.data(''));

  Future<void> createSale(SaleModel sale) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _saleService.createSale(saleModelToEntity(sale)),
    );
  }
}

// Update sale state
final updateSaleProvider =
    StateNotifierProvider<UpdateSaleNotifier, AsyncValue<void>>((ref) {
  final saleService = ref.watch(saleApplicationServiceProvider);
  return UpdateSaleNotifier(saleService);
});

class UpdateSaleNotifier extends StateNotifier<AsyncValue<void>> {
  final SaleApplicationService _saleService;

  UpdateSaleNotifier(this._saleService) : super(const AsyncValue.data(null));

  Future<void> updateSale(String id, SaleModel sale) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _saleService.updateSale(id, saleModelToEntity(sale)),
    );
  }
}

// Delete sale state
final deleteSaleProvider =
    StateNotifierProvider<DeleteSaleNotifier, AsyncValue<void>>((ref) {
  final saleService = ref.watch(saleApplicationServiceProvider);
  return DeleteSaleNotifier(saleService);
});

class DeleteSaleNotifier extends StateNotifier<AsyncValue<void>> {
  final SaleApplicationService _saleService;

  DeleteSaleNotifier(this._saleService) : super(const AsyncValue.data(null));

  Future<void> deleteSale(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _saleService.deleteSale(id),
    );
  }
}
