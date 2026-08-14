import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_role.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dealer_profile_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserStreamProvider).value?.uid;
    final profile = uid == null
        ? null
        : ref.watch(userProfileStreamProvider(uid));
    final accessibleAgencies = ref.watch(accessibleAgenciesProvider);
    final currentDealer = ref.watch(currentDealerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body: profile == null
          ? const Center(child: Text('Not signed in'))
          : profile.when(
              data: (user) {
                if (user == null) {
                  return const Center(child: Text('Profile not found'));
                }
                final role = UserRoleExtension.fromString(user.role);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue[100],
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Chip(
                          label: Text(role.displayName),
                          backgroundColor: Colors.blue.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (AccessService.isAdmin(user)) ...[
                        const Text(
                          'My Agencies',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        accessibleAgencies.when(
                          data: (agencies) => agencies.isEmpty
                              ? const Text('No agencies assigned')
                              : Column(
                                  children: agencies
                                      .map(
                                        (a) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: const Icon(Icons.business),
                                          title: Text(a.name),
                                        ),
                                      )
                                      .toList(),
                                ),
                          loading: () => const LinearProgressIndicator(),
                          error: (error, _) => Text('Error: $error'),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (AccessService.isDealer(user))
                        currentDealer.when(
                          data: (dealer) {
                            if (dealer == null) {
                              return const SizedBox.shrink();
                            }
                            return CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dealer Summary',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.shopping_cart),
                                    title: const Text('Total Sales'),
                                    trailing: Text(
                                      '${dealer.totalSales}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.payments),
                                    title: const Text('Commission Earned'),
                                    trailing: Text(
                                      dealer.totalCommission.toCurrencyString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      const SizedBox(height: 16),
                      CustomCard(
                        onTap: () => context.push('/biometric-settings'),
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.fingerprint),
                          title: Text('Security Settings'),
                          subtitle: Text('Biometric login configuration'),
                          trailing: Icon(Icons.chevron_right),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            await ref.read(authServiceProvider).logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'Loading profile...'),
              error: (error, _) => ErrorView(message: error.toString()),
            ),
    );
  }
}
