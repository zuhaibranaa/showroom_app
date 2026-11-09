import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/access_service_compat.dart';
import '../compat/model_converters.dart';
import '../core/application/services/expense_application_service.dart';
import '../core/domain/entities/expense.dart';
import '../core/domain/repositories/expense_repository.dart';
import '../infrastructure/repositories/firestore_expense_repository.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart' hide accessServiceProvider;
import 'access_provider.dart';

// Repository provider (DIP: depends on abstraction)
final expenseRepositoryProvider = Provider<IExpenseRepository>((ref) {
  return FirestoreExpenseRepository(FirebaseFirestore.instance);
});

// Backward-compatible expense service provider
final expenseServiceProvider = Provider((ref) {
  return _ExpenseServiceCompat(ref.watch(expenseApplicationServiceProvider));
});

class _ExpenseServiceCompat {
  final ExpenseApplicationService _service;
  _ExpenseServiceCompat(this._service);
  Future<List<ExpenseModel>> getExpenses() => _service.getAll().then((e) => e.map(expenseEntityToModel).toList());
  Future<List<ExpenseModel>> getExpensesByAgency(String agencyId) => _service.getByAgency(agencyId).then((e) => e.map(expenseEntityToModel).toList());
  Future<ExpenseModel> getExpenseById(String id) async {
    final e = await _service.getById(id);
    if (e == null) throw Exception('Expense not found');
    return expenseEntityToModel(e);
  }
  Future<void> createExpense(ExpenseModel expense) => _service.create(expenseModelToEntity(expense));
  Future<void> updateExpense(String id, ExpenseModel expense) => _service.update(id, expenseModelToEntity(expense));
  Future<void> deleteExpense(String id) => _service.delete(id);
  Stream<List<ExpenseModel>> expensesStream() => _service.getAll().asStream().map((e) => e.map(expenseEntityToModel).toList());
}

// Backward-compatible accessible expenses provider
final accessibleExpensesProvider = FutureProvider<List<ExpenseModel>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return const [];
  final service = ref.watch(expenseApplicationServiceProvider);
  final accessService = ref.watch(accessServiceProvider);
  if (accessService.isSuperAdmin(userModelToEntity(user))) {
    final entities = await service.getAll();
    return entities.map(expenseEntityToModel).toList();
  }
  final seen = <String>{};
  final result = <ExpenseModel>[];
  for (final agencyId in user.agencyIds) {
    final entities = await service.getByAgency(agencyId);
    for (final item in entities) {
      if (seen.add(item.id)) result.add(expenseEntityToModel(item));
    }
  }
  return result;
});

// Application service provider (depends on repository abstraction)
final expenseApplicationServiceProvider =
    Provider<ExpenseApplicationService>((ref) {
  return ExpenseApplicationService(ref.watch(expenseRepositoryProvider));
});

// Expense model providers (backward compatible with screens)
final expensesProvider = FutureProvider<List<ExpenseModel>>((ref) async {
  final expenseService = ref.watch(expenseApplicationServiceProvider);
  final entities = await expenseService.getAll();
  return entities.map(expenseEntityToModel).toList();
});

final expensesByAgencyProvider =
    FutureProvider.family<List<ExpenseModel>, String>((ref, agencyId) async {
  final expenseService = ref.watch(expenseApplicationServiceProvider);
  final entities = await expenseService.getByAgency(agencyId);
  return entities.map(expenseEntityToModel).toList();
});

final expenseByIdProvider =
    FutureProvider.family<ExpenseModel?, String>((ref, id) async {
  final expenseService = ref.watch(expenseApplicationServiceProvider);
  final entity = await expenseService.getById(id);
  return entity != null ? expenseEntityToModel(entity) : null;
});

// Create expense state
final createExpenseProvider =
    StateNotifierProvider<CreateExpenseNotifier, AsyncValue<String>>((ref) {
  final expenseService = ref.watch(expenseApplicationServiceProvider);
  return CreateExpenseNotifier(expenseService);
});

class CreateExpenseNotifier extends StateNotifier<AsyncValue<String>> {
  final ExpenseApplicationService _expenseService;

  CreateExpenseNotifier(this._expenseService)
      : super(const AsyncValue.data(''));

  Future<void> createExpense(ExpenseModel expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _expenseService.create(expenseModelToEntity(expense)),
    );
  }
}

// Update expense state
final updateExpenseProvider =
    StateNotifierProvider<UpdateExpenseNotifier, AsyncValue<void>>((ref) {
  final expenseService = ref.watch(expenseApplicationServiceProvider);
  return UpdateExpenseNotifier(expenseService);
});

class UpdateExpenseNotifier extends StateNotifier<AsyncValue<void>> {
  final ExpenseApplicationService _expenseService;

  UpdateExpenseNotifier(this._expenseService)
      : super(const AsyncValue.data(null));

  Future<void> updateExpense(String id, ExpenseModel expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _expenseService.update(id, expenseModelToEntity(expense)),
    );
  }
}

// Delete expense state
final deleteExpenseProvider =
    StateNotifierProvider<DeleteExpenseNotifier, AsyncValue<void>>((ref) {
  final expenseService = ref.watch(expenseApplicationServiceProvider);
  return DeleteExpenseNotifier(expenseService);
});

class DeleteExpenseNotifier extends StateNotifier<AsyncValue<void>> {
  final ExpenseApplicationService _expenseService;

  DeleteExpenseNotifier(this._expenseService)
      : super(const AsyncValue.data(null));

  Future<void> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _expenseService.delete(id),
    );
  }
}
