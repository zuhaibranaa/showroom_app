import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user profile
  Future<void> createUserProfile(String uid, UserModel user) async {
    try {
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(uid)
          .set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) throw Exception('User not found');
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, UserModel user) async {
    try {
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(uid)
          .update(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Stream user profile
  Stream<UserModel?> userProfileStream(String uid) {
    return _firestore
        .collection(AppConfig.usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromJson(snapshot.data()!);
    });
  }

  // Registered admins
  Future<List<UserModel>> getAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.usersCollection)
          .where('role', isEqualTo: 'admin')
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Admin invite (pending admin who has not registered yet).
  // Doc id is the normalized email.
  Future<void> createAdminInvite({
    required String name,
    required String email,
    required List<String> agencyIds,
  }) async {
    try {
      final now = DateTime.now();
      await _firestore
          .collection(AppConfig.adminInvitesCollection)
          .doc(email.trim().toLowerCase())
          .set({
        'name': name.trim(),
        'email': email.trim(),
        'agencyIds': agencyIds,
        'createdAt': now,
        'updatedAt': now,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getAdminInvite(String email) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.adminInvitesCollection)
          .doc(email.trim().toLowerCase())
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAdminInvites() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.adminInvitesCollection)
          .get();
      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAdminInvite({
    required String email,
    String? name,
    required List<String> agencyIds,
  }) async {
    try {
      await _firestore
          .collection(AppConfig.adminInvitesCollection)
          .doc(email.trim().toLowerCase())
          .update({
        if (name != null) 'name': name.trim(),
        'agencyIds': agencyIds,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAdminInvite(String email) async {
    try {
      await _firestore
          .collection(AppConfig.adminInvitesCollection)
          .doc(email.trim().toLowerCase())
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}
