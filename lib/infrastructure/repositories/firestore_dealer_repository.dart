import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/dealer.dart';
import '../../../core/domain/entities/dealer_permissions.dart';
import '../../../core/domain/repositories/dealer_repository.dart';

/// Firestore implementation of [IDealerRepository].
class FirestoreDealerRepository implements IDealerRepository {
  final FirebaseFirestore _firestore;

  FirestoreDealerRepository(this._firestore);

  static const String _collection = AppConfig.dealersCollection;

  DealerEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DealerEntity(
      id: doc.id,
      agencyId: data['agencyId'] as String? ?? '',
      userId: data['userId'] as String?,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      licenseNumber: data['licenseNumber'] as String?,
      commissionPercent: (data['commissionPercent'] as num?)?.toDouble(),
      permissions: _permissionsFromJson(data['permissions']),
      totalCommission: (data['totalCommission'] as num?)?.toDouble() ?? 0.0,
      totalSales: (data['totalSales'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  DealerPermissionsEntity _permissionsFromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return const DealerPermissionsEntity();
    }
    return DealerPermissionsEntity(
      vehicles: ModulePermissionEntity(
        create: json['vehicles']?['create'] as bool? ?? false,
        edit: json['vehicles']?['edit'] as bool? ?? false,
        view: json['vehicles']?['view'] as bool? ?? false,
      ),
      sales: ModulePermissionEntity(
        create: json['sales']?['create'] as bool? ?? false,
        edit: json['sales']?['edit'] as bool? ?? false,
        view: json['sales']?['view'] as bool? ?? false,
      ),
      dealers: ModulePermissionEntity(
        create: json['dealers']?['create'] as bool? ?? false,
        edit: json['dealers']?['edit'] as bool? ?? false,
        view: json['dealers']?['view'] as bool? ?? false,
      ),
    );
  }

  Map<String, dynamic> _toMap(DealerEntity dealer) => {
        'agencyId': dealer.agencyId,
        if (dealer.userId != null) 'userId': dealer.userId,
        'name': dealer.name,
        'email': dealer.email,
        'phone': dealer.phone,
        'address': dealer.address,
        'city': dealer.city,
        if (dealer.licenseNumber != null)
          'licenseNumber': dealer.licenseNumber,
        if (dealer.commissionPercent != null)
          'commissionPercent': dealer.commissionPercent,
        'permissions': {
          'vehicles': {
            'create': dealer.permissions.vehicles.create,
            'edit': dealer.permissions.vehicles.edit,
            'view': dealer.permissions.vehicles.view,
          },
          'sales': {
            'create': dealer.permissions.sales.create,
            'edit': dealer.permissions.sales.edit,
            'view': dealer.permissions.sales.view,
          },
          'dealers': {
            'create': dealer.permissions.dealers.create,
            'edit': dealer.permissions.dealers.edit,
            'view': dealer.permissions.dealers.view,
          },
        },
        'totalCommission': dealer.totalCommission,
        'totalSales': dealer.totalSales,
        'isActive': dealer.isActive,
        'createdAt': dealer.createdAt.toIso8601String(),
        'updatedAt': dealer.updatedAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<String> create(DealerEntity dealer) async {
    final data = _toMap(dealer);
    data['emailLower'] = dealer.email.trim().toLowerCase();
    final doc = await _firestore.collection(_collection).add(data);
    return doc.id;
  }

  @override
  Future<void> update(String id, DealerEntity dealer) async {
    final data = _toMap(dealer);
    data['emailLower'] = dealer.email.trim().toLowerCase();
    await _firestore.collection(_collection).doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<void> linkToUser(String dealerId, String userId) async {
    await _firestore.collection(_collection).doc(dealerId).update({
      'userId': userId,
    });
  }

  @override
  Future<List<DealerEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<DealerEntity>> getByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<DealerEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  @override
  Future<DealerEntity?> getByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final snapshot = await _firestore
        .collection(_collection)
        .where('emailLower', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return _fromDocument(snapshot.docs.first);
    }
    // Legacy fallback
    final all = await _firestore.collection(_collection).get();
    for (final doc in all.docs) {
      final data = doc.data();
      if ((data['email'] as String? ?? '').toLowerCase() == normalized) {
        return _fromDocument(doc);
      }
    }
    return null;
  }

  @override
  Future<DealerEntity?> getByUserId(String userId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();
    if (qs.docs.isEmpty) return null;
    return _fromDocument(qs.docs.first);
  }

  @override
  Stream<List<DealerEntity>> streamAll() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDocument).toList();
    });
  }

  @override
  Stream<List<DealerEntity>> streamByAgency(String agencyId) {
    return _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }

  @override
  Stream<DealerEntity?> streamByUserId(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return _fromDocument(snapshot.docs.first);
    });
  }
}
