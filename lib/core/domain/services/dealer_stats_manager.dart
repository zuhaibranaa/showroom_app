import '../entities/dealer.dart';

/// Manages dealer statistics (total sales, total commission).
///
/// Single responsibility: dealer stat bookkeeping. Knows how to increment
/// or decrement dealer stats but does not know about Firestore directly.
class DealerStatsManager {
  /// Increments the dealer's total sales by 1 and total commission by [commission].
  DealerEntity incrementSales(DealerEntity dealer, double commission) {
    return dealer.copyWith(
      totalSales: dealer.totalSales + 1,
      totalCommission: dealer.totalCommission + commission,
    );
  }

  /// Decrements the dealer's total sales by 1 and total commission by [commission].
  DealerEntity decrementSales(DealerEntity dealer, double commission) {
    return dealer.copyWith(
      totalSales: (dealer.totalSales - 1).clamp(0, double.infinity).toInt(),
      totalCommission: (dealer.totalCommission - commission).clamp(0.0, double.infinity),
    );
  }

  /// Adjusts the dealer's total commission by [delta] (can be negative).
  DealerEntity adjustCommission(DealerEntity dealer, double delta) {
    return dealer.copyWith(
      totalCommission: (dealer.totalCommission + delta).clamp(0.0, double.infinity),
    );
  }
}
