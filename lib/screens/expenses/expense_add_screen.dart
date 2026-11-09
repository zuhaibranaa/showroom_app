import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/reference_options.dart';
import '../../models/expense_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';

class ExpenseAddScreen extends ConsumerStatefulWidget {
  const ExpenseAddScreen({super.key, this.id, this.kind = 'showroom'});

  final String? id;
  final String kind;

  @override
  ConsumerState<ExpenseAddScreen> createState() => _ExpenseAddScreenState();
}

class _ExpenseAddScreenState extends ConsumerState<ExpenseAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _category;
  String? _selectedVehicleId;
  String? _selectedAgencyId;
  DateTime _date = DateTime.now();
  ExpenseModel? _existing;
  bool _loading = false;
  bool _saving = false;
  String? _loadError;

  bool get _isBike => widget.kind == 'bike';

  @override
  void initState() {
    super.initState();
    final agencies = ref.read(accessibleAgenciesProvider).valueOrNull;
    if (agencies != null && agencies.isNotEmpty) {
      _selectedAgencyId = agencies.first.id;
    }
    if (widget.id != null) _loadExpense();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExpense() async {
    setState(() => _loading = true);
    try {
      final expense = await ref
          .read(expenseServiceProvider)
          .getExpenseById(widget.id!);
      if (!mounted) return;
      // Agency-scoping: admins can only edit expenses for their own agencies.
      final user = ref.read(currentUserProvider).value;
      if (user == null ||
          (!AccessService.isSuperAdmin(user) &&
              !user.agencyIds.contains(expense.agencyId))) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unauthorized: expense not in your agency.')),
          );
        }
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _existing = expense;
        _category = expense.category;
        _selectedVehicleId = expense.vehicleId;
        _selectedAgencyId = expense.agencyId.isEmpty
            ? _selectedAgencyId
            : expense.agencyId;
        _amountController.text = expense.amount.toStringAsFixed(2);
        _notesController.text = expense.notes ?? '';
        _date = expense.date;
      });
    } catch (error) {
      _loadError = '$error';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 'Enter an amount greater than zero';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!AccessService.isStaff(ref.read(currentUserProvider).value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can save expenses.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_isBike &&
        (_selectedVehicleId == null || _selectedVehicleId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a bike for this expense.')),
      );
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_date.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense date cannot be in the future.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final vehicles =
          ref.read(accessibleVehiclesProvider).valueOrNull ?? const [];
      final vehicle = _selectedVehicleId == null
          ? null
          : vehicles.where((item) => item.id == _selectedVehicleId).firstOrNull;
      final createdAt = _existing?.createdAt ?? now;
      final expense = ExpenseModel(
        id: _existing?.id ?? '',
        agencyId: _isBike
            ? (vehicle?.agencyId ?? _existing?.agencyId ?? '')
            : (_selectedAgencyId ?? ''),
        vehicleId: _isBike ? _selectedVehicleId : null,
        kind: widget.kind,
        category: _category!.trim(),
        amount: double.parse(_amountController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        date: _date,
        createdAt: createdAt,
        updatedAt: now,
      );
      if (_existing == null) {
        await ref.read(expenseServiceProvider).createExpense(expense);
      } else {
        await ref
            .read(expenseServiceProvider)
            .updateExpense(_existing!.id, expense);
      }
      ref.invalidate(expensesProvider);
      ref.invalidate(accessibleExpensesProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage = AccessService.isStaff(
      ref.watch(currentUserProvider).value,
    );
    final categories = _isBike
        ? ReferenceOptions.bikeExpenseCategories
        : ReferenceOptions.showroomExpenseCategories;
    final categoryItems = <String>[
      ...categories,
      if (_category != null && !categories.contains(_category)) _category!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_existing == null ? 'Add' : 'Edit'} ${_isBike ? 'Bike' : 'Showroom'} Expense',
        ),
      ),
      body: !canManage
          ? const Center(child: Text('Only admins can manage expenses.'))
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(child: Text(_loadError!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isBike)
                      ref
                          .watch(accessibleVehiclesProvider)
                          .when(
                            loading: () => const LinearProgressIndicator(),
                            error: (error, _) => Text('$error'),
                            data: (vehicles) => DropdownButtonFormField<String>(
                              initialValue:
                                  vehicles.any(
                                    (vehicle) =>
                                        vehicle.id == _selectedVehicleId,
                                  )
                                  ? _selectedVehicleId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Bike *',
                                border: OutlineInputBorder(),
                              ),
                              items: vehicles
                                  .map(
                                    (vehicle) => DropdownMenuItem(
                                      value: vehicle.id,
                                      child: Text(
                                        '${vehicle.make} ${vehicle.model}${vehicle.licensePlate.isEmpty ? '' : ' · ${vehicle.licensePlate}'}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedVehicleId = value),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Bike is required'
                                  : null,
                            ),
                          )
                    else
                      ref
                          .watch(accessibleAgenciesProvider)
                          .when(
                            loading: () => const LinearProgressIndicator(),
                            error: (error, _) => Text('$error'),
                            data: (agencies) => DropdownButtonFormField<String>(
                              initialValue:
                                  agencies.any(
                                    (agency) => agency.id == _selectedAgencyId,
                                  )
                                  ? _selectedAgencyId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Agency',
                                border: OutlineInputBorder(),
                              ),
                              items: agencies
                                  .map(
                                    (agency) => DropdownMenuItem(
                                      value: agency.id,
                                      child: Text(agency.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedAgencyId = value),
                            ),
                          ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                      ),
                      items: categoryItems
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _category = value),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Category is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        prefixText: 'Rs ',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('MMM d, yyyy').format(_date)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _existing == null
                                  ? 'Save Expense'
                                  : 'Update Expense',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
