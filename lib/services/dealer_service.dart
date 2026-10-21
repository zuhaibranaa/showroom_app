import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/dealer_model.dart';

class DealerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create dealer
  Future<String> createDealer(DealerModel dealer) async {
    final data = dealer.toJson();
    // Normalized email for indexed, case-insensitive lookups.
    data['emailLower'] = dealer.email.trim().toLowerCase();
    final doc =
        await _firestore.collection(AppConfig.dealersCollection).add(data);
    return doc.id;
  }

  // Get all dealers (Super Admin)
  Future<List<DealerModel>> getDealers() async {
    final querySnapshot =
        await _firestore.collection(AppConfig.dealersCollection).get();
    return querySnapshot.docs
        .map((doc) => DealerModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Get dealers for an agency (Admin)
  Future<List<DealerModel>> getDealersByAgency(String agencyId) async {
    final querySnapshot = await _firestore
        .collection(AppConfig.dealersCollection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return querySnapshot.docs
        .map((doc) => DealerModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Get dealer by ID
  Future<DealerModel> getDealerById(String id) async {
    final doc = await _firestore
        .collection(AppConfig.dealersCollection)
        .doc(id)
        .get();
    if (!doc.exists) throw Exception('Dealer not found');
    return DealerModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  // Get dealer by email (case-insensitive) for dealer login/registration.
  // Uses an indexed query on the normalized `emailLower` field when present,
  // falling back to an in-memory scan only for legacy documents that predate
  // the normalized field.
  Future<DealerModel?> getDealerByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final snapshot = await _firestore
        .collection(AppConfig.dealersCollection)
        .where('emailLower', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return DealerModel.fromJson({...doc.data(), 'id': doc.id});
    }

    // Legacy fallback: documents written before `emailLower` existed.
    final all = await _firestore.collection(AppConfig.dealersCollection).get();
    for (final doc in all.docs) {
      final data = doc.data();
      if ((data['email'] as String? ?? '').toLowerCase() == normalized) {
        return DealerModel.fromJson({...data, 'id': doc.id});
      }
    }
    return null;
  }

  // Get dealer profile by linked user ID
  Future<DealerModel?> getDealerByUserId(String userId) async {
    final querySnapshot = await _firestore
        .collection(AppConfig.dealersCollection)
        .where('userId', isEqualTo: userId)
        .get();
    if (querySnapshot.docs.isEmpty) return null;
    return DealerModel.fromJson({
      ...querySnapshot.docs.first.data(),
      'id': querySnapshot.docs.first.id,
    });
  }

  // Update dealer
  Future<void> updateDealer(String id, DealerModel dealer) async {
    final data = dealer.toJson();
    data['emailLower'] = dealer.email.trim().toLowerCase();
    await _firestore
        .collection(AppConfig.dealersCollection)
        .doc(id)
        .update(data);
  }

  // Delete dealer
  Future<void> deleteDealer(String id) async {
    await _firestore
        .collection(AppConfig.dealersCollection)
        .doc(id)
        .delete();
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
    await _firestore
        .collection(AppConfig.dealersCollection)
        .doc(dealerId)
        .update({'userId': userId});
  }
}
