import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/sale_model.dart';
import '../../models/vehicle_model.dart';
import '../../providers/access_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

enum _SaleListFilter { all, pending, paid, withNumber, withoutNumber }

class SalesListScreen extends ConsumerStatefulWidget {
  const SalesListScreen({super.key});

  @override
  ConsumerState<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends ConsumerState<SalesListScreen> {
  final _searchController = TextEditingController();
  _SaleListFilter _filter = _SaleListFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SaleModel> _applyFilters(
    List<SaleModel> sales,
    Map<String, VehicleModel> vehiclesById,
  ) {
    final query = _query.trim().toLowerCase();
    return sales.where((sale) {
      switch (_filter) {
        case _SaleListFilter.pending:
          if (!sale.hasBalance) return false;
          break;
        case _SaleListFilter.paid:
          if (sale.hasBalance) return false;
          break;
        case _SaleListFilter.withNumber:
          if (!sale.soldWithNumber) return false;
          break;
        case _SaleListFilter.withoutNumber:
          if (sale.soldWithNumber) return false;
          break;
        case _SaleListFilter.all:
          break;
      }
      if (query.isEmpty) return true;
      final vehicle = vehiclesById[sale.vehicleId];
      final haystack = [
        sale.buyerName,
        sale.purchaserCNIC ?? '',
        sale.buyerPhone,
        sale.receiptNo ?? '',
        sale.referenceNo ?? '',
        sale.numberPlate ?? '',
        vehicle?.make ?? '',
        vehicle?.model ?? '',
        vehicle?.chassisNo ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList()..sort((a, b) => b.saleDate.compareTo(a.saleDate));
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(accessibleSalesProvider);
    final vehiclesAsync = ref.watch(accessibleVehiclesProvider);
    final vehiclesById = <String, VehicleModel>{
      for (final vehicle in vehiclesAsync.valueOrNull ?? const <VehicleModel>[])
        vehicle.id: vehicle,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Sales'), elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/sales/add'),
        child: const Icon(Icons.add),
      ),
      body: salesAsync.when(
        loading: () => const LoadingWidget(message: 'Loading sales...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(accessibleSalesProvider),
        ),
        data: (sales) {
          final filtered = _applyFilters(sales, vehiclesById);
          final totalSale = filtered.fold<double>(0, (s, e) => s + e.salePrice);
          final totalReceived = filtered.fold<double>(
            0,
            (s, e) => s + e.received,
          );
          final totalBalance = filtered.fold<double>(
            0,
            (s, e) => s + e.balance,
          );
          final totalProfit = filtered.fold<double>(0, (s, e) => s + e.profit);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search buyer, CNIC, vehicle, receipt...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip('All', _SaleListFilter.all),
                    _filterChip('Pending payment', _SaleListFilter.pending),
                    _filterChip('Paid', _SaleListFilter.paid),
                    _filterChip('With number', _SaleListFilter.withNumber),
                    _filterChip(
                      'Without number',
                      _SaleListFilter.withoutNumber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomCard(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _summaryItem('Sales', '${filtered.length}'),
                      _summaryItem('Sale total', totalSale.toCurrencyString()),
                      _summaryItem(
                        'Received',
                        totalReceived.toCurrencyString(),
                      ),
                      _summaryItem('Balance', totalBalance.toCurrencyString()),
                      _summaryItem('Profit', totalProfit.toCurrencyString()),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No sales found'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(accessibleSalesProvider);
                          await Future<void>.delayed(
                            const Duration(milliseconds: 300),
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final sale = filtered[index];
                            final vehicle = vehiclesById[sale.vehicleId];
                            final vehicleName = vehicle == null
                                ? 'Vehicle ${sale.vehicleId}'
                                : '${vehicle.make} ${vehicle.model} ${vehicle.year}';
                            return CustomCard(
                              onTap: () => context.push('/sales/${sale.id}'),
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
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              vehicleName,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
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
                                            sale.hasBalance
                                                ? 'Balance ${sale.balance.toCurrencyString()}'
                                                : 'Paid',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: sale.hasBalance
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      _statusChip(
                                        sale.soldWithNumber
                                            ? 'With number'
                                            : 'Without number',
                                        sale.soldWithNumber
                                            ? Colors.blue
                                            : Colors.orange,
                                      ),
                                      _statusChip(
                                        sale.biometricStatus ?? 'NOT_REQUIRED',
                                        sale.biometricStatus == 'PENDING'
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      if (sale.receiptNo != null)
                                        _statusChip(
                                          'Receipt ${sale.receiptNo}',
                                          Colors.teal,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.badge_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          sale.purchaserCNIC ?? '—',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(sale.saleDate.toFormattedString()),
                                      const Spacer(),
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
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, _SaleListFilter value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
