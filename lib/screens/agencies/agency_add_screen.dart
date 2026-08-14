import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/agency_model.dart';
import '../../providers/agency_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_and_error.dart';

class AgencyAddScreen extends ConsumerStatefulWidget {
  final String? id;

  const AgencyAddScreen({super.key, this.id});

  @override
  ConsumerState<AgencyAddScreen> createState() => _AgencyAddScreenState();
}

class _AgencyAddScreenState extends ConsumerState<AgencyAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _prefilled = false;
  DateTime? _originalCreatedAt;

  bool get _isEditing => widget.id != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _prefill(AgencyModel agency) {
    _nameController.text = agency.name;
    _originalCreatedAt = agency.createdAt;
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final agency = AgencyModel(
      id: widget.id ?? '',
      name: _nameController.text.trim(),
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );
    if (_isEditing) {
      await ref.read(updateAgencyProvider.notifier).updateAgency(widget.id!, agency);
    } else {
      await ref.read(createAgencyProvider.notifier).createAgency(agency);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createAgencyProvider);
    final updateState = ref.watch(updateAgencyProvider);

    AsyncValue<AgencyModel>? editingAgency;
    if (_isEditing) {
      editingAgency = ref.watch(agencyByIdProvider(widget.id!));
    }
    final editingData = editingAgency?.value;
    if (editingData != null && !_prefilled) {
      _prefill(editingData);
    }

    ref.listen(createAgencyProvider, (_, state) {
      if (_isEditing) return;
      state.when(
        data: (id) {
          if (id.isNotEmpty && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const               SnackBar(content: Text('Agency added successfully')),
            );
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/agencies');
            }
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

    ref.listen(updateAgencyProvider, (_, state) {
      if (!_isEditing) return;
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Agency updated successfully')),
            );
            ref.invalidate(agencyByIdProvider(widget.id!));
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/agencies');
            }
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
      if (editingAgency!.hasError) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Agency'),
            elevation: 0,
            leading: const _BackToAgencies(),
          ),
          body: ErrorView(message: editingAgency.error.toString()),
        );
      }
      if (editingData == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Agency'),
            elevation: 0,
            leading: const _BackToAgencies(),
          ),
          body: const LoadingWidget(message: 'Loading agency...'),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Agency' : 'Add Agency'),
        elevation: 0,
        leading: const _BackToAgencies(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Agency Name',
                hint: 'e.g. Downtown Showroom',
                controller: _nameController,
                prefixIcon: Icons.business_outlined,
                validator: (value) =>
                    Validators.validateRequired(value, 'Agency name'),
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: _isEditing ? 'Save Changes' : 'Add Agency',
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

class _BackToAgencies extends ConsumerWidget {
  const _BackToAgencies();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/agencies');
        }
      },
    );
  }
}
