import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/access_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class DealerListScreen extends ConsumerWidget {
  const DealerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealers = ref.watch(accessibleDealersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealers'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dealers/add'),
        child: const Icon(Icons.add),
      ),
      body: dealers.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Text('No dealers found'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(accessibleDealersProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final dealer = data[index];
                return CustomCard(
                  onTap: () => context.push('/dealers/${dealer.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dealer.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dealer.city,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(dealer.email),
                            backgroundColor: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(dealer.email),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(dealer.phone),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(child: Text(dealer.address)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading dealers...'),
        error: (error, stackTrace) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(accessibleDealersProvider),
        ),
      ),
    );
  }
}
