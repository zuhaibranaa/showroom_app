import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/vehicle_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_and_error.dart';

class VehicleDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleDetailScreen> createState() =>
      _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  void _showImageViewer(List<String> urls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewerPage(imageUrls: urls, initialIndex: initialIndex),
      ),
    );
  }

  Future<void> _deleteVehicle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text('Are you sure you want to delete this vehicle?'),
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

    await ref
        .read(deleteVehicleProvider.notifier)
        .deleteVehicle(widget.vehicleId);
    if (!mounted) return;

    final state = ref.read(deleteVehicleProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vehicle deleted')));
      context.go('/vehicles');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehicleByIdProvider(widget.vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/vehicles/${widget.vehicleId}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteVehicle,
          ),
        ],
      ),
      body: vehicle.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Vehicle not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.make} ${data.model}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Year', value: '${data.year}'),
                    _DetailRow(label: 'Color', value: data.color),
                    _DetailRow(label: 'License Plate', value: data.licensePlate),
                    _DetailRow(label: 'VIN / Plate No', value: data.vin),
                    _DetailRow(label: 'Engine No', value: data.engineNo ?? '—'),
                    _DetailRow(label: 'Chassis No', value: data.chassisNo ?? '—'),
                    _DetailRow(
                      label: 'Added',
                      value: '${data.createdAt.toLocal()}',
                    ),
                  ],
                ),
              ),
              if (data.description != null) ...[
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(data.description!),
                    ],
                  ),
                ),
              ],
              if (data.imageUrls != null && data.imageUrls!.isNotEmpty) ...[
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
                          itemCount: data.imageUrls!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 120,
                              child: GestureDetector(
                                onTap: () => _showImageViewer(data.imageUrls!, index),
                                child: Image.network(
                                  data.imageUrls![index],
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
        loading: () => const LoadingWidget(message: 'Loading vehicle...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onBack: () => context.go('/vehicles'),
        ),
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
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
