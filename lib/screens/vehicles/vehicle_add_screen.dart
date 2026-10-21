import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/vehicle_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_and_error.dart';

class VehicleAddScreen extends ConsumerStatefulWidget {
  final String? id;

  const VehicleAddScreen({super.key, this.id});

  @override
  ConsumerState<VehicleAddScreen> createState() => _VehicleAddScreenState();
}

class _VehicleAddScreenState extends ConsumerState<VehicleAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vinController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Used Bike only fields
  final _receiptNoController = TextEditingController();
  final _eChallanFineController = TextEditingController();
  final _biometricPhoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _sourceController = TextEditingController();
  final _engineCCController = TextEditingController();
  final _engineNoController = TextEditingController();
  final _chassisNoController = TextEditingController();
  final _plateNoController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _sellerCNICController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _priceAmountController = TextEditingController();

  String? _selectedAgencyId;
  String? _selectedDocumentStatus;
  DateTime? _biometricAvailableDate;
  bool _isZeroMeter = false;

  bool _prefilled = false;
  DateTime? _originalCreatedAt;

  bool get _isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    _isZeroMeter = false;
    final cachedAgencies = ref.read(accessibleAgenciesProvider).value;
    if (cachedAgencies != null && cachedAgencies.isNotEmpty) {
      _selectedAgencyId = cachedAgencies.first.id;
    }
    if (_isEditing) {
      final cachedVehicle = ref.read(vehicleByIdProvider(widget.id!)).value;
      if (cachedVehicle != null) {
        _prefill(cachedVehicle);
      }
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _descriptionController.dispose();
    _receiptNoController.dispose();
    _eChallanFineController.dispose();
    _biometricPhoneController.dispose();
    _companyController.dispose();
    _sourceController.dispose();
    _engineCCController.dispose();
    _engineNoController.dispose();
    _chassisNoController.dispose();
    _plateNoController.dispose();
    _sellerNameController.dispose();
    _sellerCNICController.dispose();
    _sellerPhoneController.dispose();
    _priceAmountController.dispose();
    super.dispose();
  }

  void _prefill(VehicleModel vehicle) {
    _makeController.text = vehicle.make;
    _modelController.text = vehicle.model;
    _yearController.text = '${vehicle.year}';
    _colorController.text = vehicle.color;
    _licensePlateController.text = vehicle.licensePlate;
    _vinController.text = vehicle.vin;
    _descriptionController.text = vehicle.description ?? '';
    _selectedAgencyId = vehicle.agencyId;
    _isZeroMeter = vehicle.isZeroMeter;
    _selectedDocumentStatus = vehicle.documentStatus;
    _sourceController.text = vehicle.source ?? '';
    _companyController.text = vehicle.company ?? '';
    _engineCCController.text = vehicle.engineCC ?? '';
    _engineNoController.text = vehicle.engineNo ?? '';
    _chassisNoController.text = vehicle.chassisNo ?? '';
    _plateNoController.text = vehicle.plateNo ?? '';
    _sellerNameController.text = vehicle.sellerName ?? '';
    _sellerCNICController.text = vehicle.sellerCNIC ?? '';
    _sellerPhoneController.text = vehicle.sellerPhone ?? '';
    _priceAmountController.text = vehicle.priceAmount != null
        ? vehicle.priceAmount!.toString()
        : '';
    _receiptNoController.text = vehicle.receiptNo ?? '';
    _eChallanFineController.text = vehicle.eChallanFine != null
        ? vehicle.eChallanFine!.toString()
        : '';
    _biometricPhoneController.text = vehicle.biometricPhone ?? '';
    _biometricAvailableDate = vehicle.biometricAvailableDate;
    _originalCreatedAt = vehicle.createdAt;
    _prefilled = true;
  }

  Future<void> _pickBiometricDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _biometricAvailableDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _biometricAvailableDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAgencyId == null || _selectedAgencyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an agency')),
      );
      return;
    }

    final now = DateTime.now();
    final vehicle = VehicleModel(
      id: widget.id ?? '',
      agencyId: _selectedAgencyId!,
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      color: _colorController.text.trim(),
      licensePlate: _licensePlateController.text.trim(),
      vin: _vinController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
      receiptNo: _receiptNoController.text.trim().isEmpty
          ? null
          : _receiptNoController.text.trim(),
      eChallanFine:
          _eChallanFineController.text.trim().isNotEmpty
              ? double.tryParse(_eChallanFineController.text.trim())
              : null,
      biometricAvailableDate: _biometricAvailableDate,
      biometricPhone:
          _biometricPhoneController.text.trim().isEmpty
              ? null
              : _biometricPhoneController.text.trim(),
      company: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
      engineCC: _engineCCController.text.trim().isEmpty
          ? null
          : _engineCCController.text.trim(),
      documentStatus: _selectedDocumentStatus?.isEmpty == true
          ? null
          : _selectedDocumentStatus,
      source: _sourceController.text.trim().isEmpty
          ? null
          : _sourceController.text.trim(),
      engineNo: _engineNoController.text.trim().isEmpty
          ? null
          : _engineNoController.text.trim(),
      chassisNo: _chassisNoController.text.trim().isEmpty
          ? null
          : _chassisNoController.text.trim(),
      plateNo: _plateNoController.text.trim().isEmpty
          ? null
          : _plateNoController.text.trim(),
      sellerName: _sellerNameController.text.trim().isEmpty
          ? null
          : _sellerNameController.text.trim(),
      sellerCNIC: _sellerCNICController.text.trim().isEmpty
          ? null
          : _sellerCNICController.text.trim(),
      sellerPhone: _sellerPhoneController.text.trim().isEmpty
          ? null
          : _sellerPhoneController.text.trim(),
      priceAmount:
          _priceAmountController.text.trim().isNotEmpty
              ? double.tryParse(_priceAmountController.text.trim())
              : null,
      isZeroMeter: _isZeroMeter,
    );
    if (_isEditing) {
      await ref
          .read(updateVehicleProvider.notifier)
          .updateVehicle(widget.id!, vehicle);
    } else {
      await ref.read(createVehicleProvider.notifier).createVehicle(vehicle);
    }
  }

  Widget _buildBikeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'Model Year',
          hint: 'e.g. 2026',
          controller: _yearController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Model year is required';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid year';
            }
            return null;
          },
        ),
        CustomTextField(
          label: 'Company',
          hint: 'e.g. Honda',
          controller: _companyController,
          validator: (value) =>
              Validators.validateRequired(value, 'Company'),
        ),
        CustomTextField(
          label: 'Engine CC',
          hint: 'e.g. 70cc',
          controller: _engineCCController,
          validator: (value) =>
              Validators.validateRequired(value, 'Engine CC'),
        ),
        CustomTextField(
          label: 'Color',
          hint: 'e.g. Red',
          controller: _colorController,
          validator: (value) =>
              Validators.validateRequired(value, 'Color'),
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
              setState(() => _selectedDocumentStatus = result);
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
            child: Text(_selectedDocumentStatus ?? 'Select status'),
          ),
        ),
        CustomTextField(
          label: 'Source',
          hint: 'e.g. New Razi traders',
          controller: _sourceController,
          validator: (value) =>
              Validators.validateRequired(value, 'Source'),
        ),
        CustomTextField(
          label: 'Engine No',
          hint: 'e.g. q402782',
          controller: _engineNoController,
          validator: (value) =>
              Validators.validateRequired(value, 'Engine No'),
        ),
        CustomTextField(
          label: 'Chassis No',
          hint: 'e.g. hb944754',
          controller: _chassisNoController,
          validator: (value) =>
              Validators.validateRequired(value, 'Chassis No'),
        ),
        if (!_isZeroMeter) ...[
          CustomTextField(
            label: 'Plate No',
            hint: 'e.g. ABC-1234',
            controller: _plateNoController,
            validator: (value) =>
                Validators.validateRequired(value, 'Plate No'),
          ),
          CustomTextField(
            label: 'Seller Name',
            hint: 'Seller full name',
            controller: _sellerNameController,
            validator: (value) =>
                Validators.validateRequired(value, 'Seller name'),
          ),
          CustomTextField(
            label: 'Seller CNIC',
            hint: 'Seller CNIC',
            controller: _sellerCNICController,
            validator: (value) =>
                Validators.validateRequired(value, 'Seller CNIC'),
          ),
          CustomTextField(
            label: 'Seller Phone',
            hint: 'Seller phone number',
            controller: _sellerPhoneController,
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhone,
          ),
          CustomTextField(
            label: 'Receipt No',
            hint: 'Receipt number',
            controller: _receiptNoController,
          ),
          CustomTextField(
            label: 'E-Challan Fine',
            hint: 'Fine amount',
            controller: _eChallanFineController,
            keyboardType: TextInputType.number,
          ),
          CustomTextField(
            label: 'Biometric Phone (optional)',
            hint: 'Biometric phone',
            controller: _biometricPhoneController,
            keyboardType: TextInputType.phone,
          ),
          InkWell(
            onTap: _pickBiometricDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Biometric Available Date (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(_biometricAvailableDate != null
                  ? DateFormat('MMM d, yyyy').format(_biometricAvailableDate!)
                  : 'Select date'),
            ),
          ),
        ],
        CustomTextField(
          label: 'Price Amount',
          hint: 'Price amount',
          controller: _priceAmountController,
          keyboardType: TextInputType.number,
          validator: (value) =>
              Validators.validateRequired(value, 'Price amount'),
        ),
        CustomTextField(
          label: 'Description',
          hint: 'Optional notes about this vehicle',
          controller: _descriptionController,
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createVehicleProvider);
    final updateState = ref.watch(updateVehicleProvider);
    final agencies = ref.watch(accessibleAgenciesProvider);

    ref.listen(accessibleAgenciesProvider, (_, next) {
      final list = next.value;
      if (list != null &&
          list.isNotEmpty &&
          _selectedAgencyId == null &&
          !_prefilled) {
        setState(() => _selectedAgencyId = list.first.id);
      }
    });

    AsyncValue<VehicleModel>? editingVehicle;
    if (_isEditing) {
      ref.listen(vehicleByIdProvider(widget.id!), (_, next) {
        final data = next.value;
        if (data != null && !_prefilled) {
          setState(() => _prefill(data));
        }
      });
      editingVehicle = ref.watch(vehicleByIdProvider(widget.id!));
    }
    final editingData = editingVehicle?.value;

    ref.listen(createVehicleProvider, (_, state) {
      if (_isEditing) return;
      state.when(
        data: (id) {
          if (id.isNotEmpty && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bike added successfully')),
            );
            context.go('/vehicles');
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

    ref.listen(updateVehicleProvider, (_, state) {
      if (!_isEditing) return;
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bike updated successfully')),
            );
            ref.invalidate(vehicleByIdProvider(widget.id!));
            context.go('/vehicles/${widget.id}');
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

    final title = _isEditing ? 'Edit Bike' : (_isZeroMeter ? 'Add Zero Meter Bike' : 'Add Used Bike');

    if (_isEditing) {
      if (editingVehicle!.hasError) {
        return Scaffold(
          appBar: AppBar(title: Text(title), elevation: 0),
          body: ErrorView(
            message: editingVehicle.error.toString(),
            onBack: () => context.go('/vehicles'),
          ),
        );
      }
      if (editingData == null) {
        return Scaffold(
          appBar: AppBar(title: Text(title), elevation: 0),
          body: const LoadingWidget(message: 'Loading bike...'),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                      'Create an agency before adding bikes.',
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
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please select an agency'
                        : null,
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
              // Bike type selector (only for add mode)
              if (!_isEditing)
                DropdownButtonFormField<String>(
                  initialValue: _isZeroMeter ? 'zero_meter' : 'used',
                  decoration: const InputDecoration(
                    labelText: 'Bike Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'zero_meter',
                      child: Text('Zero Meter Bike'),
                    ),
                    DropdownMenuItem(
                      value: 'used',
                      child: Text('Used Bike'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _isZeroMeter = value == 'zero_meter';
                    });
                  },
                ),
              if (!_isEditing) const SizedBox(height: 16),
              _buildBikeFields(),
              const SizedBox(height: 8),
              CustomButton(
                label: _isEditing ? 'Save Changes' : 'Add Bike',
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
