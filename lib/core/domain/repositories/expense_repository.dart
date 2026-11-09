import '../entities/expense.dart';

/// Read-side contract for expense data.
abstract class IExpenseReadRepository {
  Future<List<ExpenseEntity>> getAll();
  Future<List<ExpenseEntity>> getByAgency(String agencyId);
  Future<ExpenseEntity?> getById(String id);
}

/// Write-side contract for expense data.
abstract class IExpenseWriteRepository {
  Future<String> create(ExpenseEntity expense);
  Future<void> update(String id, ExpenseEntity expense);
  Future<void> delete(String id);
}

/// Full expense repository contract (read + write).
abstract class IExpenseRepository
    implements IExpenseReadRepository, IExpenseWriteRepository {}
