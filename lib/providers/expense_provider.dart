import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../providers/access_provider.dart';
import '../providers/auth_provider.dart';
import '../services/expense_service.dart';

final expenseServiceProvider = Provider((ref) => ExpenseService());

final accessibleExpensesProvider = FutureProvider<List<ExpenseModel>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return const [];
  final service = ref.watch(expenseServiceProvider);
  if (AccessService.isSuperAdmin(user)) {
    return service.getExpenses();
  }
  final seen = <String>{};
  final result = <ExpenseModel>[];
  for (final agencyId in user.agencyIds) {
    final items = await service.getExpensesByAgency(agencyId);
    for (final item in items) {
      if (seen.add(item.id)) result.add(item);
    }
  }
  return result;
});

final expensesProvider = FutureProvider<List<ExpenseModel>>((ref) async {
  final s = ref.watch(expenseServiceProvider);
  return s.getExpenses();
});

final expensesByAgencyProvider =
    FutureProvider.family<List<ExpenseModel>, String>((ref, agencyId) async {
      final s = ref.watch(expenseServiceProvider);
      return s.getExpensesByAgency(agencyId);
    });

final expenseByIdProvider = FutureProvider.family<ExpenseModel, String>((
  ref,
  id,
) async {
  final s = ref.watch(expenseServiceProvider);
  return s.getExpenseById(id);
});

final createExpenseProvider =
    StateNotifierProvider<CreateExpenseNotifier, AsyncValue<String>>((ref) {
      final s = ref.watch(expenseServiceProvider);
      return CreateExpenseNotifier(s);
    });

class CreateExpenseNotifier extends StateNotifier<AsyncValue<String>> {
  final ExpenseService _s;
  CreateExpenseNotifier(this._s) : super(const AsyncValue.data(''));
  Future<void> createExpense(ExpenseModel e) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _s.createExpense(e));
  }
}

final updateExpenseProvider =
    StateNotifierProvider<UpdateExpenseNotifier, AsyncValue<void>>((ref) {
      final s = ref.watch(expenseServiceProvider);
      return UpdateExpenseNotifier(s);
    });

class UpdateExpenseNotifier extends StateNotifier<AsyncValue<void>> {
  final ExpenseService _s;
  UpdateExpenseNotifier(this._s) : super(const AsyncValue.data(null));
  Future<void> updateExpense(String id, ExpenseModel e) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _s.updateExpense(id, e));
  }
}

final deleteExpenseProvider =
    StateNotifierProvider<DeleteExpenseNotifier, AsyncValue<void>>((ref) {
      final s = ref.watch(expenseServiceProvider);
      return DeleteExpenseNotifier(s);
    });

class DeleteExpenseNotifier extends StateNotifier<AsyncValue<void>> {
  final ExpenseService _s;
  DeleteExpenseNotifier(this._s) : super(const AsyncValue.data(null));
  Future<void> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _s.deleteExpense(id));
  }
}
