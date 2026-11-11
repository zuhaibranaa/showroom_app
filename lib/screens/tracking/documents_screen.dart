import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/reference_options.dart';
import '../../models/vehicle_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/document_history_provider.dart';
import '../../providers/vehicle_provider.dart';
import 'tracking_utils.dart';
import 'update_documents_dialog.dart';

enum _DocumentType { all, newVehicle, used }

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _status = 'ALL';
  _DocumentType _type = _DocumentType.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _waitingDays(VehicleModel vehicle) {
    final days = DateTime.now().difference(vehicle.updatedAt).inDays;
    return days < 0 ? 0 : days;
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'RECEIVED':
      case 'DELIVERED':
        return Colors.green;
      case 'PENDING':
        return Colors.red;
      case 'WAITING':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  List<VehicleModel> _filtered(List<VehicleModel> vehicles) {
    final query = _query.trim().toLowerCase();
    final result = vehicles.where((vehicle) {
      final status = vehicle.documentStatus ?? 'PENDING';
      if (_status != 'ALL' && status != _status) return false;
      if (_type == _DocumentType.newVehicle && !vehicle.isZeroMeter) {
        return false;
      }
      if (_type == _DocumentType.used && vehicle.isZeroMeter) return false;
      if (query.isEmpty) return true;
      return [
        vehicle.make,
        vehicle.model,
        vehicle.licensePlate,
        vehicle.plateNo,
        vehicle.registrationNo,
        vehicle.chassisNo,
        vehicle.engineNo,
        vehicle.sellerName,
        vehicle.sellerPhone,
      ].whereType<String>().any((value) => value.toLowerCase().contains(query));
    }).toList();
    result.sort((a, b) => _waitingDays(b).compareTo(_waitingDays(a)));
    return result;
  }

  Future<void> _update(VehicleModel vehicle) async {
    final updated = await UpdateDocumentsDialog.show(context, vehicle);
    if (updated == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Documents updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(accessibleVehiclesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Document Tracking')),
      body: vehicles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(vehiclesStreamProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final items = _filtered(data);
          final waiting = data.where(
            (vehicle) => (vehicle.documentStatus ?? 'PENDING') == 'WAITING',
          );
          final delivered = data.where(
            (vehicle) => vehicle.documentStatus == 'DELIVERED',
          );
          final pending = data.where(
            (vehicle) => (vehicle.documentStatus ?? 'PENDING') == 'PENDING',
          );
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(vehiclesStreamProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth >= 900
                            ? (constraints.maxWidth - 36) / 4
                            : (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: width,
                              child: TrackingSummaryCard(
                                label: 'Total vehicles',
                                value: data.length,
                                icon: Icons.description_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: TrackingSummaryCard(
                                label: 'On hold',
                                value: pending.length,
                                icon: Icons.pause_circle_outline,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: TrackingSummaryCard(
                                label: 'Waiting',
                                value: waiting.length,
                                icon: Icons.schedule_outlined,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: TrackingSummaryCard(
                                label: 'Delivered',
                                value: delivered.length,
                                icon: Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText:
                                'Search vehicle, plate, chassis or seller',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 600;
                            final status = TrackingFilterField<String>(
                              label: 'Document status',
                              value: _status,
                              items: [
                                const DropdownMenuItem(
                                  value: 'ALL',
                                  child: Text('All statuses'),
                                ),
                                ...ReferenceOptions.documentStatuses.entries
                                    .map(
                                      (entry) => DropdownMenuItem(
                                        value: entry.key,
                                        child: Text(entry.value),
                                      ),
                                    ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _status = value ?? 'ALL'),
                            );
                            final type = TrackingFilterField<_DocumentType>(
                              label: 'Vehicle type',
                              value: _type,
                              items: const [
                                DropdownMenuItem(
                                  value: _DocumentType.all,
                                  child: Text('All vehicles'),
                                ),
                                DropdownMenuItem(
                                  value: _DocumentType.newVehicle,
                                  child: Text('New / zero meter'),
                                ),
                                DropdownMenuItem(
                                  value: _DocumentType.used,
                                  child: Text('Used'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _type = value ?? _DocumentType.all,
                              ),
                            );
                            if (wide) {
                              return Row(
                                children: [
                                  Expanded(child: status),
                                  const SizedBox(width: 12),
                                  Expanded(child: type),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                status,
                                const SizedBox(height: 12),
                                type,
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: TrackingEmptyView(
                      title: 'No documents found',
                      message:
                          'Try changing the status, type or search filters.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _DocumentCard(
                        vehicle: items[index],
                        waitingDays: _waitingDays(items[index]),
                        statusColor: _statusColor(items[index].documentStatus),
                        onUpdate: () => _update(items[index]),
                        onHistory: () async {
                          try {
                            final history = await ref.read(
                              documentHistoryByVehicleProvider(items[index].id).future,
                            );
                            if (context.mounted) {
                              await showDocumentHistory(
                                context,
                                items[index],
                                history,
                              );
                            }
                          } catch (error) {
                            if (context.mounted) {
                              showTrackingError(context, error);
                            }
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final VehicleModel vehicle;
  final int waitingDays;
  final Color statusColor;
  final VoidCallback onUpdate;
  final VoidCallback onHistory;

  const _DocumentCard({
    required this.vehicle,
    required this.waitingDays,
    required this.statusColor,
    required this.onUpdate,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final status = vehicle.documentStatus ?? 'PENDING';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model} ${vehicle.year}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.plateNo ??
                            vehicle.registrationNo ??
                            vehicle.licensePlate,
                      ),
                    ],
                  ),
                ),
                TrackingStatusChip(
                  label: ReferenceOptions.label(
                    ReferenceOptions.documentStatuses,
                    status,
                  ),
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _Fact(
                  icon: Icons.category_outlined,
                  text: vehicle.isZeroMeter ? 'New / zero meter' : 'Used',
                ),
                _Fact(
                  icon: Icons.schedule_outlined,
                  text:
                      '$waitingDays waiting day${waitingDays == 1 ? '' : 's'}',
                ),
                _Fact(
                  icon: Icons.update,
                  text: 'Updated ${trackingDate(vehicle.updatedAt)}',
                ),
                if (vehicle.sellerName?.isNotEmpty == true)
                  _Fact(icon: Icons.person_outline, text: vehicle.sellerName!),
              ],
            ),
            if (vehicle.remarks?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(
                vehicle.remarks!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer(
                  builder: (context, ref, _) => TextButton.icon(
                    onPressed: onHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onUpdate,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Update documents'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Fact({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}
