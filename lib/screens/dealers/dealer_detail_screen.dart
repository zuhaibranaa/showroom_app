import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/agency_provider.dart';
import '../../providers/dealer_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class DealerDetailScreen extends ConsumerStatefulWidget {
  final String dealerId;

  const DealerDetailScreen({super.key, required this.dealerId});

  @override
  ConsumerState<DealerDetailScreen> createState() =>
      _DealerDetailScreenState();
}

class _DealerDetailScreenState extends ConsumerState<DealerDetailScreen> {
  Future<void> _deleteDealer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dealer'),
        content: const Text('Are you sure you want to delete this dealer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(deleteDealerProvider.notifier).deleteDealer(widget.dealerId);
    if (!mounted) return;

    final state = ref.read(deleteDealerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dealer deleted')),
      );
      context.go('/dealers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dealer = ref.watch(dealerByIdProvider(widget.dealerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined),
            tooltip: 'Permissions',
            onPressed: () => context.push('/dealers/${widget.dealerId}/permissions'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/dealers/${widget.dealerId}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteDealer,
          ),
        ],
      ),
      body: dealer.when(
        data: (data) {
          final agency = ref.watch(agencyByIdProvider(data.agencyId));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Agency',
                      value: agency.hasValue ? agency.value!.name : data.agencyId,
                    ),
                    _DetailRow(label: 'Email', value: data.email),
                    _DetailRow(label: 'Phone', value: data.phone),
                    _DetailRow(label: 'Address', value: data.address),
                    _DetailRow(label: 'City', value: data.city),
                    if (data.licenseNumber != null)
                      _DetailRow(label: 'License', value: data.licenseNumber!),
                    if (data.commissionPercent != null)
                      _DetailRow(
                        label: 'Commission',
                        value:
                            '${data.commissionPercent!.toStringAsFixed(2)}%',
                      ),
                    const SizedBox(height: 12),
                    const Divider(),
                    _DetailRow(
                      label: 'Total Sales',
                      value: '${data.totalSales}',
                    ),
                    _DetailRow(
                      label: 'Total Commission',
                      value: data.totalCommission.toStringAsFixed(2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading dealer...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onBack: () => context.go('/dealers'),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
