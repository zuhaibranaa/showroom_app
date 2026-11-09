import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/vehicle.dart';
import '../../../core/domain/repositories/vehicle_repository.dart';

/// Firestore implementation of [IVehicleRepository].
///
/// Depends only on [FirebaseFirestore] (an abstraction-friendly SDK class)
/// and the repository interface — not on any application service (DIP).
class FirestoreVehicleRepository implements IVehicleRepository {
  final FirebaseFirestore _firestore;

  FirestoreVehicleRepository(this._firestore);

  static const String _collection = AppConfig.vehiclesCollection;

  VehicleEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleEntity(
      id: doc.id,
      agencyId: data['agencyId'] as String? ?? '',
      make: data['make'] as String? ?? '',
      model: data['model'] as String? ?? '',
      year: (data['year'] as num?)?.toInt() ?? 0,
      color: data['color'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      chassisNo: data['chassisNo'] as String? ?? '',
      engineNo: data['engineNo'] as String? ?? '',
      plateNo: data['plateNo'] as String? ?? '',
      vin: data['vin'] as String? ?? '',
      priceAmount: (data['priceAmount'] as num?)?.toDouble() ?? 0.0,
      isZeroMeter: data['isZeroMeter'] as bool? ?? false,
      documentStatus: data['documentStatus'] as String? ?? '',
      purchaseDate: _toDateTime(data['purchaseDate']),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> _toMap(VehicleEntity vehicle) => {
        'agencyId': vehicle.agencyId,
        'make': vehicle.make,
        'model': vehicle.model,
        'year': vehicle.year,
        'color': vehicle.color,
        'licensePlate': vehicle.licensePlate,
        'chassisNo': vehicle.chassisNo,
        'engineNo': vehicle.engineNo,
        'plateNo': vehicle.plateNo,
        'vin': vehicle.vin,
        'priceAmount': vehicle.priceAmount,
        'isZeroMeter': vehicle.isZeroMeter,
        'documentStatus': vehicle.documentStatus,
        'purchaseDate': vehicle.purchaseDate.toIso8601String(),
        'createdAt': vehicle.createdAt.toIso8601String(),
        'updatedAt': vehicle.updatedAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<String> create(VehicleEntity vehicle) async {
    final doc = await _firestore.collection(_collection).add(_toMap(vehicle));
    return doc.id;
  }

  @override
  Future<void> update(String id, VehicleEntity vehicle) async {
    await _firestore.collection(_collection).doc(id).update(_toMap(vehicle));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<VehicleEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<VehicleEntity>> getByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<VehicleEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  @override
  Stream<List<VehicleEntity>> streamAll() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDocument).toList();
    });
  }

  @override
  Stream<List<VehicleEntity>> streamByAgency(String agencyId) {
    return _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }
}
