import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/dealer_model.dart';

class DealerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create dealer
  Future<String> createDealer(DealerModel dealer) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.dealersCollection)
          .add(dealer.toJson());
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all dealers (Super Admin)
  Future<List<DealerModel>> getDealers() async {
    try {
      final querySnapshot =
          await _firestore.collection(AppConfig.dealersCollection).get();
      return querySnapshot.docs
          .map((doc) => DealerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get dealers for an agency (Admin)
  Future<List<DealerModel>> getDealersByAgency(String agencyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.dealersCollection)
          .where('agencyId', isEqualTo: agencyId)
          .get();
      return querySnapshot.docs
          .map((doc) => DealerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get dealer by ID
  Future<DealerModel> getDealerById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.dealersCollection)
          .doc(id)
          .get();
      if (!doc.exists) throw Exception('Dealer not found');
      return DealerModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      rethrow;
    }
  }

  // Get dealer by email (case-insensitive) for dealer login/registration
  Future<DealerModel?> getDealerByEmail(String email) async {
    try {
      final querySnapshot =
          await _firestore.collection(AppConfig.dealersCollection).get();
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if ((data['email'] as String? ?? '').toLowerCase() ==
            email.toLowerCase()) {
          return DealerModel.fromJson({...data, 'id': doc.id});
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get dealer profile by linked user ID
  Future<DealerModel?> getDealerByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.dealersCollection)
          .where('userId', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isEmpty) return null;
      return DealerModel.fromJson({
        ...querySnapshot.docs.first.data(),
        'id': querySnapshot.docs.first.id,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update dealer
  Future<void> updateDealer(String id, DealerModel dealer) async {
    try {
      await _firestore
          .collection(AppConfig.dealersCollection)
          .doc(id)
          .update(dealer.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Delete dealer
  Future<void> deleteDealer(String id) async {
    try {
      await _firestore
          .collection(AppConfig.dealersCollection)
          .doc(id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Stream all dealers
  Stream<List<DealerModel>> dealersStream() {
    return _firestore
        .collection(AppConfig.dealersCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DealerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Stream dealers for an agency
  Stream<List<DealerModel>> dealersStreamByAgency(String agencyId) {
    return _firestore
        .collection(AppConfig.dealersCollection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DealerModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Stream the dealer profile linked to a user ID
  Stream<DealerModel?> dealerStreamByUserId(String userId) {
    return _firestore
        .collection(AppConfig.dealersCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return DealerModel.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    });
  }

  // Link an authenticated user to a dealer record
  Future<void> linkDealerToUser(String dealerId, String userId) async {
    try {
      await _firestore
          .collection(AppConfig.dealersCollection)
          .doc(dealerId)
          .update({'userId': userId});
    } catch (e) {
      rethrow;
    }
  }

  // Update commission
  Future<void> updateCommission(String id, double commission) async {
    try {
      await _firestore
          .collection(AppConfig.dealersCollection)
          .doc(id)
          .update({'totalCommission': FieldValue.increment(commission)});
    } catch (e) {
      rethrow;
    }
  }

  // Update sales count
  Future<void> incrementSalesCount(String id) async {
    try {
      await _firestore
          .collection(AppConfig.dealersCollection)
          .doc(id)
          .update({'totalSales': FieldValue.increment(1)});
    } catch (e) {
      rethrow;
    }
  }
}
