import '../entities/sale.dart';

/// Validates sale business rules.
///
/// Single responsibility: sale validation. Does not touch persistence.
class SaleValidator {
  /// Validates that [sale] has a valid price (sale price >= purchase price).
  /// Throws [ArgumentError] if invalid.
  void validatePrice(SaleEntity sale) {
    if (sale.salePrice < sale.purchasePrice) {
      throw ArgumentError('Sale price cannot be less than purchase price');
    }
  }

  /// Validates that [sale] has required fields.
  /// Throws [ArgumentError] if invalid.
  void validateRequired(SaleEntity sale) {
    if (sale.vehicleId.isEmpty) {
      throw ArgumentError('Vehicle ID is required');
    }
    if (sale.buyerName.isEmpty) {
      throw ArgumentError('Buyer name is required');
    }
    if (sale.agencyId.isEmpty) {
      throw ArgumentError('Agency ID is required');
    }
  }

  /// Runs all validations on [sale].
  void validate(SaleEntity sale) {
    validateRequired(sale);
    validatePrice(sale);
  }
}
