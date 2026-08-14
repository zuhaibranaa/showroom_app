import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dealer_profile_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class DealerCommissionScreen extends ConsumerWidget {
  const DealerCommissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentDealerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Commission Details'), elevation: 0),
      body: profile.when(
        data: (dealer) {
          if (dealer == null) {
            return const Center(
              child: Text('No dealer profile found for this account.'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Commission Earned',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dealer.totalCommission.toCurrencyString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Across ${dealer.totalSales} sale(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Commission Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                CustomCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.percent),
                        title: const Text('Commission Rate'),
                        trailing: Text(
                          dealer.commissionPercent != null
                              ? '${dealer.commissionPercent!.toStringAsFixed(2)}%'
                              : 'Not set',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: const Text('Total Sales'),
                        trailing: Text(
                          '${dealer.totalSales}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading commission...'),
        error: (error, _) => ErrorView(message: error.toString()),
      ),
    );
  }
}
