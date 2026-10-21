import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/sale_model.dart';

class SaleService {
  final FirebaseFirestore _firestore;

  /// Allows injecting a [FirebaseFirestore] instance (e.g. for unit testing).
  /// Defaults to `FirebaseFirestore.instance`.
  SaleService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Commission earned by [dealerId] on a sale of [salePrice].
  /// Returns 0 when the dealer record is missing or has no rate set.
  Future<double> _commissionFor(String dealerId, double salePrice) async {
    final dealerDoc = await _firestore
        .collection(AppConfig.dealersCollection)
        .doc(dealerId)
        .get();
    if (!dealerDoc.exists) return 0;
    final percent =
        (dealerDoc.data()!['commissionPercent'] as num?)?.toDouble() ?? 0;
    return salePrice * percent / 100;
  }

  /// Create sale with price validation and dealer stat bookkeeping.
  Future<String> createSale(SaleModel sale) async {
    if (sale.salePrice < sale.purchasePrice) {
      throw Exception('Sale price cannot be less than purchase price');
    }

    final batch = _firestore.batch();
    final saleRef = _firestore.collection(AppConfig.salesCollection).doc();
    batch.set(saleRef, sale.toJson());

    final dealerRef =
        _firestore.collection(AppConfig.dealersCollection).doc(sale.dealerId);
    final dealerDoc = await dealerRef.get();
    if (dealerDoc.exists) {
      final percent =
          (dealerDoc.data()!['commissionPercent'] as num?)?.toDouble() ?? 0;
      final commission = sale.salePrice * percent / 100;
      batch.update(dealerRef, {
        'totalSales': FieldValue.increment(1),
        'totalCommission': FieldValue.increment(commission),
      });
    }

    await batch.commit();
    return saleRef.id;
  }

  // Get all sales (Super Admin)
  Future<List<SaleModel>> getSales() async {
    final querySnapshot =
        await _firestore.collection(AppConfig.salesCollection).get();
    return querySnapshot.docs
        .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Get sales for an agency (Admin)
  Future<List<SaleModel>> getSalesByAgency(String agencyId) async {
    final querySnapshot = await _firestore
        .collection(AppConfig.salesCollection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return querySnapshot.docs
        .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Get sale by ID
  Future<SaleModel> getSaleById(String id) async {
    final doc =
        await _firestore.collection(AppConfig.salesCollection).doc(id).get();
    if (!doc.exists) throw Exception('Sale not found');
    return SaleModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Update sale with validation, adjusting dealer stats when the
  /// dealer or the sale price changes.
  Future<void> updateSale(String id, SaleModel sale) async {
    if (sale.salePrice < sale.purchasePrice) {
      throw Exception('Sale price cannot be less than purchase price');
    }

    final oldDoc =
        await _firestore.collection(AppConfig.salesCollection).doc(id).get();
    if (!oldDoc.exists) throw Exception('Sale not found');
    final oldSale = SaleModel.fromJson({...oldDoc.data()!, 'id': oldDoc.id});

    final oldCommission =
        await _commissionFor(oldSale.dealerId, oldSale.salePrice);
    final newCommission =
        await _commissionFor(sale.dealerId, sale.salePrice);

    final batch = _firestore.batch();
    batch.update(
        _firestore.collection(AppConfig.salesCollection).doc(id),
        sale.toJson());

    if (oldSale.dealerId != sale.dealerId) {
      // Dealer changed: revert old dealer stats, apply new dealer stats.
      final oldDealerRef =
          _firestore.collection(AppConfig.dealersCollection).doc(oldSale.dealerId);
      final newDealerRef =
          _firestore.collection(AppConfig.dealersCollection).doc(sale.dealerId);
      final oldDealerDoc = await oldDealerRef.get();
      final newDealerDoc = await newDealerRef.get();
      if (oldDealerDoc.exists) {
        batch.update(oldDealerRef, {
          'totalSales': FieldValue.increment(-1),
          'totalCommission': FieldValue.increment(-oldCommission),
        });
      }
      if (newDealerDoc.exists) {
        batch.update(newDealerRef, {
          'totalSales': FieldValue.increment(1),
          'totalCommission': FieldValue.increment(newCommission),
        });
      }
    } else if ((newCommission - oldCommission).abs() > 0.0001) {
      // Same dealer: adjust commission by the difference.
      final dealerRef =
          _firestore.collection(AppConfig.dealersCollection).doc(sale.dealerId);
      final dealerDoc = await dealerRef.get();
      if (dealerDoc.exists) {
        batch.update(dealerRef, {
          'totalCommission': FieldValue.increment(newCommission - oldCommission),
        });
      }
    }

    await batch.commit();
  }

  /// Delete sale and revert the dealer stat bookkeeping.
  Future<void> deleteSale(String id) async {
    final doc =
        await _firestore.collection(AppConfig.salesCollection).doc(id).get();
    if (!doc.exists) return;
    final sale = SaleModel.fromJson({...doc.data()!, 'id': doc.id});

    final commission = await _commissionFor(sale.dealerId, sale.salePrice);

    final batch = _firestore.batch();
    batch.delete(_firestore.collection(AppConfig.salesCollection).doc(id));
    final dealerRef =
        _firestore.collection(AppConfig.dealersCollection).doc(sale.dealerId);
    final dealerDoc = await dealerRef.get();
    if (dealerDoc.exists) {
      batch.update(dealerRef, {
        'totalSales': FieldValue.increment(-1),
        'totalCommission': FieldValue.increment(-commission),
      });
    }
    await batch.commit();
  }

  // Stream all sales (Super Admin)
  Stream<List<SaleModel>> salesStream() {
    return _firestore
        .collection(AppConfig.salesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Stream sales for an agency (Admin)
  Stream<List<SaleModel>> salesStreamByAgency(String agencyId) {
    return _firestore
        .collection(AppConfig.salesCollection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get sales by vehicle ID
  Future<List<SaleModel>> getSalesByVehicle(String vehicleId) async {
    final querySnapshot = await _firestore
        .collection(AppConfig.salesCollection)
        .where('vehicleId', isEqualTo: vehicleId)
        .get();
    return querySnapshot.docs
        .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Stream sales by dealer ID
  Stream<List<SaleModel>> salesStreamByDealer(String dealerId) {
    return _firestore
        .collection(AppConfig.salesCollection)
        .where('dealerId', isEqualTo: dealerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get total profit (Super Admin)
  Future<double> getTotalProfit() async {
    final sales = await getSales();
    var total = 0.0;
    for (final sale in sales) {
      total += sale.profit;
    }
    return total;
  }

  // Get total profit for an agency (Admin)
  Future<double> getTotalProfitByAgency(String agencyId) async {
    final sales = await getSalesByAgency(agencyId);
    var total = 0.0;
    for (final sale in sales) {
      total += sale.profit;
    }
    return total;
  }
}
