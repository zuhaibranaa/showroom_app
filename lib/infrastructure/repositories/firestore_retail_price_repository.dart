import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/retail_price.dart';
import '../../../core/domain/repositories/retail_price_repository.dart';

/// Firestore implementation of [IRetailPriceRepository].
class FirestoreRetailPriceRepository implements IRetailPriceRepository {
  final FirebaseFirestore _firestore;

  FirestoreRetailPriceRepository(this._firestore);

  static const String _collection = AppConfig.retailPricesCollection;

  RetailPriceEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RetailPriceEntity(
      id: doc.id,
      make: data['make'] as String? ?? '',
      model: data['model'] as String? ?? '',
      agencyId: data['agencyId'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> _toMap(RetailPriceEntity price) => {
        'make': price.make,
        'model': price.model,
        'agencyId': price.agencyId,
        'price': price.price,
        'updatedAt': price.updatedAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<String> create(RetailPriceEntity price) async {
    final doc = await _firestore.collection(_collection).add(_toMap(price));
    return doc.id;
  }

  @override
  Future<void> update(String id, RetailPriceEntity price) async {
    await _firestore.collection(_collection).doc(id).update(_toMap(price));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<RetailPriceEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<RetailPriceEntity>> getByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<RetailPriceEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  @override
  Future<RetailPriceEntity?> getByMakeModel(
      String agencyId, String make, String model) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .where('make', isEqualTo: make)
        .where('model', isEqualTo: model)
        .limit(1)
        .get();
    if (qs.docs.isEmpty) return null;
    return _fromDocument(qs.docs.first);
  }

  @override
  Stream<List<RetailPriceEntity>> streamAll() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDocument).toList();
    });
  }

  @override
  Stream<List<RetailPriceEntity>> streamByAgency(String agencyId) {
    return _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }
}
