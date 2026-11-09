import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/operations_models.dart';
import '../../models/sale_model.dart';
import '../../providers/operations_provider.dart';
import '../../providers/sale_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_and_error.dart';

class PendingPaymentScreen extends ConsumerStatefulWidget {
  final String saleId;

  const PendingPaymentScreen({super.key, required this.saleId});

  @override
  ConsumerState<PendingPaymentScreen> createState() =>
      _PendingPaymentScreenState();
}

class _PendingPaymentScreenState extends ConsumerState<PendingPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  DateTime? _promisedDate;
  String _mode = 'CASH';
  String? _bank;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit(SaleModel sale) async {
    if (!_formKey.currentState!.validate()) return;
    if (_mode != 'CASH' && _bank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a bank for this payment mode')),
      );
      return;
    }
    final amount = double.parse(_amount.text.trim());
    final balance = sale.balance;
    if (amount > balance + 0.009) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount cannot exceed the balance')),
      );
      return;
    }
    final remaining = balance - amount;
    if (remaining > 0.009 && _promisedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promised date is required for a balance'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(operationsServiceProvider)
          .savePayment(
            PaymentModel(
              saleId: sale.id,
              vehicleId: sale.vehicleId,
              amount: amount,
              date: _date,
              mode: _mode,
              bank: _mode == 'CASH' ? null : _bank,
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
              promisedDate: remaining > 0.009 ? _promisedDate : null,
            ),
          );
      ref.invalidate(saleByIdProvider(widget.saleId));
      ref.invalidate(paymentsForSaleProvider(widget.saleId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment received')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saleAsync = ref.watch(saleByIdProvider(widget.saleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Receive Payment')),
      body: saleAsync.when(
        loading: () => const LoadingWidget(message: 'Loading sale...'),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (sale) {
          final balance = sale.balance;
          final remaining =
              balance - (double.tryParse(_amount.text.trim()) ?? 0);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.buyerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Sale total: ${sale.salePrice.toCurrencyString()}'),
                      Text('Received: ${sale.received.toCurrencyString()}'),
                      Text(
                        'Balance: ${balance.toCurrencyString()}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Amount received *',
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: Icons.payments_outlined,
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    if (amount > balance + 0.009) {
                      return 'Amount cannot exceed the balance';
                    }
                    return null;
                  },
                ),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateUtils.dateOnly(DateTime.now()),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Payment date *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(_date.toFormattedString()),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _mode,
                  decoration: const InputDecoration(
                    labelText: 'Payment mode',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                    DropdownMenuItem(value: 'BANK', child: Text('Bank')),
                    DropdownMenuItem(value: 'ONLINE', child: Text('Online')),
                    DropdownMenuItem(value: 'CHEQUE', child: Text('Cheque')),
                  ],
                  onChanged: (value) => setState(() {
                    _mode = value ?? 'CASH';
                    if (_mode == 'CASH') _bank = null;
                  }),
                ),
                if (_mode != 'CASH') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _bank,
                    decoration: const InputDecoration(
                      labelText: 'Bank *',
                      border: OutlineInputBorder(),
                    ),
                    items: const ['UBL', 'MCB', 'BOP', 'BAHL']
                        .map(
                          (bank) =>
                              DropdownMenuItem(value: bank, child: Text(bank)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _bank = value),
                  ),
                ],
                if (remaining > 0.009) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _promisedDate ?? _date,
                        firstDate: _date,
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (picked != null) {
                        setState(() => _promisedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Promised payment date *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        errorText: _promisedDate == null
                            ? 'Required for a balance'
                            : null,
                      ),
                      child: Text(
                        _promisedDate?.toFormattedString() ?? 'Select date',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(label: 'Note (optional)', controller: _note),
                CustomButton(
                  label: 'Receive payment',
                  isLoading: _saving,
                  onPressed: _saving ? () {} : () => _submit(sale),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
