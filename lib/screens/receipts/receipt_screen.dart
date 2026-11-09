import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/agency_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/extensions.dart';

class ReceiptScreen extends ConsumerWidget {
  final String saleId;

  const ReceiptScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleByIdProvider(saleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              if (kIsWeb) {
                // Best-effort browser print on web without extra dependencies.
                // ignore: avoid_web_libraries_in_flutter
                // no-op fallback below
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Use your browser or device print option to print this receipt.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: saleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (sale) {
          final vehicleAsync = ref.watch(
            vehicleByIdOrNullProvider(sale.vehicleId),
          );
          final vehicle = vehicleAsync.valueOrNull;
          final agencyAsync = ref.watch(
            agencyByIdProvider(sale.agencyId),
          );
          final agencyName = agencyAsync.valueOrNull?.name ?? '';
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          agencyName.isNotEmpty
                              ? agencyName.toUpperCase()
                              : 'SHOWROOM',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Center(child: Text('Sale Receipt')),
                      const Divider(height: 32),
                      _row('Receipt no.', sale.receiptNo ?? sale.id),
                      _row('Date', sale.saleDate.toFormattedString()),
                      _row('Reference', sale.referenceNo ?? '—'),
                      const SizedBox(height: 12),
                      _section('Vehicle'),
                      _row(
                        'Make / Model',
                        vehicle == null
                            ? sale.vehicleId
                            : '${vehicle.make} ${vehicle.model} ${vehicle.year}',
                      ),
                      _row('Chassis no.', vehicle?.chassisNo ?? '—'),
                      _row('Engine no.', vehicle?.engineNo ?? '—'),
                      _row('Number plate', sale.numberPlate ?? '—'),
                      const SizedBox(height: 12),
                      _section('Buyer'),
                      _row('Name', sale.buyerName),
                      _row('CNIC', sale.purchaserCNIC ?? '—'),
                      _row('Phone', sale.buyerPhone),
                      _row('Father name', sale.purchaserFatherName ?? '—'),
                      _row('Address', sale.purchaserAddress ?? '—'),
                      const SizedBox(height: 12),
                      _section('Payment'),
                      _row(
                        'Purchase price',
                        sale.purchasePrice.toCurrencyString(),
                      ),
                      _row('Sale price', sale.salePrice.toCurrencyString()),
                      _row('Received', sale.received.toCurrencyString()),
                      _row('Balance', sale.balance.toCurrencyString()),
                      _row('Payment mode', sale.paymentMode ?? '—'),
                      _row('Bank', sale.bank ?? '—'),
                      _row(
                        'Promised date',
                        sale.promisedDate?.toFormattedString() ?? '—',
                      ),
                      const SizedBox(height: 12),
                      _section('Seller / witness'),
                      _row('Witness', sale.witnessName ?? '—'),
                      _row('Witness phone', sale.witnessMobileNo ?? '—'),
                      _row('Biometric', sale.biometricStatus ?? '—'),
                      _row(
                        'Number',
                        sale.soldWithNumber ? 'With number' : 'Without number',
                      ),
                      const SizedBox(height: 24),
                      const Center(child: Text('Thank you for your business')),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
