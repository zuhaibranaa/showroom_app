import '../entities/dealer.dart';

/// Calculates commission for a dealer on a sale.
///
/// Single responsibility: commission calculation. Knows nothing about
/// Firestore, validation, or dealer stats — only the math.
class CommissionCalculator {
  /// Commission earned by [dealer] on a sale of [salePrice].
  /// Returns 0 when the dealer has no commission rate set.
  double calculate(DealerEntity dealer, double salePrice) {
    final percent = dealer.commissionPercent;
    if (percent == null) return 0;
    return salePrice * percent / 100;
  }
}
