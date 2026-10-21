import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/dealer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class SaleDetailScreen extends ConsumerStatefulWidget {
  final String saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  Future<void> _deleteSale() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this sale?'),
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

    await ref.read(deleteSaleProvider.notifier).deleteSale(widget.saleId);
    if (!mounted) return;

    final state = ref.read(deleteSaleProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale deleted')),
      );
      context.go('/sales');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sale = ref.watch(saleByIdProvider(widget.saleId));
    final vehicle =
        ref.watch(vehicleByIdOrNullProvider(sale.value?.vehicleId ?? ''));
    final dealer =
        ref.watch(dealerByIdOrNullProvider(sale.value?.dealerId ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/sales/${widget.saleId}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteSale,
          ),
        ],
      ),
      body: sale.when(
        data: (data) {
          final vehicleName = vehicle.value != null
              ? '${vehicle.value!.make} ${vehicle.value!.model}'
              : (data.vehicleId.isEmpty ? 'Unknown' : data.vehicleId);
          final dealerName = dealer.value?.name ??
              (data.dealerId.isEmpty ? 'Unknown' : data.dealerId);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.buyerName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Vehicle', value: vehicleName),
                    _DetailRow(label: 'Dealer', value: dealerName),
                    _DetailRow(label: 'Buyer Email', value: data.buyerEmail),
                    _DetailRow(label: 'Buyer Phone', value: data.buyerPhone),
                    _DetailRow(
                      label: 'Purchase Price',
                      value: data.purchasePrice.toCurrencyString(),
                    ),
                    _DetailRow(
                      label: 'Sale Price',
                      value: data.salePrice.toCurrencyString(),
                    ),
                    _DetailRow(
                      label: 'Profit',
                      value: data.profit.toCurrencyString(),
                    ),
                    _DetailRow(
                      label: 'Sale Date',
                      value: data.saleDate.toFormattedString(),
                    ),
                  ],
                ),
              ),
              if (data.notes != null) ...[
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(data.notes!),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading sale...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onBack: () => context.go('/sales'),
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
            width: 130,
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
