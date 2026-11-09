import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/user.dart';
import '../../../core/domain/repositories/user_repository.dart';

/// Firestore implementation of [IUserRepository].
class FirestoreUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository(this._firestore);

  static const String _collection = AppConfig.usersCollection;

  UserEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserEntity(
      id: doc.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      fullName: data['fullName'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      role: data['role'] as String? ?? 'dealer',
      agencyIds: (data['agencyIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      agencyId: data['agencyId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      mustChangePassword: data['mustChangePassword'] as bool? ?? false,
      isAgencyOwner: data['isAgencyOwner'] as bool? ?? false,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> _toMap(UserEntity user) => {
        'email': user.email,
        'username': user.username,
        if (user.fullName != null) 'fullName': user.fullName,
        if (user.profileImageUrl != null)
          'profileImageUrl': user.profileImageUrl,
        'role': user.role,
        'agencyIds': user.agencyIds,
        if (user.agencyId != null) 'agencyId': user.agencyId,
        'isActive': user.isActive,
        'mustChangePassword': user.mustChangePassword,
        'isAgencyOwner': user.isAgencyOwner,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<void> create(String uid, UserEntity user) async {
    await _firestore.collection(_collection).doc(uid).set(_toMap(user));
  }

  @override
  Future<void> update(String uid, UserEntity user) async {
    await _firestore.collection(_collection).doc(uid).update(_toMap(user));
  }

  @override
  Future<UserEntity?> getById(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  @override
  Future<List<UserEntity>> getByRole(String role) async {
    final qs = await _firestore
        .collection(_collection)
        .where('role', isEqualTo: role)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Stream<UserEntity?> streamById(String uid) {
    return _firestore.collection(_collection).doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDocument(doc);
    });
  }
}
