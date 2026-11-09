import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/sale.dart';
import '../../../core/domain/repositories/sale_repository.dart';

/// Firestore implementation of [ISaleRepository].
class FirestoreSaleRepository implements ISaleRepository {
  final FirebaseFirestore _firestore;

  FirestoreSaleRepository(this._firestore);

  static const String _collection = AppConfig.salesCollection;

  SaleEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleEntity(
      id: doc.id,
      vehicleId: data['vehicleId'] as String? ?? '',
      buyerName: data['buyerName'] as String? ?? '',
      purchaserCNIC: data['purchaserCNIC'] as String? ?? '',
      buyerPhone: data['buyerPhone'] as String? ?? '',
      salePrice: (data['salePrice'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (data['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      profit: (data['profit'] as num?)?.toDouble() ?? 0.0,
      received: (data['received'] as num?)?.toDouble() ?? 0.0,
      hasBalance: data['hasBalance'] as bool? ?? false,
      dealerId: data['dealerId'] as String?,
      receiptNo: data['receiptNo'] as String?,
      referenceNo: data['referenceNo'] as String?,
      numberPlate: data['numberPlate'] as String?,
      soldWithNumber: data['soldWithNumber'] as String?,
      documentStatus: data['documentStatus'] as String?,
      saleDate: _toDateTime(data['saleDate']),
      agencyId: data['agencyId'] as String? ?? '',
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> _toMap(SaleEntity sale) => {
        'vehicleId': sale.vehicleId,
        'buyerName': sale.buyerName,
        'purchaserCNIC': sale.purchaserCNIC,
        'buyerPhone': sale.buyerPhone,
        'salePrice': sale.salePrice,
        'purchasePrice': sale.purchasePrice,
        'profit': sale.profit,
        'received': sale.received,
        'hasBalance': sale.hasBalance,
        if (sale.dealerId != null) 'dealerId': sale.dealerId,
        if (sale.receiptNo != null) 'receiptNo': sale.receiptNo,
        if (sale.referenceNo != null) 'referenceNo': sale.referenceNo,
        if (sale.numberPlate != null) 'numberPlate': sale.numberPlate,
        if (sale.soldWithNumber != null)
          'soldWithNumber': sale.soldWithNumber,
        if (sale.documentStatus != null)
          'documentStatus': sale.documentStatus,
        'saleDate': sale.saleDate.toIso8601String(),
        'agencyId': sale.agencyId,
        'createdAt': sale.createdAt.toIso8601String(),
        'updatedAt': sale.updatedAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<String> create(SaleEntity sale) async {
    final doc = await _firestore.collection(_collection).add(_toMap(sale));
    return doc.id;
  }

  @override
  Future<void> update(String id, SaleEntity sale) async {
    await _firestore.collection(_collection).doc(id).update(_toMap(sale));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<SaleEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<SaleEntity>> getByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<SaleEntity>> getByVehicle(String vehicleId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('vehicleId', isEqualTo: vehicleId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<SaleEntity>> getByDealer(String dealerId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('dealerId', isEqualTo: dealerId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<SaleEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  @override
  Stream<List<SaleEntity>> streamAll() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDocument).toList();
    });
  }

  @override
  Stream<List<SaleEntity>> streamByAgency(String agencyId) {
    return _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }

  @override
  Stream<List<SaleEntity>> streamByDealer(String dealerId) {
    return _firestore
        .collection(_collection)
        .where('dealerId', isEqualTo: dealerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }
}
