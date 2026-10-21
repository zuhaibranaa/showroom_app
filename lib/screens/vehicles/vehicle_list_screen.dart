import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/vehicle_model.dart';
import '../../providers/access_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_and_error.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(accessibleVehiclesProvider);
    final searchQuery = ref.watch(_searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Bikes'),
        elevation: 0,
      ),
      body: vehiclesAsync.when(
        data: (data) {
          final query = searchQuery.toLowerCase();
          final filtered = data.where((v) {
            return (v.chassisNo ?? '').toLowerCase().contains(query) ||
                (v.engineNo ?? '').toLowerCase().contains(query) ||
                (v.plateNo ?? '').toLowerCase().contains(query) ||
                v.make.toLowerCase().contains(query) ||
                v.model.toLowerCase().contains(query);
          }).toList();

          if (filtered.isEmpty) {
            return const Center(
              child: Text('No bikes found'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(accessibleVehiclesProvider.future),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomTextField(
                    label: 'Search by chassis, engine, or plate no',
                    hint: 'Search bikes...',
                    onChanged: (value) {
                      ref.read(_searchQueryProvider.notifier).state = value;
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final vehicle = filtered[index];
                      return CustomCard(
                        onTap: () => context.push('/vehicles/${vehicle.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${vehicle.make} ${vehicle.model}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Year: ${vehicle.year}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      context.push('/vehicles/${vehicle.id}/edit'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.tag, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text('VIN: ${vehicle.vin}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.directions_car,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text('License: ${vehicle.licensePlate}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showSellBikeDialog(context, vehicle, ref),
                                  icon: const Icon(
                                    Icons.attach_money,
                                    size: 18,
                                  ),
                                  label: const Text('Sell Bike'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading bikes...'),
        error: (error, stackTrace) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(accessibleVehiclesProvider),
        ),
      ),
    );
  }

  void _showSellBikeDialog(
      BuildContext context, VehicleModel vehicle, WidgetRef ref) {
    final receiptNoController = TextEditingController();
    final purchaserNameController = TextEditingController();
    final cnicController = TextEditingController();
    final phoneController = TextEditingController();
    final soldPriceController = TextEditingController();
    final pendingAmountController = TextEditingController();
    final descriptionController = TextEditingController();
    String? documentStatus;
    DateTime? pendingDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Sell ${vehicle.make} ${vehicle.year}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Receipt#',
                    hint: 'Receipt number',
                    controller: receiptNoController,
                  ),
                  CustomTextField(
                    label: 'Purchaser Name',
                    hint: 'Purchaser full name',
                    controller: purchaserNameController,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Purchaser name'),
                  ),
                  CustomTextField(
                    label: 'CNIC',
                    hint: 'Purchaser CNIC',
                    controller: cnicController,
                    validator: (value) =>
                        Validators.validateRequired(value, 'CNIC'),
                  ),
                  CustomTextField(
                    label: 'Phone Number',
                    hint: 'Purchaser phone',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  InkWell(
                    onTap: () async {
                      final result = await showDialog<String?>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Document Status'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              'Applied', 'Pending', 'Approved', 'Rejected'
                            ].map((status) {
                              return ListTile(
                                title: Text(status),
                                onTap: () => Navigator.pop(context, status),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                      if (result != null) {
                        setDialogState(() => documentStatus = result);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Document Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(documentStatus ?? 'Select status'),
                    ),
                  ),
                  CustomTextField(
                    label: 'Sold Price',
                    hint: 'Sold price',
                    controller: soldPriceController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Sold price'),
                  ),
                  CustomTextField(
                    label: 'Pending Amount',
                    hint: 'Pending amount',
                    controller: pendingAmountController,
                    keyboardType: TextInputType.number,
                  ),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: pendingDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => pendingDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Pending Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        pendingDate != null
                            ? DateFormat('MMM d, yyyy').format(pendingDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                  CustomTextField(
                    label: 'Description',
                    hint: 'Optional description',
                    controller: descriptionController,
                    maxLines: 2,
                    minLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bike sold successfully')),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}

final _searchQueryProvider = StateProvider<String>((ref) => '');
