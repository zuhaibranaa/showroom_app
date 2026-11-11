import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/operations_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vehicle_provider.dart';
import 'pending_payment_screen.dart';
import '../receipts/receipt_screen.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class SaleDetailScreen extends ConsumerWidget {
  final String saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  Future<void> _cancelSale(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel sale'),
        content: const Text(
          'This will remove the sale record and return the vehicle to stock. '
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel sale'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(deleteSaleProvider.notifier).deleteSale(saleId);
    if (!context.mounted) return;
    final state = ref.read(deleteSaleProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sale cancelled')));
      context.go('/sales');
    }
  }

  void _showImageViewer(BuildContext context, List<String> urls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewerPage(imageUrls: urls, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleByIdProvider(saleId));
    final user = ref.watch(currentUserProvider).value;
    final isOwner = user?.role == 'super_admin';
    final paymentsAsync = ref.watch(paymentsForSaleProvider(saleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        elevation: 0,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/sales/$saleId/edit'),
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () => _cancelSale(context, ref),
            ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReceiptScreen(saleId: saleId)),
            ),
          ),
        ],
      ),
      body: saleAsync.when(
        loading: () => const LoadingWidget(message: 'Loading sale...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onBack: () => context.go('/sales'),
        ),
        data: (sale) {
          if (sale == null) {
            return const Center(child: Text('Sale not found'));
          }
          final vehicleAsync = ref.watch(
            vehicleByIdOrNullProvider(sale.vehicleId),
          );
          final vehicle = vehicleAsync.valueOrNull;
          final vehicleName = vehicle == null
              ? (sale.vehicleId.isEmpty ? 'Unknown' : sale.vehicleId)
              : '${vehicle.make} ${vehicle.model} ${vehicle.year}';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.buyerName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Vehicle', value: vehicleName),
                    _DetailRow(
                      label: 'Buyer CNIC',
                      value: sale.purchaserCNIC ?? '—',
                    ),
                    _DetailRow(label: 'Buyer phone', value: sale.buyerPhone),
                    _DetailRow(
                      label: 'Father name',
                      value: sale.purchaserFatherName ?? '—',
                    ),
                    _DetailRow(
                      label: 'Address',
                      value: sale.purchaserAddress ?? '—',
                    ),
                    _DetailRow(
                      label: 'Receipt no.',
                      value: sale.receiptNo ?? '—',
                    ),
                    _DetailRow(
                      label: 'Reference',
                      value: sale.referenceNo ?? '—',
                    ),
                    _DetailRow(
                      label: 'Purchase price',
                      value: sale.purchasePrice.toCurrencyString(),
                    ),
                    _DetailRow(
                      label: 'Sale price',
                      value: sale.salePrice.toCurrencyString(),
                    ),
                    _DetailRow(
                      label: 'Received',
                      value: sale.received.toCurrencyString(),
                    ),
                    _DetailRow(
                      label: 'Balance',
                      value: sale.balance.toCurrencyString(),
                    ),
                    _DetailRow(
                      label: 'Profit',
                      value: sale.profit.toCurrencyString(),
                    ),
                    _DetailRow(
                      label: 'Sale date',
                      value: sale.saleDate.toFormattedString(),
                    ),
                    _DetailRow(
                      label: 'Payment mode',
                      value: sale.paymentMode ?? '—',
                    ),
                    _DetailRow(label: 'Bank', value: sale.bank ?? '—'),
                    _DetailRow(
                      label: 'Promised date',
                      value: sale.promisedDate?.toFormattedString() ?? '—',
                    ),
                    _DetailRow(
                      label: 'Biometric',
                      value: sale.biometricStatus ?? '—',
                    ),
                    if (sale.buyerBiometricLastDate != null)
                      _DetailRow(
                        label: 'Biometric last date',
                        value: sale.buyerBiometricLastDate!.toFormattedString(),
                      ),
                    _DetailRow(
                      label: 'Number',
                      value: sale.soldWithNumber
                          ? 'With number'
                          : 'Without number',
                    ),
                    if (sale.numberPlate != null)
                      _DetailRow(
                        label: 'Number plate',
                        value: sale.numberPlate!,
                      ),
                    _DetailRow(label: 'Remarks', value: sale.remarks ?? '—'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PendingPaymentScreen(saleId: saleId),
                        ),
                      ),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Receive payment'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceiptScreen(saleId: saleId),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Receipt'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    paymentsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Text(e.toString()),
                      data: (payments) {
                        if (payments.isEmpty) {
                          return const Text('No payments recorded');
                        }
                        return Column(
                          children: payments.map((payment) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(payment.amount.toCurrencyString()),
                              subtitle: Text(
                                '${payment.date.toFormattedString()} • ${payment.mode}'
                                '${payment.bank == null ? '' : ' • ${payment.bank}'}'
                                '${payment.cancelled ? ' • CANCELLED' : ''}',
                              ),
                              trailing: payment.cancelled
                                  ? null
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.edit_calendar_outlined,
                                      ),
                                      onPressed: () async {
                                        final newDate = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              payment.promisedDate ??
                                              DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 3650),
                                          ),
                                        );
                                        if (newDate == null) return;
                                        await ref
                                            .read(operationsServiceProvider)
                                            .cancelPayment(
                                              payment,
                                              'Date changed',
                                              newDate,
                                            );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Payment updated'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (sale.notes != null) ...[
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
                      Text(sale.notes!),
                    ],
                  ),
                ),
              ],
              if (sale.imageUrls != null && sale.imageUrls!.isNotEmpty) ...[
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Images',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: sale.imageUrls!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 120,
                              child: GestureDetector(
                                onTap: () => _showImageViewer(
                                  context, sale.imageUrls!, index,
                                ),
                                child: Image.network(
                                  sale.imageUrls![index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ImageViewerPage({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${initialIndex + 1} of ${imageUrls.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.white70, size: 80);
                },
              ),
            ),
          );
        },
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
            width: 150,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
