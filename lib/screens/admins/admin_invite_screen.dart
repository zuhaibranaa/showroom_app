import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/agency_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AdminInviteScreen extends ConsumerStatefulWidget {
  const AdminInviteScreen({super.key});

  @override
  ConsumerState<AdminInviteScreen> createState() => _AdminInviteScreenState();
}

class _AdminInviteScreenState extends ConsumerState<AdminInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final Set<String> _selectedAgencyIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAgencyIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one agency')),
      );
      return;
    }

    await ref.read(createAdminInviteProvider.notifier).createInvite(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          agencyIds: _selectedAgencyIds.toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createAdminInviteProvider);
    final agencies = ref.watch(agenciesProvider);

    ref.listen(createAdminInviteProvider, (_, state) {
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invite created. The admin can now register.'),
              ),
            );
            ref.invalidate(adminInvitesProvider);
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admins');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Admin'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admins');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Name',
                hint: 'Admin full name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    Validators.validateRequired(value, 'Name'),
              ),
              CustomTextField(
                label: 'Email',
                hint: 'The email they will register with',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              const Text(
                'Agencies',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              agencies.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Text('Create an agency first.');
                  }
                  return Column(
                    children: data.map((agency) {
                      return CheckboxListTile(
                        title: Text(agency.name),
                        value: _selectedAgencyIds.contains(agency.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedAgencyIds.add(agency.id);
                            } else {
                              _selectedAgencyIds.remove(agency.id);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Error loading agencies: $error'),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Send Invite',
                isLoading: createState.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
