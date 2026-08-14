import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dealer_profile_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class DealerDashboardScreen extends ConsumerWidget {
  const DealerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentDealerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Portal'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: profile.when(
        data: (value) {
          if (value == null) {
            return const Center(
              child: Text('No dealer profile found for this account.'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${value.name}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Sales Dashboard',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _OverviewStat(
                            label: 'Total Sales',
                            value: '${value.totalSales}',
                          ),
                          _OverviewStat(
                            label: 'Commission Earned',
                            value: value.totalCommission.toCurrencyString(),
                          ),
                        ],
                      ),
                      if (value.commissionPercent != null) ...[
                        const SizedBox(height: 16),
                        _OverviewStat(
                          label: 'Commission Rate',
                          value:
                              '${value.commissionPercent!.toStringAsFixed(2)}%',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (AccessService.dealerCanView(value, 'sales')) ...[
                  _ActionButton(
                    label: 'My Sales',
                    icon: Icons.shopping_cart,
                    onTap: () => context.push('/dealer-sales'),
                  ),
                  const SizedBox(height: 12),
                ],
                if (AccessService.dealerCanView(value, 'vehicles')) ...[
                  _ActionButton(
                    label: 'Vehicles',
                    icon: Icons.directions_car,
                    onTap: () => context.push('/dealer-vehicles'),
                  ),
                  const SizedBox(height: 12),
                ],
                _ActionButton(
                  label: 'Commission Details',
                  icon: Icons.payments,
                  onTap: () => context.push('/dealer-commission'),
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

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
