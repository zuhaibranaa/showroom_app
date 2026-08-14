import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DealerLoginScreen extends ConsumerStatefulWidget {
  const DealerLoginScreen({super.key});

  @override
  ConsumerState<DealerLoginScreen> createState() => _DealerLoginScreenState();
}

class _DealerLoginScreenState extends ConsumerState<DealerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(dealerLoginStateProvider);

    ref.listen(dealerLoginStateProvider, (_, state) {
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dealer login successful')),
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
      appBar: AppBar(title: const Text('Dealer Login')),
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
                'Dealer Portal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Access your sales and commission information',
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
              CustomButton(
                label: 'Login',
                isLoading: loginState.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref.read(dealerLoginStateProvider.notifier).dealerLogin(
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
                  const Text('Not a dealer? '),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Staff Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New dealer? '),
                  GestureDetector(
                    onTap: () => context.push('/dealer-register'),
                    child: const Text(
                      'Register',
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
