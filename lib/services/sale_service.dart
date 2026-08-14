import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/sale_model.dart';

class SaleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create sale with price validation
  Future<String> createSale(SaleModel sale) async {
    try {
      if (sale.salePrice < sale.purchasePrice) {
        throw Exception('Sale price cannot be less than purchase price');
      }
      final doc = await _firestore
          .collection(AppConfig.salesCollection)
          .add(sale.toJson());
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all sales (Super Admin)
  Future<List<SaleModel>> getSales() async {
    try {
      final querySnapshot =
          await _firestore.collection(AppConfig.salesCollection).get();
      return querySnapshot.docs
          .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get sales for an agency (Admin)
  Future<List<SaleModel>> getSalesByAgency(String agencyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.salesCollection)
          .where('agencyId', isEqualTo: agencyId)
          .get();
      return querySnapshot.docs
          .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get sale by ID
  Future<SaleModel> getSaleById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.salesCollection)
          .doc(id)
          .get();
      if (!doc.exists) throw Exception('Sale not found');
      return SaleModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      rethrow;
    }
  }

  // Update sale with validation
  Future<void> updateSale(String id, SaleModel sale) async {
    try {
      if (sale.salePrice < sale.purchasePrice) {
        throw Exception('Sale price cannot be less than purchase price');
      }
      await _firestore
          .collection(AppConfig.salesCollection)
          .doc(id)
          .update(sale.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Delete sale
  Future<void> deleteSale(String id) async {
    try {
      await _firestore
          .collection(AppConfig.salesCollection)
          .doc(id)
          .delete();
    } catch (e) {
      rethrow;
    }
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
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.salesCollection)
          .where('vehicleId', isEqualTo: vehicleId)
          .get();
      return querySnapshot.docs
          .map((doc) => SaleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      rethrow;
    }
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
    try {
      final sales = await getSales();
      var total = 0.0;
      for (final sale in sales) {
        total += sale.profit;
      }
      return total;
    } catch (e) {
      rethrow;
    }
  }

  // Get total profit for an agency (Admin)
  Future<double> getTotalProfitByAgency(String agencyId) async {
    try {
      final sales = await getSalesByAgency(agencyId);
      var total = 0.0;
      for (final sale in sales) {
        total += sale.profit;
      }
      return total;
    } catch (e) {
      rethrow;
    }
  }
}
