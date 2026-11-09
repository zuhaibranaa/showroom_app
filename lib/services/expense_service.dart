import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createExpense(ExpenseModel expense) async {
    final doc = await _firestore
        .collection(AppConfig.expensesCollection)
        .add(expense.toJson());
    return doc.id;
  }

  Future<List<ExpenseModel>> getExpenses() async {
    final qs = await _firestore.collection(AppConfig.expensesCollection).get();
    return qs.docs
        .map((doc) => ExpenseModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<ExpenseModel>> getExpensesByAgency(String agencyId) async {
    final qs = await _firestore
        .collection(AppConfig.expensesCollection)
        .where('agencyId', isEqualTo: agencyId)
        .get();
    return qs.docs
        .map((doc) => ExpenseModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<ExpenseModel> getExpenseById(String id) async {
    final doc = await _firestore
        .collection(AppConfig.expensesCollection)
        .doc(id)
        .get();
    if (!doc.exists) throw Exception('Expense not found');
    return ExpenseModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> updateExpense(String id, ExpenseModel expense) async {
    await _firestore
        .collection(AppConfig.expensesCollection)
        .doc(id)
        .update(expense.toJson());
  }

  Future<void> deleteExpense(String id) async {
    await _firestore.collection(AppConfig.expensesCollection).doc(id).delete();
  }
}
