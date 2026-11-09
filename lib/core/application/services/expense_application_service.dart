import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

/// Application service for expense use cases.
class ExpenseApplicationService {
  final IExpenseRepository _repository;

  ExpenseApplicationService(this._repository);

  Future<String> create(ExpenseEntity expense) => _repository.create(expense);
  Future<void> update(String id, ExpenseEntity expense) =>
      _repository.update(id, expense);
  Future<void> delete(String id) => _repository.delete(id);

  Future<List<ExpenseEntity>> getAll() => _repository.getAll();
  Future<List<ExpenseEntity>> getByAgency(String agencyId) =>
      _repository.getByAgency(agencyId);
  Future<ExpenseEntity?> getById(String id) => _repository.getById(id);
}
