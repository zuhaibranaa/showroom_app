import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/operations_models.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/operations_provider.dart';
import 'option_merge.dart';

class RetailPricesScreen extends ConsumerWidget {
  const RetailPricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final pricesAsync = ref.watch(retailPricesProvider);
    final options = ref.watch(appOptionsProvider).valueOrNull ?? const <AppOptionModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Retail Prices')),
      floatingActionButton: AccessService.isSuperAdmin(user)
          ? FloatingActionButton.extended(
              onPressed: () => _showEditor(context, ref, options),
              icon: const Icon(Icons.add),
              label: const Text('Add price'),
            )
          : null,
      body: userAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !AccessService.isSuperAdmin(user)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Only the owner can manage retail prices.'),
                  ),
                )
              : pricesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Could not load retail prices: $error'),
                    ),
                  ),
                  data: (prices) {
                    final sorted = prices.toList()
                      ..sort((a, b) {
                        final make = a.make.compareTo(b.make);
                        return make != 0 ? make : a.model.compareTo(b.model);
                      });
                    if (sorted.isEmpty) {
                      return const Center(
                        child: Text('No retail prices yet. Add the first one.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final price = sorted[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.sell_outlined),
                            ),
                            title: Text('${price.make} ${price.model}'),
                            subtitle: Text(
                              'Updated ${DateFormat('dd MMM yyyy, h:mm a').format(price.updatedAt)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  NumberFormat('#,##0.00').format(price.price),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () => _showEditor(
                                      context, ref, options, price),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: () =>
                                      _confirmDelete(context, ref, price),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref,
    List<AppOptionModel> storedOptions, [
    RetailPriceModel? existing,
  ]) async {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController(
        text: existing == null ? '' : existing.price.toStringAsFixed(2));
    var make = existing?.make ?? '';
    var model = existing?.model ?? '';
    var saving = false;
    String? error;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final makes = optionNames(storedOptions, 'make');
          if (make.isNotEmpty && !makes.contains(make)) makes.add(make);
          final models = make.isEmpty
              ? <String>[]
              : optionNames(storedOptions, 'model', make: make);
          if (model.isNotEmpty && !models.contains(model)) models.add(model);
          return AlertDialog(
            title: Text(existing == null ? 'Add retail price' : 'Edit retail price'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: make.isEmpty ? null : make,
                      decoration: const InputDecoration(
                        labelText: 'Make',
                        border: OutlineInputBorder(),
                      ),
                      items: makes
                          .map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Select a make'
                          : null,
                      onChanged: saving
                          ? null
                          : (value) => setDialogState(() {
                                make = value ?? '';
                                model = '';
                              }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(make),
                      initialValue: model.isEmpty ? null : model,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                      ),
                      items: models
                          .map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Select a model'
                          : null,
                      onChanged: saving
                          ? null
                          : (value) => model = value ?? '',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      enabled: !saving,
                      autofocus: existing == null,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Retail price',
                        prefixText: 'Rs ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final price = double.tryParse(value?.trim() ?? '');
                        if (price == null || !price.isFinite || price <= 0) {
                          return 'Enter a valid price greater than zero';
                        }
                        return null;
                      },
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final all = ref.read(retailPricesProvider).valueOrNull ??
                            const <RetailPriceModel>[];
                        final duplicate = all.any((item) =>
                            item.id != existing?.id &&
                            item.make.trim().toLowerCase() ==
                                make.trim().toLowerCase() &&
                            item.model.trim().toLowerCase() ==
                                model.trim().toLowerCase());
                        if (duplicate) {
                          setDialogState(() =>
                              error = 'A price for this make and model already exists.');
                          return;
                        }
                        setDialogState(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          await ref.read(operationsServiceProvider).saveRetailPrice(
                                RetailPriceModel(
                                  id: existing?.id ?? '',
                                  make: make,
                                  model: model,
                                  price: double.parse(priceController.text.trim()),
                                  updatedAt: DateTime.now(),
                                ),
                                id: existing?.id,
                          );
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                        } catch (exception) {
                          setDialogState(() {
                            saving = false;
                            error = 'Could not save: $exception';
                          });
                        }
                      },
                child: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    priceController.dispose();
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, RetailPriceModel price) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete retail price?'),
        content: Text('Remove ${price.make} ${price.model}?'),
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
      await ref.read(operationsServiceProvider).deleteRetailPrice(price.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Retail price deleted')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not delete: $error')));
      }
    }
  }
}
