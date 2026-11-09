import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/operations_models.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/operations_provider.dart';
import 'vehicle_service_add_screen.dart';

class VehicleServiceListScreen extends ConsumerStatefulWidget {
  const VehicleServiceListScreen({super.key});

  @override
  ConsumerState<VehicleServiceListScreen> createState() =>
      _VehicleServiceListScreenState();
}

class _VehicleServiceListScreenState
    extends ConsumerState<VehicleServiceListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _type = 'All';
  bool _allDates = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VehicleServiceRecord> _filtered(List<VehicleServiceRecord> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final query = _query.trim().toLowerCase();
    final result = items.where((record) {
      if (_type != 'All' && record.type != _type) return false;
      if (!_allDates) {
        final date = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );
        if (date != today) return false;
      }
      if (query.isEmpty) return true;
      final haystack = [
        record.type,
        record.chassisNo,
        record.oldNumber,
        record.newNumber,
        record.customerName,
        record.firstOwner,
        record.secondOwner,
        record.phone,
        record.receivedBy,
        record.note,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Future<void> _delete(VehicleServiceRecord record) async {
    final user = ref.read(currentUserProvider).value;
    if (!AccessService.isStaff(user)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(operationsServiceProvider).deleteVehicleService(record.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Record deleted')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  Future<void> _openForm({VehicleServiceRecord? record}) async {
    final user = ref.read(currentUserProvider).value;
    if (!AccessService.isStaff(user)) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VehicleServiceAddScreen(
          id: record?.id,
          type: record?.type ?? 'REGISTRATION',
        ),
      ),
    );
    if (saved == true) ref.invalidate(vehicleServicesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final canManage = AccessService.isStaff(user);
    final servicesAsync = ref.watch(vehicleServicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registration & Transfer')),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              child: const Icon(Icons.add),
            )
          : null,
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString(), textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.invalidate(vehicleServicesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          final filtered = _filtered(items);
          final total = filtered.fold<double>(
            0,
            (sum, record) => sum + record.amount,
          );
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(vehicleServicesProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryValue(
                            label: _allDates
                                ? 'All-time amount'
                                : 'Today amount',
                            value: NumberFormat.currency(
                              symbol: 'Rs ',
                            ).format(total),
                          ),
                        ),
                        Expanded(
                          child: _SummaryValue(
                            label: 'Records',
                            value: filtered.length.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Today'),
                      selected: !_allDates,
                      onSelected: (_) => setState(() => _allDates = false),
                    ),
                    ChoiceChip(
                      label: const Text('All dates'),
                      selected: _allDates,
                      onSelected: (_) => setState(() => _allDates = true),
                    ),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All types'),
                          ),
                          DropdownMenuItem(
                            value: 'REGISTRATION',
                            child: Text('Registration'),
                          ),
                          DropdownMenuItem(
                            value: 'TRANSFER',
                            child: Text('Transfer'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _type = value ?? 'All'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('No records found')),
                  )
                else
                  ...filtered.map(
                    (record) => _recordCard(context, record, canManage),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _recordCard(
    BuildContext context,
    VehicleServiceRecord record,
    bool canManage,
  ) {
    final biometricText = [
      if (record.firstOwnerBiometricPending) '1st owner biometric pending',
      if (record.secondOwnerBiometricPending) '2nd owner biometric pending',
    ].join(', ');
    return Card(
      child: ListTile(
        title: Text(
          record.type == 'TRANSFER' ? 'Transfer' : 'Registration',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          [
            if (record.chassisNo?.isNotEmpty == true)
              'Chassis: ${record.chassisNo}',
            if (record.oldNumber?.isNotEmpty == true)
              'Old: ${record.oldNumber}',
            if (record.newNumber?.isNotEmpty == true)
              'New: ${record.newNumber}',
            if (record.customerName?.isNotEmpty == true)
              'Customer: ${record.customerName}',
            if (record.firstOwner?.isNotEmpty == true)
              '1st: ${record.firstOwner}',
            if (record.secondOwner?.isNotEmpty == true)
              '2nd: ${record.secondOwner}',
            'Phone: ${record.phone}',
            'Received by: ${record.receivedBy}',
            DateFormat('MMM d, yyyy').format(record.date),
            if (record.note?.isNotEmpty == true) record.note!,
            if (biometricText.isNotEmpty) biometricText,
          ].join('\n'),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat.currency(symbol: 'Rs ').format(record.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (canManage)
              PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    _openForm(record: record);
                  } else {
                    _delete(record);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
