import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/biometric_provider.dart';
import '../../widgets/custom_card.dart';

class BiometricSettingsScreen extends ConsumerWidget {
  const BiometricSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBioAvailable = ref.watch(isBiometricAvailableProvider);
    final isBioEnabled = ref.watch(isBiometricEnabledProvider);
    final biometricName = ref.watch(biometricNameProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biometric Authentication',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            isBioAvailable.when(
              data: (isAvailable) {
                if (!isAvailable) {
                  return CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text(
                          'Biometric Not Available',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your device does not support biometric authentication.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return isBioEnabled.when(
                  data: (enabled) {
                    return CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              biometricName.when(
                                data: (name) => Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                loading: () => const Text('Loading...'),
                                error: (_, _) =>
                                    const Text('Biometric Authentication'),
                              ),
                              Switch(
                                value: enabled,
                                onChanged: (value) {
                                  if (value) {
                                    _showEnableBiometricDialog(context, ref);
                                  } else {
                                    ref
                                        .read(biometricServiceProvider)
                                        .disableBiometric();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            enabled
                                ? 'Biometric login is enabled for this device'
                                : 'Enable quick login with your fingerprint or face',
                            style:
                                TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => CustomCard(
                    child: Text('Error: $error'),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => CustomCard(
                child: Text('Error: $error'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Security Tips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SecurityTip(
              icon: Icons.fingerprint,
              title: 'Keep Your Biometric Private',
              description:
                  'Your fingerprint and face data are stored securely on your device only.',
            ),
            _SecurityTip(
              icon: Icons.lock,
              title: 'Use Strong Passwords',
              description:
                  'Always use a strong, unique password for your account.',
            ),
            _SecurityTip(
              icon: Icons.phone_android,
              title: 'Device Security',
              description:
                  'Keep your device updated with the latest security patches.',
            ),
          ],
        ),
      ),
    );
  }

  void _showEnableBiometricDialog(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserStreamProvider).value;
    final uid = currentUser?.uid;
    final role = uid == null
        ? 'user'
        : ref.read(userProfileStreamProvider(uid)).value?.role ?? 'user';

    final emailController =
        TextEditingController(text: currentUser?.email ?? '');
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Your credentials will be securely stored on this device.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(biometricServiceProvider).enableBiometric(
                    email: emailController.text,
                    password: passwordController.text,
                    role: role,
                  );
              Navigator.pop(context);
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}

class _SecurityTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
