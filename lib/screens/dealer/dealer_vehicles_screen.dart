import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dealer_profile_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class DealerVehiclesScreen extends ConsumerWidget {
  const DealerVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentDealerProfileProvider);
    final dealer = profile.value;
    final vehicles = dealer == null
        ? null
        : ref.watch(vehiclesStreamByAgencyProvider(dealer.agencyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles'), elevation: 0),
      body: profile.isLoading
          ? const LoadingWidget(message: 'Loading profile...')
          : dealer == null
              ? const Center(
                  child: Text('No dealer profile found for this account.'),
                )
              : vehicles == null
                  ? const LoadingWidget(message: 'Loading vehicles...')
                  : vehicles.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return const Center(child: Text('No vehicles yet'));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final vehicle = data[index];
                            return CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${vehicle.make} ${vehicle.model}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        label: Text(vehicle.color),
                                        backgroundColor: Colors.blue
                                            .withValues(alpha: 0.2),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Year: ${vehicle.year}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'License: ${vehicle.licensePlate}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const LoadingWidget(message: 'Loading vehicles...'),
                      error: (error, _) =>
                          ErrorView(message: error.toString()),
                    ),
    );
  }
}
