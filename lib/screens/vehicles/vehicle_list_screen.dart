import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/access_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(accessibleVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vehicles/add'),
        child: const Icon(Icons.add),
      ),
      body: vehicles.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Text('No vehicles found'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(accessibleVehiclesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final vehicle = data[index];
                return CustomCard(
                  onTap: () => context.push('/vehicles/${vehicle.id}'),
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
                                  '${vehicle.make} ${vehicle.model}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Year: ${vehicle.year}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(vehicle.color),
                            backgroundColor: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.tag, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text('VIN: ${vehicle.vin}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.directions_car,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text('License: ${vehicle.licensePlate}'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading vehicles...'),
        error: (error, stackTrace) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(accessibleVehiclesProvider),
        ),
      ),
    );
  }
}
