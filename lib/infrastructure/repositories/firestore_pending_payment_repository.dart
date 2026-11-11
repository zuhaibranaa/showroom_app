import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/pending_payment.dart';
import '../../../core/domain/repositories/pending_payment_repository.dart';

/// Firestore implementation of [IPendingPaymentRepository].
class FirestorePendingPaymentRepository implements IPendingPaymentRepository {
  final FirebaseFirestore _firestore;

  FirestorePendingPaymentRepository(this._firestore);

  static const String _collection = AppConfig.paymentsCollection;

  PendingPaymentEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PendingPaymentEntity(
      id: doc.id,
      agencyId: data['agencyId'] as String? ?? '',
      saleId: data['saleId'] as String?,
      vehicleId: data['vehicleId'] as String?,
      buyerName: data['buyerName'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      status: data['status'] as String? ?? 'pending',
      notes: data['notes'] as String?,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> _toMap(PendingPaymentEntity payment) => {
        'agencyId': payment.agencyId,
        'saleId': payment.saleId,
        'vehicleId': payment.vehicleId,
        'buyerName': payment.buyerName,
        'amount': payment.amount,
        'dueDate': payment.dueDate?.toIso8601String(),
        'status': payment.status,
        'notes': payment.notes,
        'createdAt': payment.createdAt.toIso8601String(),
        'updatedAt': payment.updatedAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<String> create(PendingPaymentEntity payment) async {
    final doc = await _firestore.collection(_collection).add(_toMap(payment));
    return doc.id;
  }

  @override
  Future<void> update(String id, PendingPaymentEntity payment) async {
    await _firestore.collection(_collection).doc(id).update(_toMap(payment));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<PendingPaymentEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<PendingPaymentEntity>> getByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<PendingPaymentEntity>> getBySale(String saleId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('saleId', isEqualTo: saleId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<PendingPaymentEntity>> getByVehicle(String vehicleId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('vehicleId', isEqualTo: vehicleId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<PendingPaymentEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  @override
  Stream<List<PendingPaymentEntity>> streamAll() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDocument).toList();
    });
  }

  @override
  Stream<List<PendingPaymentEntity>> streamByAgency(String agencyId) {
    return _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }
}
