import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/repositories/dealer_repository.dart';
import '../../domain/services/commission_calculator.dart';
import '../../domain/services/sale_validator.dart';
import '../../domain/services/dealer_stats_manager.dart';

/// Application service for sale use cases.
///
/// Orchestrates sale repositories and domain services. Does not know
/// about Firestore directly — only repository interfaces (DIP).
class SaleApplicationService {
  final ISaleRepository _saleRepository;
  final IDealerRepository _dealerRepository;
  final SaleValidator _validator;
  final CommissionCalculator _commissionCalculator;
  final DealerStatsManager _statsManager;

  SaleApplicationService({
    required ISaleRepository saleRepository,
    required IDealerRepository dealerRepository,
    SaleValidator? validator,
    CommissionCalculator? commissionCalculator,
    DealerStatsManager? statsManager,
  })  : _saleRepository = saleRepository,
        _dealerRepository = dealerRepository,
        _validator = validator ?? SaleValidator(),
        _commissionCalculator = commissionCalculator ?? CommissionCalculator(),
        _statsManager = statsManager ?? DealerStatsManager();

  /// Create a sale with validation and dealer stat bookkeeping.
  Future<String> createSale(SaleEntity sale) async {
    _validator.validate(sale);

    final saleId = await _saleRepository.create(sale);

    final dealer = sale.dealerId != null
        ? await _dealerRepository.getById(sale.dealerId!)
        : null;
    if (dealer != null) {
      final commission =
          _commissionCalculator.calculate(dealer, sale.salePrice);
      final updatedDealer = _statsManager.incrementSales(dealer, commission);
      await _dealerRepository.update(sale.dealerId!, updatedDealer);
    }

    return saleId;
  }

  /// Update a sale with validation and dealer stat adjustment.
  Future<void> updateSale(String id, SaleEntity sale) async {
    _validator.validate(sale);

    final oldSale = await _saleRepository.getById(id);
    if (oldSale == null) {
      throw ArgumentError('Sale not found');
    }

    await _saleRepository.update(id, sale);

    // Revert old dealer stats
    if (oldSale.dealerId != null) {
      final oldDealer = await _dealerRepository.getById(oldSale.dealerId!);
      if (oldDealer != null) {
        final oldCommission =
            _commissionCalculator.calculate(oldDealer, oldSale.salePrice);
        final reverted = _statsManager.decrementSales(oldDealer, oldCommission);
        await _dealerRepository.update(oldSale.dealerId!, reverted);
      }
    }

    // Apply new dealer stats
    if (sale.dealerId != null) {
      final newDealer = await _dealerRepository.getById(sale.dealerId!);
      if (newDealer != null) {
        final newCommission =
            _commissionCalculator.calculate(newDealer, sale.salePrice);
        final updated = _statsManager.incrementSales(newDealer, newCommission);
        await _dealerRepository.update(sale.dealerId!, updated);
      }
    }
  }

  /// Delete a sale and revert dealer stats.
  Future<void> deleteSale(String id) async {
    final sale = await _saleRepository.getById(id);
    if (sale == null) return;

    await _saleRepository.delete(id);

    if (sale.dealerId != null) {
      final dealer = await _dealerRepository.getById(sale.dealerId!);
      if (dealer != null) {
        final commission =
            _commissionCalculator.calculate(dealer, sale.salePrice);
        final reverted = _statsManager.decrementSales(dealer, commission);
        await _dealerRepository.update(sale.dealerId!, reverted);
      }
    }
  }

  Future<List<SaleEntity>> getAll() => _saleRepository.getAll();
  Future<List<SaleEntity>> getByAgency(String agencyId) =>
      _saleRepository.getByAgency(agencyId);
  Future<List<SaleEntity>> getByVehicle(String vehicleId) =>
      _saleRepository.getByVehicle(vehicleId);
  Future<List<SaleEntity>> getByDealer(String dealerId) =>
      _saleRepository.getByDealer(dealerId);
  Future<SaleEntity?> getById(String id) => _saleRepository.getById(id);

  Stream<List<SaleEntity>> streamAll() => _saleRepository.streamAll();
  Stream<List<SaleEntity>> streamByAgency(String agencyId) =>
      _saleRepository.streamByAgency(agencyId);
  Stream<List<SaleEntity>> streamByDealer(String dealerId) =>
      _saleRepository.streamByDealer(dealerId);
}
