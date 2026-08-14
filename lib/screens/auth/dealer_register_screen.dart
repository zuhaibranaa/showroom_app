import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DealerRegisterScreen extends ConsumerStatefulWidget {
  const DealerRegisterScreen({super.key});

  @override
  ConsumerState<DealerRegisterScreen> createState() =>
      _DealerRegisterScreenState();
}

class _DealerRegisterScreenState extends ConsumerState<DealerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(dealerRegistrationStateProvider);

    ref.listen(dealerRegistrationStateProvider, (_, state) {
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful')),
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
      appBar: AppBar(title: const Text('Dealer Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.business, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Dealer Registration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your email must match the record added by the showroom',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.validateEmail,
              ),
              CustomTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: Validators.validatePassword,
              ),
              CustomTextField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Register',
                isLoading: registerState.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(dealerRegistrationStateProvider.notifier)
                        .registerDealer(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already registered? '),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
