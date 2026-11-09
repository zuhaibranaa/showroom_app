import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/reference_options.dart';
import '../../models/sale_model.dart';
import '../../models/vehicle_model.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vehicle_provider.dart';
import 'tracking_utils.dart';

enum _BiometricFilter { pending, done, all }

enum _BiometricWho { all, seller, buyer }

enum _BiometricDateFilter { all, today, lastSevenDays, thisMonth, custom }

enum _BiometricAction { done, changeDate, reopen }

class _BiometricItem {
  final String id;
  final String person;
  final String phone;
  final String vehicle;
  final String number;
  final String status;
  final DateTime date;
  final bool seller;
  final VehicleModel? vehicleRecord;
  final SaleModel? saleRecord;

  const _BiometricItem({
    required this.id,
    required this.person,
    required this.phone,
    required this.vehicle,
    required this.number,
    required this.status,
    required this.date,
    required this.seller,
    this.vehicleRecord,
    this.saleRecord,
  });
}

class BiometricsScreen extends ConsumerStatefulWidget {
  const BiometricsScreen({super.key});

  @override
  ConsumerState<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends ConsumerState<BiometricsScreen> {
  final _searchController = TextEditingController();
  _BiometricFilter _status = _BiometricFilter.pending;
  _BiometricWho _who = _BiometricWho.all;
  _BiometricDateFilter _dateFilter = _BiometricDateFilter.all;
  DateTime? _customDate;
  String _query = '';
  final Set<String> _busyItems = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_BiometricItem> _allItems(
    List<VehicleModel> vehicles,
    List<SaleModel> sales,
  ) {
    final vehicleNames = {
      for (final vehicle in vehicles)
        vehicle.id: '${vehicle.make} ${vehicle.model} ${vehicle.year}',
    };
    final sellerItems = vehicles
        .where(
          (vehicle) =>
              vehicle.biometricStatus == 'PENDING' ||
              vehicle.biometricStatus == 'DONE',
        )
        .map(
          (vehicle) => _BiometricItem(
            id: 'seller-${vehicle.id}',
            person: vehicle.sellerName?.isNotEmpty == true
                ? vehicle.sellerName!
                : 'Seller not named',
            phone: vehicle.biometricPhone ?? vehicle.sellerPhone ?? '',
            vehicle: '${vehicle.make} ${vehicle.model} ${vehicle.year}',
            number:
                vehicle.plateNo ??
                vehicle.registrationNo ??
                vehicle.licensePlate,
            status: vehicle.biometricStatus!,
            date: vehicle.biometricAvailableDate ?? vehicle.updatedAt,
            seller: true,
            vehicleRecord: vehicle,
          ),
        );
    final buyerItems = sales
        .where(
          (sale) =>
              sale.biometricStatus == 'PENDING' ||
              sale.biometricStatus == 'DONE',
        )
        .map(
          (sale) => _BiometricItem(
            id: 'buyer-${sale.id}',
            person: sale.buyerName.isNotEmpty
                ? sale.buyerName
                : 'Buyer not named',
            phone: sale.buyerPhone,
            vehicle:
                vehicleNames[sale.vehicleId] ?? 'Vehicle ${sale.vehicleId}',
            number: sale.numberPlate ?? '',
            // SaleModel has no dedicated biometric date. Its update timestamp is
            // kept in sync by every biometric action below.
            status: sale.biometricStatus!,
            date: sale.buyerBiometricLastDate ?? sale.updatedAt,
            seller: false,
            saleRecord: sale,
          ),
        );
    return [...sellerItems, ...buyerItems]
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  bool _matchesDate(_BiometricItem item, DateTime now) {
    final date = DateTime(item.date.year, item.date.month, item.date.day);
    final today = DateTime(now.year, now.month, now.day);
    switch (_dateFilter) {
      case _BiometricDateFilter.all:
        return true;
      case _BiometricDateFilter.today:
        return date == today;
      case _BiometricDateFilter.lastSevenDays:
        return !date.isBefore(today.subtract(const Duration(days: 6))) &&
            !date.isAfter(today);
      case _BiometricDateFilter.thisMonth:
        return date.year == now.year && date.month == now.month;
      case _BiometricDateFilter.custom:
        if (_customDate == null) return true;
        return date ==
            DateTime(_customDate!.year, _customDate!.month, _customDate!.day);
    }
  }

  List<_BiometricItem> _filtered(List<_BiometricItem> items) {
    final query = _query.trim().toLowerCase();
    final now = DateTime.now();
    return items.where((item) {
      if (_status == _BiometricFilter.pending && item.status != 'PENDING') {
        return false;
      }
      if (_status == _BiometricFilter.done && item.status != 'DONE') {
        return false;
      }
      if (_who == _BiometricWho.seller && !item.seller) return false;
      if (_who == _BiometricWho.buyer && item.seller) return false;
      if (!_matchesDate(item, now)) return false;
      if (query.isEmpty) return true;
      return [
        item.person,
        item.phone,
        item.vehicle,
        item.number,
      ].any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _perform(_BiometricItem item, _BiometricAction action) async {
    DateTime? selectedDate = item.date;
    if (action != _BiometricAction.reopen) {
      selectedDate = await _showBiometricActionDialog(item, action);
      if (selectedDate == null) return;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reopen biometric?'),
          content: Text('Mark ${item.person}\'s biometric as pending again?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reopen'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (!mounted) return;
    setState(() => _busyItems.add(item.id));
    try {
      final bool done;
      if (action == _BiometricAction.reopen) {
        done = false;
      } else if (action == _BiometricAction.done) {
        done = true;
      } else {
        done = item.status == 'DONE';
      }
      final date = action == _BiometricAction.reopen
          ? DateTime.now()
          : selectedDate;
      if (item.seller) {
        final vehicle = item.vehicleRecord!;
        await ref
            .read(vehicleServiceProvider)
            .updateVehicle(
              vehicle.id,
              vehicle.copyWith(
                biometricStatus: done ? 'DONE' : 'PENDING',
                biometricAvailableDate: date,
                updatedAt: DateTime.now(),
              ),
            );
      } else {
        final sale = item.saleRecord!;
        await ref
            .read(saleServiceProvider)
            .updateSale(
              sale.id,
              sale.copyWith(
                biometricStatus: done ? 'DONE' : 'PENDING',
                buyerBiometricLastDate: date,
                updatedAt: DateTime.now(),
              ),
            );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == _BiometricAction.reopen
                  ? 'Biometric reopened'
                  : action == _BiometricAction.changeDate
                  ? 'Biometric date updated'
                  : 'Biometric marked done',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) showTrackingError(context, error);
    } finally {
      if (mounted) setState(() => _busyItems.remove(item.id));
    }
  }

  Future<DateTime?> _showBiometricActionDialog(
    _BiometricItem item,
    _BiometricAction action,
  ) async {
    final formKey = GlobalKey<FormState>();
    DateTime? date = action == _BiometricAction.done
        ? DateTime.now()
        : item.date;
    return showDialog<DateTime>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            action == _BiometricAction.done
                ? 'Mark biometric done'
                : 'Change biometric date',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.person} • ${item.vehicle}'),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: trackingDate(date)),
                  validator: (_) =>
                      date == null ? 'Select a biometric date' : null,
                  onTap: () async {
                    final selected = await pickTrackingDate(
                      context,
                      initialDate: date,
                    );
                    if (selected != null) setDialogState(() => date = selected);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Biometric date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(date);
                }
              },
              child: Text(
                action == _BiometricAction.done ? 'Mark done' : 'Save date',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesStreamProvider);
    final sales = ref.watch(salesStreamProvider);
    final hasError = vehicles.hasError || sales.hasError;
    final isLoading = vehicles.isLoading || sales.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Tracking')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (vehicles.error ?? sales.error).toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        ref.invalidate(vehiclesStreamProvider);
                        ref.invalidate(salesStreamProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _buildContent(vehicles.value ?? [], sales.value ?? []),
    );
  }

  Widget _buildContent(List<VehicleModel> vehicles, List<SaleModel> sales) {
    final all = _allItems(vehicles, sales);
    final items = _filtered(all);
    final pending = all.where((item) => item.status == 'PENDING').length;
    final done = all.where((item) => item.status == 'DONE').length;
    final sellerPending = all
        .where((item) => item.seller && item.status == 'PENDING')
        .length;
    final buyerPending = all
        .where((item) => !item.seller && item.status == 'PENDING')
        .length;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(vehiclesStreamProvider);
        ref.invalidate(salesStreamProvider);
      },
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
                  final cards = [
                    TrackingSummaryCard(
                      label: 'Pending',
                      value: pending,
                      icon: Icons.schedule_outlined,
                      color: Colors.orange,
                    ),
                    TrackingSummaryCard(
                      label: 'Seller pending',
                      value: sellerPending,
                      icon: Icons.person_outline,
                      color: Colors.blue,
                    ),
                    TrackingSummaryCard(
                      label: 'Buyer pending',
                      value: buyerPending,
                      icon: Icons.badge_outlined,
                      color: Colors.purple,
                    ),
                    TrackingSummaryCard(
                      label: 'Completed',
                      value: done,
                      icon: Icons.verified_outlined,
                      color: Colors.green,
                    ),
                  ];
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: cards
                        .map((card) => SizedBox(width: width, child: card))
                        .toList(),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(child: _buildFilters()),
          ),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: TrackingEmptyView(
                title: 'No biometrics found',
                message:
                    'Try changing the status, person, date or search filters.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _BiometricCard(
                    item: item,
                    busy: _busyItems.contains(item.id),
                    onDone: () => _perform(item, _BiometricAction.done),
                    onChangeDate: () =>
                        _perform(item, _BiometricAction.changeDate),
                    onReopen: () => _perform(item, _BiometricAction.reopen),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search person, phone, vehicle or number',
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
            final fields = [
              TrackingFilterField<_BiometricFilter>(
                label: 'Status',
                value: _status,
                items: const [
                  DropdownMenuItem(
                    value: _BiometricFilter.pending,
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem(
                    value: _BiometricFilter.done,
                    child: Text('Done'),
                  ),
                  DropdownMenuItem(
                    value: _BiometricFilter.all,
                    child: Text('Pending + done'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? _BiometricFilter.pending),
              ),
              TrackingFilterField<_BiometricWho>(
                label: 'Who',
                value: _who,
                items: const [
                  DropdownMenuItem(
                    value: _BiometricWho.all,
                    child: Text('Everyone'),
                  ),
                  DropdownMenuItem(
                    value: _BiometricWho.seller,
                    child: Text('Sellers'),
                  ),
                  DropdownMenuItem(
                    value: _BiometricWho.buyer,
                    child: Text('Buyers'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _who = value ?? _BiometricWho.all),
              ),
              TrackingFilterField<_BiometricDateFilter>(
                label: 'Date',
                value: _dateFilter,
                items: const [
                  DropdownMenuItem(
                    value: _BiometricDateFilter.all,
                    child: Text('Any date'),
                  ),
                  DropdownMenuItem(
                    value: _BiometricDateFilter.today,
                    child: Text('Today'),
                  ),
                  DropdownMenuItem(
                    value: _BiometricDateFilter.lastSevenDays,
                    child: Text('Last 7 days'),
                  ),
                  DropdownMenuItem(
                    value: _BiometricDateFilter.thisMonth,
                    child: Text('This month'),
                  ),
                  DropdownMenuItem(
                    value: _BiometricDateFilter.custom,
                    child: Text('Choose date'),
                  ),
                ],
                onChanged: (value) async {
                  final filter = value ?? _BiometricDateFilter.all;
                  DateTime? custom = _customDate;
                  if (filter == _BiometricDateFilter.custom) {
                    custom = await pickTrackingDate(
                      context,
                      initialDate: _customDate,
                    );
                    if (custom == null) return;
                  }
                  setState(() {
                    _dateFilter = filter;
                    _customDate = custom;
                  });
                },
              ),
            ];
            if (constraints.maxWidth >= 800) {
              return Row(
                children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: fields[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < fields.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  fields[i],
                ],
              ],
            );
          },
        ),
        if (_dateFilter == _BiometricDateFilter.custom && _customDate != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InputChip(
                avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(trackingDate(_customDate)),
                onDeleted: () => setState(() {
                  _dateFilter = _BiometricDateFilter.all;
                  _customDate = null;
                }),
              ),
            ),
          ),
      ],
    );
  }
}

class _BiometricCard extends StatelessWidget {
  final _BiometricItem item;
  final bool busy;
  final VoidCallback onDone;
  final VoidCallback onChangeDate;
  final VoidCallback onReopen;

  const _BiometricCard({
    required this.item,
    required this.busy,
    required this.onDone,
    required this.onChangeDate,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final done = item.status == 'DONE';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: item.seller
                      ? Colors.blue.withValues(alpha: 0.12)
                      : Colors.purple.withValues(alpha: 0.12),
                  foregroundColor: item.seller ? Colors.blue : Colors.purple,
                  child: Icon(
                    item.seller ? Icons.person_outline : Icons.badge_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.person,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item.seller
                            ? 'Seller • Vehicle purchase'
                            : 'Buyer • Vehicle sale',
                      ),
                    ],
                  ),
                ),
                TrackingStatusChip(
                  label: ReferenceOptions.label(
                    ReferenceOptions.biometricStatuses,
                    item.status,
                  ),
                  color: done ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _BiometricFact(
                  icon: Icons.directions_car_outlined,
                  text: item.vehicle,
                ),
                if (item.number.isNotEmpty)
                  _BiometricFact(icon: Icons.pin_outlined, text: item.number),
                if (item.phone.isNotEmpty)
                  _BiometricFact(icon: Icons.phone_outlined, text: item.phone),
                _BiometricFact(
                  icon: Icons.calendar_today_outlined,
                  text: trackingDate(item.date),
                ),
              ],
            ),
            const Divider(height: 24),
            if (busy)
              const Center(child: CircularProgressIndicator())
            else
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (done)
                      OutlinedButton.icon(
                        onPressed: onReopen,
                        icon: const Icon(Icons.replay),
                        label: const Text('Reopen'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: onDone,
                        icon: const Icon(Icons.check),
                        label: const Text('Mark done'),
                      ),
                    OutlinedButton.icon(
                      onPressed: onChangeDate,
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: const Text('Change date'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BiometricFact extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BiometricFact({required this.icon, required this.text});

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
