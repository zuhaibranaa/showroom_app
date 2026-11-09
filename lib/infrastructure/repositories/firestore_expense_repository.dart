import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_config.dart';
import '../../../core/domain/entities/expense.dart';
import '../../../core/domain/repositories/expense_repository.dart';

/// Firestore implementation of [IExpenseRepository].
class FirestoreExpenseRepository implements IExpenseRepository {
  final FirebaseFirestore _firestore;

  FirestoreExpenseRepository(this._firestore);

  static const String _collection = AppConfig.expensesCollection;

  ExpenseEntity _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseEntity(
      id: doc.id,
      agencyId: data['agencyId'] as String? ?? '',
      vehicleId: data['vehicleId'] as String?,
      kind: data['kind'] as String? ?? 'showroom',
      category: data['category'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'] as String?,
      date: _toDateTime(data['date']),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> _toMap(ExpenseEntity expense) => {
        'agencyId': expense.agencyId,
        if (expense.vehicleId != null) 'vehicleId': expense.vehicleId,
        'kind': expense.kind,
        'category': expense.category,
        'amount': expense.amount,
        if (expense.notes != null) 'notes': expense.notes,
        'date': expense.date.toIso8601String(),
        'createdAt': expense.createdAt.toIso8601String(),
        'updatedAt': expense.updatedAt.toIso8601String(),
      };

  DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Future<String> create(ExpenseEntity expense) async {
    final doc = await _firestore.collection(_collection).add(_toMap(expense));
    return doc.id;
  }

  @override
  Future<void> update(String id, ExpenseEntity expense) async {
    await _firestore.collection(_collection).doc(id).update(_toMap(expense));
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<ExpenseEntity>> getAll() async {
    final qs = await _firestore.collection(_collection).get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<List<ExpenseEntity>> getByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(_collection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs.map(_fromDocument).toList();
  }

  @override
  Future<ExpenseEntity?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }
}
