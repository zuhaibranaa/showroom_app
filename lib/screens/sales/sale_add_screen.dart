import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/sale_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/dealer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_and_error.dart';

class SaleAddScreen extends ConsumerStatefulWidget {
  final String? id;

  const SaleAddScreen({super.key, this.id});

  @override
  ConsumerState<SaleAddScreen> createState() => _SaleAddScreenState();
}

class _SaleAddScreenState extends ConsumerState<SaleAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buyerNameController = TextEditingController();
  final _buyerEmailController = TextEditingController();
  final _buyerPhoneController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedAgencyId;
  String? _selectedVehicleId;
  String? _selectedDealerId;
  DateTime _saleDate = DateTime.now();

  bool _prefilled = false;
  DateTime? _originalCreatedAt;

  bool get _isEditing => widget.id != null;

  @override
  void dispose() {
    _buyerNameController.dispose();
    _buyerEmailController.dispose();
    _buyerPhoneController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefill(SaleModel sale) {
    _buyerNameController.text = sale.buyerName;
    _buyerEmailController.text = sale.buyerEmail;
    _buyerPhoneController.text = sale.buyerPhone;
    _purchasePriceController.text = sale.purchasePrice.toString();
    _salePriceController.text = sale.salePrice.toString();
    _notesController.text = sale.notes ?? '';
    _selectedAgencyId = sale.agencyId;
    _selectedVehicleId = sale.vehicleId;
    _selectedDealerId = sale.dealerId;
    _saleDate = sale.saleDate;
    _originalCreatedAt = sale.createdAt;
    _prefilled = true;
  }

  Future<void> _pickSaleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _saleDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAgencyId == null ||
        _selectedVehicleId == null ||
        _selectedDealerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an agency, a vehicle and a dealer'),
        ),
      );
      return;
    }

    final purchasePrice = double.parse(_purchasePriceController.text.trim());
    final salePrice = double.parse(_salePriceController.text.trim());
    if (salePrice < purchasePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale price cannot be less than purchase price'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final sale = SaleModel(
      id: widget.id ?? '',
      agencyId: _selectedAgencyId!,
      vehicleId: _selectedVehicleId!,
      dealerId: _selectedDealerId!,
      buyerName: _buyerNameController.text.trim(),
      buyerEmail: _buyerEmailController.text.trim(),
      buyerPhone: _buyerPhoneController.text.trim(),
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      saleDate: _saleDate,
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );
    if (_isEditing) {
      await ref.read(updateSaleProvider.notifier).updateSale(widget.id!, sale);
    } else {
      await ref.read(createSaleProvider.notifier).createSale(sale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createSaleProvider);
    final updateState = ref.watch(updateSaleProvider);
    final agencies = ref.watch(accessibleAgenciesProvider);
    final agencyList = agencies.value;

    if (agencyList != null &&
        agencyList.isNotEmpty &&
        _selectedAgencyId == null &&
        !_prefilled) {
      _selectedAgencyId = agencyList.first.id;
    }

    final selectedAgencyId = _selectedAgencyId;
    final vehicles = selectedAgencyId == null
        ? ref.watch(vehiclesProvider)
        : ref.watch(vehiclesByAgencyProvider(selectedAgencyId));
    final dealers = selectedAgencyId == null
        ? ref.watch(dealersProvider)
        : ref.watch(dealersByAgencyProvider(selectedAgencyId));

    AsyncValue<SaleModel>? editingSale;
    if (_isEditing) {
      editingSale = ref.watch(saleByIdProvider(widget.id!));
    }
    final editingData = editingSale?.value;
    if (editingData != null && !_prefilled) {
      _prefill(editingData);
    }

    ref.listen(createSaleProvider, (_, state) {
      if (_isEditing) return;
      state.when(
        data: (id) {
          if (id.isNotEmpty && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sale recorded successfully')),
            );
            context.go('/sales');
          }
        },
        error: (error, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          }
        },
        loading: () {},
      );
    });

    ref.listen(updateSaleProvider, (_, state) {
      if (!_isEditing) return;
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sale updated successfully')),
            );
            ref.invalidate(saleByIdProvider(widget.id!));
            context.go('/sales/${widget.id}');
          }
        },
        error: (error, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          }
        },
        loading: () {},
      );
    });

    if (_isEditing) {
      if (editingSale!.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Sale'), elevation: 0),
          body: ErrorView(message: editingSale.error.toString()),
        );
      }
      if (editingData == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Sale'), elevation: 0),
          body: const LoadingWidget(message: 'Loading sale...'),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Sale' : 'Record Sale'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Buyer Name',
                hint: 'Full name of the buyer',
                controller: _buyerNameController,
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    Validators.validateRequired(value, 'Buyer name'),
              ),
              CustomTextField(
                label: 'Buyer Email',
                hint: 'Buyer email address',
                controller: _buyerEmailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.validateEmail,
              ),
              CustomTextField(
                label: 'Buyer Phone',
                hint: 'Buyer phone number',
                controller: _buyerPhoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: Validators.validatePhone,
              ),
              agencies.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Text(
                      'Create an agency before recording sales.',
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAgencyId,
                    decoration: const InputDecoration(
                      labelText: 'Agency',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    items: data
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAgencyId = value;
                        _selectedVehicleId = null;
                        _selectedDealerId = null;
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Error loading agencies: $error'),
              ),
              const SizedBox(height: 16),
              vehicles.when(
                data: (vehicleList) => DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleId,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle',
                    border: OutlineInputBorder(),
                  ),
                  items: vehicleList
                      .map(
                        (v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(
                            '${v.make} ${v.model} (${v.year})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleId = value;
                    });
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Error loading vehicles: $error'),
              ),
              const SizedBox(height: 16),
              dealers.when(
                data: (dealerList) => DropdownButtonFormField<String>(
                  initialValue: _selectedDealerId,
                  decoration: const InputDecoration(
                    labelText: 'Dealer',
                    border: OutlineInputBorder(),
                  ),
                  items: dealerList
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(d.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDealerId = value;
                    });
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Error loading dealers: $error'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Purchase Price',
                hint: 'Amount the showroom paid',
                controller: _purchasePriceController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
                validator: Validators.validateNumber,
              ),
              CustomTextField(
                label: 'Sale Price',
                hint: 'Amount the buyer paid',
                controller: _salePriceController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
                validator: Validators.validateNumber,
              ),
              InkWell(
                onTap: _pickSaleDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Sale Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_saleDate.toFormattedString()),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Notes',
                hint: 'Optional notes about this sale',
                controller: _notesController,
                maxLines: 3,
                minLines: 3,
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: _isEditing ? 'Save Changes' : 'Record Sale',
                isLoading:
                    _isEditing ? updateState.isLoading : createState.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
