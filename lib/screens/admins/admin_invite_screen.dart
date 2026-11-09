import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/access_provider.dart';
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
  bool _isAgencyOwner = false;

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

    final user = ref.read(currentUserProvider).value;
    // Agency owner can only invite for their own agencies.
    if (user != null &&
        !AccessService.isSuperAdmin(user) &&
        AccessService.isAgencyOwner(user)) {
      final invalid = _selectedAgencyIds.where((id) => !user.agencyIds.contains(id));
      if (invalid.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agency owners can only invite for their own agencies.'),
          ),
        );
        return;
      }
    }

    await ref.read(createAdminInviteProvider.notifier).createInvite(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          agencyIds: _selectedAgencyIds.toList(),
          isAgencyOwner: _isAgencyOwner,
        );
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createAdminInviteProvider);
    final user = ref.watch(currentUserProvider).value;
    final isSuperAdmin = AccessService.isSuperAdmin(user);
    final isAgencyOwner = AccessService.isAgencyOwner(user);
    final agencies = ref.watch(agenciesProvider);

    // Only super admin or agency owner can access this screen.
    if (user == null || (!isSuperAdmin && !isAgencyOwner)) {
      return const Scaffold(
        body: Center(child: Text('Unauthorized')),
      );
    }

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
                  final filtered = isAgencyOwner
                      ? data.where((a) => user.agencyIds.contains(a.id)).toList()
                      : data;
                  if (filtered.isEmpty) {
                    return const Text('No agencies available.');
                  }
                  return Column(
                    children: filtered.map((agency) {
                      final initialSelected =
                          isAgencyOwner && user.agencyIds.contains(agency.id);
                      return CheckboxListTile(
                        title: Text(agency.name),
                        subtitle: isAgencyOwner
                            ? const Text('Your agency')
                            : null,
                        value: isAgencyOwner ? initialSelected : _selectedAgencyIds.contains(agency.id),
                        onChanged: isAgencyOwner
                            ? null
                            : (checked) {
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
              if (!isAgencyOwner) ...[
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Agency Owner'),
                  subtitle: const Text(
                    'Can invite other agency admins for this agency.',
                  ),
                  value: _isAgencyOwner,
                  onChanged: (checked) {
                    setState(() => _isAgencyOwner = checked == true);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
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
