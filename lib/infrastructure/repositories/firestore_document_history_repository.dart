import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/document_history.dart';
import '../../../core/domain/repositories/document_history_repository.dart';

/// Firestore implementation of [IDocumentHistoryRepository].
class FirestoreDocumentHistoryRepository
    implements IDocumentHistoryRepository {
  final FirebaseFirestore _firestore;

  FirestoreDocumentHistoryRepository(this._firestore);

  static const String _collection = AppConfig.documentHistoryCollection;

  DocumentHistoryEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentHistoryEntity(
      id: doc.id,
      vehicleId: data['vehicleId'] as String? ?? '',
      agencyId: data['agencyId'] as String? ?? '',
      status: data['status'] as String? ?? 'PENDING',
      changedBy: data['changedBy'] as String? ?? '',
      remarks: data['remarks'] as String?,
      registrationStatus: data['registrationStatus'] as String?,
      registeredFrom: data['registeredFrom'] as String?,
      numberPlate: data['numberPlate'] as String?,
      registrationBook: data['registrationBook'] as String?,
      checklist: List<String>.from(data['checklist'] ?? []),
      statusDate: _toDateTime(data['statusDate']),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> _toMap(DocumentHistoryEntity history) => {
        'vehicleId': history.vehicleId,
        'agencyId': history.agencyId,
        'status': history.status,
        'changedBy': history.changedBy,
        'remarks': history.remarks,
        'registrationStatus': history.registrationStatus,
        'registeredFrom': history.registeredFrom,
        'numberPlate': history.numberPlate,
        'registrationBook': history.registrationBook,
        'checklist': history.checklist,
        'statusDate': history.statusDate.toIso8601String(),
        'createdAt': history.createdAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<String> create(DocumentHistoryEntity history) async {
    final doc = await _firestore.collection(_collection).add(_toMap(history));
    return doc.id;
  }

  @override
  Future<void> update(String id, DocumentHistoryEntity history) async {
    await _firestore.collection(_collection).doc(id).update(_toMap(history));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<DocumentHistoryEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<DocumentHistoryEntity>> getByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<DocumentHistoryEntity>> getByVehicle(String vehicleId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('vehicleId', isEqualTo: vehicleId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<DocumentHistoryEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  @override
  Stream<List<DocumentHistoryEntity>> streamAll() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDocument).toList();
    });
  }

  @override
  Stream<List<DocumentHistoryEntity>> streamByAgency(String agencyId) {
    return _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }

  @override
  Stream<List<DocumentHistoryEntity>> streamByVehicle(String vehicleId) {
    return _firestore
        .collection(_collection)
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDocument).toList());
  }
}
