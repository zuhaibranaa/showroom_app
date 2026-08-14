import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changeState = ref.watch(changePasswordStateProvider);
    final user = ref.watch(currentUserProvider).value;

    ref.listen(changePasswordStateProvider, (_, state) {
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully')),
            );
            context.go('/dealer-dashboard');
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
      appBar: AppBar(title: const Text('Change Password'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You are using a temporary password. '
                  'Please set a new password to continue.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Current Password',
                hint: 'Enter your temporary password',
                controller: _currentPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: Validators.validatePassword,
              ),
              CustomTextField(
                label: 'New Password',
                hint: 'Enter a new password',
                controller: _newPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: Validators.validatePassword,
              ),
              CustomTextField(
                label: 'Confirm New Password',
                hint: 'Confirm your new password',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Change Password',
                isLoading: changeState.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final uid = user?.id;
                    if (uid == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You are not signed in. Please login.'),
                        ),
                      );
                      return;
                    }
                    ref
                        .read(changePasswordStateProvider.notifier)
                        .changePassword(
                          uid: uid,
                          currentPassword: _currentPasswordController.text,
                          newPassword: _newPasswordController.text,
                        );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
