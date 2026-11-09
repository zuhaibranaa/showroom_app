import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sale_model.dart';
import '../../models/vehicle_model.dart';
import '../../providers/access_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_card.dart';
import 'person_edit_screen.dart';

class PersonDetailScreen extends ConsumerWidget {
  final String name;
  final String? phone;
  final String? saleId;
  final String? vehicleId;

  const PersonDetailScreen({
    super.key,
    required this.name,
    this.phone,
    this.saleId,
    this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales =
        ref.watch(accessibleSalesProvider).valueOrNull ?? const <SaleModel>[];
    final vehicles =
        ref.watch(accessibleVehiclesProvider).valueOrNull ??
        const <VehicleModel>[];
    final relatedSales = sales.where((s) => s.buyerName == name).toList();
    final relatedVehicles = vehicles
        .where((v) => v.sellerName == name)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (phone != null && phone!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(phone!),
                ],
                const SizedBox(height: 8),
                Text('Related sales: ${relatedSales.length}'),
                Text('Related vehicles: ${relatedVehicles.length}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (relatedSales.isNotEmpty) ...[
            const Text(
              'Sales',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...relatedSales.map(
              (sale) => CustomCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PersonEditScreen(name: name, saleId: sale.id),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(sale.buyerName),
                  subtitle: Text(
                    '${sale.salePrice.toCurrencyString()} • ${sale.saleDate.toFormattedString()}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
          if (relatedVehicles.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Vehicles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...relatedVehicles.map(
              (vehicle) => CustomCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PersonEditScreen(name: name, vehicleId: vehicle.id),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${vehicle.make} ${vehicle.model}'),
                  subtitle: Text(vehicle.chassisNo ?? vehicle.vin),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
          if (relatedSales.isEmpty && relatedVehicles.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: Text('No related records found')),
            ),
        ],
      ),
    );
  }
}
