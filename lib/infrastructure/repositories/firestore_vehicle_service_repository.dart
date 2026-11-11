import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/vehicle_service_record.dart';
import '../../../core/domain/repositories/vehicle_service_repository.dart';

/// Firestore implementation of [IVehicleServiceRepository].
class FirestoreVehicleServiceRepository implements IVehicleServiceRepository {
  final FirebaseFirestore _firestore;

  FirestoreVehicleServiceRepository(this._firestore);

  static const String _collection = AppConfig.vehicleServicesCollection;

  VehicleServiceRecordEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleServiceRecordEntity(
      id: doc.id,
      type: data['type'] as String? ?? 'REGISTRATION',
      phone: data['phone'] as String? ?? '',
      receivedBy: data['receivedBy'] as String? ?? '',
      agencyId: data['agencyId'] as String? ?? '',
      chassisNo: data['chassisNo'] as String?,
      oldNumber: data['oldNumber'] as String?,
      newNumber: data['newNumber'] as String?,
      customerName: data['customerName'] as String?,
      firstOwner: data['firstOwner'] as String?,
      secondOwner: data['secondOwner'] as String?,
      note: data['note'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      firstOwnerBiometricPending: data['firstOwnerBiometricPending'] ?? false,
      secondOwnerBiometricPending: data['secondOwnerBiometricPending'] ?? false,
      date: _toDateTime(data['date']),
    );
  }

  Map<String, dynamic> _toMap(VehicleServiceRecordEntity record) => {
        'type': record.type,
        'phone': record.phone,
        'receivedBy': record.receivedBy,
        'agencyId': record.agencyId,
        'chassisNo': record.chassisNo,
        'oldNumber': record.oldNumber,
        'newNumber': record.newNumber,
        'customerName': record.customerName,
        'firstOwner': record.firstOwner,
        'secondOwner': record.secondOwner,
        'note': record.note,
        'amount': record.amount,
        'firstOwnerBiometricPending': record.firstOwnerBiometricPending,
        'secondOwnerBiometricPending': record.secondOwnerBiometricPending,
        'date': record.date.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse('$value') ?? DateTime.now();
    return DateTime.now();
  }

  @override
  Future<String> create(VehicleServiceRecordEntity record) async {
    final doc = await _firestore.collection(_collection).add(_toMap(record));
    return doc.id;
  }

  @override
  Future<void> update(String id, VehicleServiceRecordEntity record) async {
    await _firestore.collection(_collection).doc(id).update(_toMap(record));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<VehicleServiceRecordEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<VehicleServiceRecordEntity>> getByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<VehicleServiceRecordEntity>> getByVehicle(String vehicleId) async {
    // VehicleServiceRecord does not store vehicleId directly; it stores chassisNo/oldNumber/newNumber.
    // Query by chassis number as a fallback if needed.
    return [];
  }

  @override
  Future<VehicleServiceRecordEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  @override
  Stream<List<VehicleServiceRecordEntity>> streamAll() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDocument).toList();
    });
  }

  @override
  Stream<List<VehicleServiceRecordEntity>> streamByAgency(String agencyId) {
    return _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }

  @override
  Stream<List<VehicleServiceRecordEntity>> streamByVehicle(String vehicleId) {
    return Stream.value([]);
  }
}
