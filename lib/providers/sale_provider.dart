import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sale_service.dart';
import '../models/sale_model.dart';

// Sale Service Provider
final saleServiceProvider = Provider((ref) => SaleService());

// Get all sales
final salesProvider = FutureProvider<List<SaleModel>>((ref) async {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.getSales();
});

// Stream sales
final salesStreamProvider = StreamProvider<List<SaleModel>>((ref) {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.salesStream();
});

// Get sales for an agency (Admin)
final salesByAgencyProvider =
    FutureProvider.family<List<SaleModel>, String>((ref, agencyId) async {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.getSalesByAgency(agencyId);
});

// Stream sales for an agency (Admin)
final salesStreamByAgencyProvider =
    StreamProvider.family<List<SaleModel>, String>((ref, agencyId) {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.salesStreamByAgency(agencyId);
});

// Total profit for an agency (Admin)
final totalProfitByAgencyProvider =
    FutureProvider.family<double, String>((ref, agencyId) async {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.getTotalProfitByAgency(agencyId);
});

// Get sale by ID
final saleByIdProvider = FutureProvider.family<SaleModel, String>((ref, id) async {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.getSaleById(id);
});

// Get sales by vehicle
final salesByVehicleProvider =
    FutureProvider.family<List<SaleModel>, String>((ref, vehicleId) async {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.getSalesByVehicle(vehicleId);
});

// Stream sales for a specific dealer
final salesForDealerProvider =
    StreamProvider.family<List<SaleModel>, String>((ref, dealerId) {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.salesStreamByDealer(dealerId);
});

// Total profit provider
final totalProfitProvider = FutureProvider<double>((ref) async {
  final saleService = ref.watch(saleServiceProvider);
  return saleService.getTotalProfit();
});

// Create sale state
final createSaleProvider =
    StateNotifierProvider<CreateSaleNotifier, AsyncValue<String>>((ref) {
  final saleService = ref.watch(saleServiceProvider);
  return CreateSaleNotifier(saleService);
});

class CreateSaleNotifier extends StateNotifier<AsyncValue<String>> {
  final SaleService _saleService;

  CreateSaleNotifier(this._saleService) : super(const AsyncValue.data(''));

  Future<void> createSale(SaleModel sale) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _saleService.createSale(sale),
    );
  }
}

// Update sale state
final updateSaleProvider =
    StateNotifierProvider<UpdateSaleNotifier, AsyncValue<void>>((ref) {
  final saleService = ref.watch(saleServiceProvider);
  return UpdateSaleNotifier(saleService);
});

class UpdateSaleNotifier extends StateNotifier<AsyncValue<void>> {
  final SaleService _saleService;

  UpdateSaleNotifier(this._saleService) : super(const AsyncValue.data(null));

  Future<void> updateSale(String id, SaleModel sale) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _saleService.updateSale(id, sale),
    );
  }
}

// Delete sale state
final deleteSaleProvider =
    StateNotifierProvider<DeleteSaleNotifier, AsyncValue<void>>((ref) {
  final saleService = ref.watch(saleServiceProvider);
  return DeleteSaleNotifier(saleService);
});

class DeleteSaleNotifier extends StateNotifier<AsyncValue<void>> {
  final SaleService _saleService;

  DeleteSaleNotifier(this._saleService) : super(const AsyncValue.data(null));

  Future<void> deleteSale(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _saleService.deleteSale(id),
    );
  }
}
