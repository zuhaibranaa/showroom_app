import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/access_provider.dart';
import '../../providers/dealer_profile_provider.dart';
import '../../providers/sale_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class DealerSalesScreen extends ConsumerWidget {
  const DealerSalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentDealerProfileProvider);
    final dealer = profile.value;
    final sales = dealer == null
        ? null
        : ref.watch(salesForDealerProvider(dealer.id));

    return Scaffold(
      appBar: AppBar(title: const Text('My Sales'), elevation: 0),
      body: profile.isLoading
          ? const LoadingWidget(message: 'Loading profile...')
          : dealer == null
              ? const Center(
                  child: Text('No dealer profile found for this account.'),
                )
              : !AccessService.dealerCanView(dealer, 'sales')
                  ? const Center(
                      child: Text('You do not have permission to view sales.'),
                    )
                  : sales == null
                  ? const LoadingWidget(message: 'Loading sales...')
                  : sales.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return const Center(child: Text('No sales yet'));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final sale = data[index];
                            return CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sale.buyerName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Vehicle ID: ${sale.vehicleId}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            sale.salePrice.toCurrencyString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Profit: ${sale.profit.toCurrencyString()}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(sale.saleDate.toFormattedString()),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const LoadingWidget(message: 'Loading sales...'),
                      error: (error, _) => ErrorView(message: error.toString()),
                    ),
    );
  }
}
