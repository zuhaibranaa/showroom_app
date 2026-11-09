import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/operations_models.dart';
import '../services/operations_service.dart';

final operationsServiceProvider=Provider((ref)=>OperationsService());
final paymentsProvider=StreamProvider<List<PaymentModel>>((ref)=>ref.watch(operationsServiceProvider).payments());
final paymentsForSaleProvider=StreamProvider.family<List<PaymentModel>,String>((ref,id)=>ref.watch(operationsServiceProvider).paymentsForSale(id));
final documentHistoryProvider=StreamProvider.family<List<DocumentHistoryModel>,String>((ref,id)=>ref.watch(operationsServiceProvider).documentHistory(id));
final vehicleServicesProvider=StreamProvider<List<VehicleServiceRecord>>((ref)=>ref.watch(operationsServiceProvider).vehicleServices());
final appOptionsProvider=StreamProvider<List<AppOptionModel>>((ref)=>ref.watch(operationsServiceProvider).options());
final retailPricesProvider=StreamProvider<List<RetailPriceModel>>((ref)=>ref.watch(operationsServiceProvider).retailPrices());
