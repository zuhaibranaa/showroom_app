import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/reference_options.dart';
import '../../models/expense_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/vehicle_provider.dart';
import 'expense_add_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  bool _allDates = false;
  String _category = 'All categories';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final canManage = AccessService.isStaff(user);
    final expenses = ref.watch(accessibleExpensesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expenses'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.two_wheeler), text: 'Bike'),
              Tab(icon: Icon(Icons.storefront), text: 'Showroom'),
            ],
          ),
        ),
        floatingActionButton: canManage
            ? Builder(
                builder: (context) => FloatingActionButton(
                  onPressed: () => _openForm(
                    context,
                    DefaultTabController.of(context).index,
                  ),
                  child: const Icon(Icons.add),
                ),
              )
            : null,
        body: !canManage
            ? const Center(child: Text('Only admins can manage expenses.'))
            : expenses.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error.toString(), textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(accessibleExpensesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (items) => TabBarView(
                  children: [
                    _buildTab(context, items, 'bike'),
                    _buildTab(context, items, 'showroom'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, List<ExpenseModel> all, String kind) {
    final categories = kind == 'bike'
        ? ReferenceOptions.bikeExpenseCategories
        : ReferenceOptions.showroomExpenseCategories;
    final now = DateTime.now();
    final kindItems = all.where((expense) => expense.kind == kind).toList();
    final filtered = kindItems.where((expense) {
      final inPeriod =
          _allDates ||
          (expense.date.year == now.year && expense.date.month == now.month);
      return inPeriod &&
          (_category == 'All categories' || expense.category == _category);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
    final total = filtered.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    if (_category != 'All categories' && !categories.contains(_category)) {
      _category = 'All categories';
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(accessibleExpensesProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryValue(
                      label: _allDates ? 'All-time expenses' : 'This month',
                      value: NumberFormat.currency(symbol: 'Rs ').format(total),
                    ),
                  ),
                  Expanded(
                    child: _SummaryValue(
                      label: 'Records',
                      value: filtered.length.toString(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Current month'),
                selected: !_allDates,
                onSelected: (_) => setState(() => _allDates = false),
              ),
              ChoiceChip(
                label: const Text('All dates'),
                selected: _allDates,
                onSelected: (_) => setState(() => _allDates = true),
              ),
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'All categories',
                      child: Text('All categories'),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _category = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('No expenses found')),
            )
          else
            ...filtered.map((expense) => _expenseCard(context, expense)),
        ],
      ),
    );
  }

  Widget _expenseCard(BuildContext context, ExpenseModel expense) {
    final vehicle = expense.vehicleId == null
        ? null
        : ref.watch(vehicleByIdOrNullProvider(expense.vehicleId!)).valueOrNull;
    final vehicleName = vehicle == null
        ? null
        : '${vehicle.make} ${vehicle.model}${vehicle.licensePlate.isEmpty ? '' : ' · ${vehicle.licensePlate}'}';
    return Card(
      child: ListTile(
        title: Text(expense.category),
        subtitle: Text(
          [
            DateFormat('MMM d, yyyy').format(expense.date),
            if (vehicleName != null) vehicleName,
            if (expense.notes?.isNotEmpty == true) expense.notes,
          ].join('\n'),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat.currency(symbol: 'Rs ').format(expense.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') {
                  _openForm(context, expense.kind == 'bike' ? 0 : 1, expense);
                } else {
                  _delete(expense);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    int tab, [
    ExpenseModel? expense,
  ]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExpenseAddScreen(
          id: expense?.id,
          kind: expense?.kind ?? (tab == 0 ? 'bike' : 'showroom'),
        ),
      ),
    );
    if (saved == true) ref.invalidate(accessibleExpensesProvider);
  }

  Future<void> _delete(ExpenseModel expense) async {
    final user = ref.read(currentUserProvider).value;
    if (!AccessService.isStaff(user)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(expenseServiceProvider).deleteExpense(expense.id);
      ref.invalidate(accessibleExpensesProvider);
      ref.invalidate(expensesProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
