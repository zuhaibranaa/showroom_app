import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/operations_models.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/operations_provider.dart';

class VehicleServiceAddScreen extends ConsumerStatefulWidget {
  const VehicleServiceAddScreen({
    super.key,
    this.id,
    this.type = 'REGISTRATION',
  });

  final String? id;
  final String type;

  @override
  ConsumerState<VehicleServiceAddScreen> createState() =>
      _VehicleServiceAddScreenState();
}

class _VehicleServiceAddScreenState
    extends ConsumerState<VehicleServiceAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chassisController = TextEditingController();
  final _oldNumberController = TextEditingController();
  final _newNumberController = TextEditingController();
  final _customerController = TextEditingController();
  final _firstOwnerController = TextEditingController();
  final _secondOwnerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _receivedByController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'REGISTRATION';
  DateTime _date = DateTime.now();
  bool _firstOwnerBiometricPending = false;
  bool _secondOwnerBiometricPending = false;
  VehicleServiceRecord? _existing;
  bool _loading = false;
  bool _saving = false;
  String? _loadError;

  bool get _isTransfer => _type == 'TRANSFER';

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    if (widget.id != null) _loadRecord();
  }

  @override
  void dispose() {
    _chassisController.dispose();
    _oldNumberController.dispose();
    _newNumberController.dispose();
    _customerController.dispose();
    _firstOwnerController.dispose();
    _secondOwnerController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _receivedByController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    setState(() => _loading = true);
    try {
      final services = await ref.read(vehicleServicesProvider.future);
      final record = services.firstWhere((item) => item.id == widget.id);
      if (!mounted) return;
      setState(() {
        _existing = record;
        _type = record.type;
        _chassisController.text = record.chassisNo ?? '';
        _oldNumberController.text = record.oldNumber ?? '';
        _newNumberController.text = record.newNumber ?? '';
        _customerController.text = record.customerName ?? '';
        _firstOwnerController.text = record.firstOwner ?? '';
        _secondOwnerController.text = record.secondOwner ?? '';
        _phoneController.text = record.phone;
        _amountController.text = record.amount.toStringAsFixed(2);
        _receivedByController.text = record.receivedBy;
        _noteController.text = record.note ?? '';
        _date = record.date;
        _firstOwnerBiometricPending = record.firstOwnerBiometricPending;
        _secondOwnerBiometricPending = record.secondOwnerBiometricPending;
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

  String? _validatePhone(String? value) {
    final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.length < 7) return 'Phone must have at least 7 digits';
    return null;
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 'Enter an amount greater than zero';
    }
    return null;
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).value;
    if (!AccessService.isStaff(user)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can save records.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (_isTransfer) {
      final oldNumber = _oldNumberController.text.trim();
      final newNumber = _newNumberController.text.trim();
      if (oldNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Old number is required for transfer.')),
        );
        return;
      }
      if (newNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New number is required for transfer.')),
        );
        return;
      }
      if (oldNumber == newNumber) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Old and new numbers must be different.'),
          ),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final record = VehicleServiceRecord(
        id: _existing?.id ?? '',
        type: _type,
        chassisNo: _chassisController.text.trim().isEmpty
            ? null
            : _chassisController.text.trim(),
        oldNumber: _oldNumberController.text.trim().isEmpty
            ? null
            : _oldNumberController.text.trim(),
        newNumber: _newNumberController.text.trim().isEmpty
            ? null
            : _newNumberController.text.trim(),
        customerName: _customerController.text.trim().isEmpty
            ? null
            : _customerController.text.trim(),
        firstOwner: _firstOwnerController.text.trim().isEmpty
            ? null
            : _firstOwnerController.text.trim(),
        secondOwner: _secondOwnerController.text.trim().isEmpty
            ? null
            : _secondOwnerController.text.trim(),
        phone: _phoneController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        receivedBy: _receivedByController.text.trim(),
        agencyId: ref.read(currentUserProvider).value?.agencyId ?? '',
        date: _date,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        firstOwnerBiometricPending: _firstOwnerBiometricPending,
        secondOwnerBiometricPending: _secondOwnerBiometricPending,
      );
      if (_existing == null) {
        await ref.read(operationsServiceProvider).saveVehicleService(record);
      } else {
        await ref
            .read(operationsServiceProvider)
            .saveVehicleService(record, id: _existing!.id);
      }
      ref.invalidate(vehicleServicesProvider);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_existing == null ? 'Add' : 'Edit'} Registration/Transfer',
        ),
      ),
      body: !canManage
          ? const Center(child: Text('Only admins can manage records.'))
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
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'REGISTRATION',
                          child: Text('Registration'),
                        ),
                        DropdownMenuItem(
                          value: 'TRANSFER',
                          child: Text('Transfer'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _type = value);
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Type is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _chassisController,
                      decoration: const InputDecoration(
                        labelText: 'Chassis number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _oldNumberController,
                      decoration: InputDecoration(
                        labelText: _isTransfer ? 'Old number *' : 'Old number',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newNumberController,
                      decoration: InputDecoration(
                        labelText: _isTransfer ? 'New number *' : 'New number',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerController,
                      decoration: const InputDecoration(
                        labelText: 'Customer name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstOwnerController,
                      decoration: const InputDecoration(
                        labelText: 'First owner',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _secondOwnerController,
                      decoration: const InputDecoration(
                        labelText: 'Second owner',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone *',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validatePhone,
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
                    TextFormField(
                      controller: _receivedByController,
                      decoration: const InputDecoration(
                        labelText: 'Received by *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Received by is required'
                          : null,
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
                    CheckboxListTile(
                      value: _firstOwnerBiometricPending,
                      onChanged: (value) => setState(
                        () => _firstOwnerBiometricPending = value ?? false,
                      ),
                      title: const Text('First owner biometric pending'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _secondOwnerBiometricPending,
                      onChanged: (value) => setState(
                        () => _secondOwnerBiometricPending = value ?? false,
                      ),
                      title: const Text('Second owner biometric pending'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
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
                                  ? 'Save Record'
                                  : 'Update Record',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
