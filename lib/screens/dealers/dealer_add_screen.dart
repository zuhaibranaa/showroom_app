import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/dealer_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/dealer_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_and_error.dart';

class DealerAddScreen extends ConsumerStatefulWidget {
  final String? id;

  const DealerAddScreen({super.key, this.id});

  @override
  ConsumerState<DealerAddScreen> createState() => _DealerAddScreenState();
}

class _DealerAddScreenState extends ConsumerState<DealerAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _licenseController = TextEditingController();
  final _commissionController = TextEditingController();
  final _tempPasswordController = TextEditingController();

  String? _selectedAgencyId;
  bool _prefilled = false;
  DateTime? _originalCreatedAt;

  bool get _isEditing => widget.id != null;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _licenseController.dispose();
    _commissionController.dispose();
    _tempPasswordController.dispose();
    super.dispose();
  }

  void _prefill(DealerModel dealer) {
    _nameController.text = dealer.name;
    _emailController.text = dealer.email;
    _phoneController.text = dealer.phone;
    _addressController.text = dealer.address;
    _cityController.text = dealer.city;
    _licenseController.text = dealer.licenseNumber ?? '';
    _commissionController.text =
        dealer.commissionPercent?.toString() ?? '';
    _selectedAgencyId = dealer.agencyId;
    _originalCreatedAt = dealer.createdAt;
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAgencyId == null || _selectedAgencyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an agency')),
      );
      return;
    }

    final commissionText = _commissionController.text.trim();
    final now = DateTime.now();
    final dealer = DealerModel(
      id: widget.id ?? '',
      agencyId: _selectedAgencyId!,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      licenseNumber: _licenseController.text.trim().isEmpty
          ? null
          : _licenseController.text.trim(),
      commissionPercent: commissionText.isEmpty
          ? null
          : double.parse(commissionText),
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );
    if (_isEditing) {
      await ref.read(updateDealerProvider.notifier).updateDealer(widget.id!, dealer);
    } else {
      await ref.read(createDealerProvider.notifier).createDealer(
            dealer,
            tempPassword: _tempPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createDealerProvider);
    final updateState = ref.watch(updateDealerProvider);
    final agencies = ref.watch(accessibleAgenciesProvider);
    final agencyList = agencies.value;

    if (agencyList != null &&
        agencyList.isNotEmpty &&
        _selectedAgencyId == null &&
        !_prefilled) {
      _selectedAgencyId = agencyList.first.id;
    }

    AsyncValue<DealerModel>? editingDealer;
    if (_isEditing) {
      editingDealer = ref.watch(dealerByIdProvider(widget.id!));
    }
    final editingData = editingDealer?.value;
    if (editingData != null && !_prefilled) {
      _prefill(editingData);
    }

    ref.listen(createDealerProvider, (_, state) {
      if (_isEditing) return;
      state.when(
        data: (id) {
          if (id.isNotEmpty && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dealer added successfully')),
            );
            context.go('/dealers');
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

    ref.listen(updateDealerProvider, (_, state) {
      if (!_isEditing) return;
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dealer updated successfully')),
            );
            ref.invalidate(dealerByIdProvider(widget.id!));
            context.go('/dealers/${widget.id}');
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
      if (editingDealer!.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Dealer'), elevation: 0),
          body: ErrorView(message: editingDealer.error.toString()),
        );
      }
      if (editingData == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Dealer'), elevation: 0),
          body: const LoadingWidget(message: 'Loading dealer...'),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Dealer' : 'Add Dealer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              agencies.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Text(
                      'Create an agency before adding dealers.',
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
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Error loading agencies: $error'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Name',
                hint: 'Dealer name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    Validators.validateRequired(value, 'Name'),
              ),
              CustomTextField(
                label: 'Email',
                hint: 'Dealer email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.validateEmail,
              ),
              CustomTextField(
                label: 'Phone',
                hint: 'Dealer phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: Validators.validatePhone,
              ),
              CustomTextField(
                label: 'Address',
                hint: 'Street address',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                validator: (value) =>
                    Validators.validateRequired(value, 'Address'),
              ),
              CustomTextField(
                label: 'City',
                hint: 'City',
                controller: _cityController,
                prefixIcon: Icons.location_city,
                validator: (value) =>
                    Validators.validateRequired(value, 'City'),
              ),
              CustomTextField(
                label: 'License Number',
                hint: 'Optional dealer license number',
                controller: _licenseController,
              ),
              CustomTextField(
                label: 'Commission Percent',
                hint: 'e.g. 5 for 5%',
                controller: _commissionController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 8),
                CustomTextField(
                  label: 'Temporary Password',
                  hint: 'Dealer will use this to log in first time',
                  controller: _tempPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.validatePassword,
                ),
              ],
              const SizedBox(height: 8),
              CustomButton(
                label: _isEditing ? 'Save Changes' : 'Add Dealer',
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
