import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/agency.dart';
import '../../../core/domain/repositories/agency_repository.dart';

/// Firestore implementation of [IAgencyRepository].
class FirestoreAgencyRepository implements IAgencyRepository {
  final FirebaseFirestore _firestore;

  FirestoreAgencyRepository(this._firestore);

  static const String _collection = AppConfig.agenciesCollection;

  AgencyEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgencyEntity(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> _toMap(AgencyEntity agency) => {
        'name': agency.name,
        'createdAt': agency.createdAt.toIso8601String(),
        'updatedAt': agency.updatedAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<String> create(AgencyEntity agency) async {
    final doc = await _firestore.collection(_collection).add(_toMap(agency));
    return doc.id;
  }

  @override
  Future<void> update(String id, AgencyEntity agency) async {
    await _firestore.collection(_collection).doc(id).update(_toMap(agency));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<AgencyEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<AgencyEntity>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final results = <AgencyEntity>[];
    for (final id in ids) {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) results.add(_fromDocument(doc));
    }
    return results;
  }

  @override
  Future<AgencyEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }
}
