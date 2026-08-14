import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  String? _selectedAgencyId;
  bool _prefilled = false;
  DateTime? _originalCreatedAt;

  bool get _isEditing => widget.id != null;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _descriptionController.dispose();
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
    _originalCreatedAt = vehicle.createdAt;
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
    );
    if (_isEditing) {
      await ref
          .read(updateVehicleProvider.notifier)
          .updateVehicle(widget.id!, vehicle);
    } else {
      await ref.read(createVehicleProvider.notifier).createVehicle(vehicle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createVehicleProvider);
    final updateState = ref.watch(updateVehicleProvider);
    final agencies = ref.watch(accessibleAgenciesProvider);
    final agencyList = agencies.value;

    if (agencyList != null &&
        agencyList.isNotEmpty &&
        _selectedAgencyId == null &&
        !_prefilled) {
      _selectedAgencyId = agencyList.first.id;
    }

    AsyncValue<VehicleModel>? editingVehicle;
    if (_isEditing) {
      editingVehicle = ref.watch(vehicleByIdProvider(widget.id!));
    }
    final editingData = editingVehicle?.value;
    if (editingData != null && !_prefilled) {
      _prefill(editingData);
    }

    ref.listen(createVehicleProvider, (_, state) {
      if (_isEditing) return;
      state.when(
        data: (id) {
          if (id.isNotEmpty && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle added successfully')),
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
              const SnackBar(content: Text('Vehicle updated successfully')),
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

    if (_isEditing) {
      if (editingVehicle!.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Vehicle'), elevation: 0),
          body: ErrorView(message: editingVehicle.error.toString()),
        );
      }
      if (editingData == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Vehicle'), elevation: 0),
          body: const LoadingWidget(message: 'Loading vehicle...'),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
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
                      'Create an agency before adding vehicles.',
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
                label: 'Make',
                hint: 'e.g. Toyota',
                controller: _makeController,
                prefixIcon: Icons.directions_car,
                validator: (value) => Validators.validateRequired(value, 'Make'),
              ),
              CustomTextField(
                label: 'Model',
                hint: 'e.g. Corolla',
                controller: _modelController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Model'),
              ),
              CustomTextField(
                label: 'Year',
                hint: 'e.g. 2022',
                controller: _yearController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Year is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              CustomTextField(
                label: 'Color',
                hint: 'e.g. Red',
                controller: _colorController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Color'),
              ),
              CustomTextField(
                label: 'License Plate',
                hint: 'e.g. ABC-1234',
                controller: _licensePlateController,
                validator: (value) =>
                    Validators.validateRequired(value, 'License plate'),
              ),
              CustomTextField(
                label: 'VIN',
                hint: 'Vehicle identification number',
                controller: _vinController,
                validator: (value) =>
                    Validators.validateRequired(value, 'VIN'),
              ),
              CustomTextField(
                label: 'Description',
                hint: 'Optional notes about this vehicle',
                controller: _descriptionController,
                maxLines: 3,
                minLines: 3,
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: _isEditing ? 'Save Changes' : 'Add Vehicle',
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
