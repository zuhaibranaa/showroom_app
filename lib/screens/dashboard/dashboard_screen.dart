import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/agency_model.dart';
import '../../models/expense_model.dart';
import '../../models/operations_models.dart';
import '../../models/sale_model.dart';
import '../../models/user_model.dart';
import '../../models/vehicle_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/agency_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/operations_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vehicle_provider.dart';

const _allAgencies = '__all__';

final _currency = NumberFormat.currency(
  locale: 'en_PK',
  symbol: 'Rs ',
  decimalDigits: 0,
);
final _saleDateFormat = DateFormat('d MMM y');

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _agencyFilter = _allAgencies;
  bool _todayOnly = false;

  Future<void> _refresh(String agencyFilter) async {
    final futures = <Future<Object?>>[
      ref.refresh(accessibleAgenciesProvider.future),
      ref.refresh(paymentsProvider.future),
      ref.refresh(vehicleServicesProvider.future),
    ];
    if (agencyFilter == _allAgencies) {
      futures.addAll([
        ref.refresh(accessibleVehiclesProvider.future),
        ref.refresh(accessibleSalesProvider.future),
        ref.refresh(expensesProvider.future),
      ]);
    } else {
      futures.addAll([
        ref.refresh(vehiclesStreamByAgencyProvider(agencyFilter).future),
        ref.refresh(salesStreamByAgencyProvider(agencyFilter).future),
        ref.refresh(expensesByAgencyProvider(agencyFilter).future),
      ]);
    }
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final user = currentUser.value;

    if (currentUser.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null) {
      return Scaffold(body: _ProfileUnavailable(hasError: currentUser.hasError));
    }
    return _buildDashboard(context, user);
  }

  Widget _buildDashboard(BuildContext context, UserModel user) {
    final isSuperAdmin = AccessService.isSuperAdmin(user);
    final agencies = ref.watch(accessibleAgenciesProvider);
    final agencyFilter =
        !isSuperAdmin &&
            _agencyFilter == _allAgencies &&
            user.agencyIds.isNotEmpty
        ? user.agencyIds.first
        : _agencyFilter;
    final isAllAgencies = agencyFilter == _allAgencies;

    final vehicles = isAllAgencies
        ? ref.watch(accessibleVehiclesProvider)
        : ref.watch(vehiclesStreamByAgencyProvider(agencyFilter));
    final sales = isAllAgencies
        ? ref.watch(accessibleSalesProvider)
        : ref.watch(salesStreamByAgencyProvider(agencyFilter));
    final expenses = isAllAgencies
        ? ref.watch(expensesProvider)
        : ref.watch(expensesByAgencyProvider(agencyFilter));
    final payments = ref.watch(paymentsProvider);
    final services = ref.watch(vehicleServicesProvider);

    final vehicleList = vehicles.value ?? const <VehicleModel>[];
    final saleList = sales.value ?? const <SaleModel>[];
    final expenseList = expenses.value ?? const <ExpenseModel>[];
    final paymentList = payments.value ?? const <PaymentModel>[];
    final serviceList = services.value ?? const <VehicleServiceRecord>[];
    final now = DateTime.now();
    final periodSales = saleList
        .where((sale) => _inSelectedPeriod(sale.saleDate, now, _todayOnly))
        .toList();
    final periodExpenses = expenseList
        .where((expense) => _inSelectedPeriod(expense.date, now, _todayOnly))
        .toList();
    final soldVehicleIds = saleList.map((sale) => sale.vehicleId).toSet();
    final inStock = vehicleList
        .where((vehicle) => !soldVehicleIds.contains(vehicle.id))
        .length;
    final pendingDocuments = vehicleList
        .where((vehicle) => _isPending(vehicle.documentStatus))
        .toList();
    final paymentsBySale = <String, List<PaymentModel>>{};
    for (final payment in paymentList) {
      paymentsBySale.putIfAbsent(payment.saleId, () => []).add(payment);
    }
    final outstanding = <String, double>{
      for (final sale in saleList)
        sale.id: _outstandingAmount(sale, paymentsBySale[sale.id] ?? const []),
    };
    final pendingSales = saleList
        .where((sale) => (outstanding[sale.id] ?? 0) > 0)
        .toList();
    final toCollect = pendingSales.fold<double>(
      0,
      (total, sale) => total + (outstanding[sale.id] ?? 0),
    );
    final purchased = periodSales.fold<double>(
      0,
      (total, sale) => total + sale.purchasePrice,
    );
    final sold = periodSales.fold<double>(
      0,
      (total, sale) => total + sale.salePrice,
    );
    final showroomExpenses = periodExpenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
    final bikeProfit = sold - purchased;
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfDueWeek = startOfToday.add(const Duration(days: 7));
    final overdue = pendingSales.where((sale) {
      final dueDate = _paymentDueDate(sale, paymentsBySale[sale.id]);
      return dueDate != null && dueDate.isBefore(startOfToday);
    }).length;
    final dueThisWeek = pendingSales.where((sale) {
      final dueDate = _paymentDueDate(sale, paymentsBySale[sale.id]);
      return dueDate != null &&
          !dueDate.isBefore(startOfToday) &&
          !dueDate.isAfter(endOfDueWeek);
    }).length;
    final biometricAlerts =
        saleList.where((sale) => _isPending(sale.biometricStatus)).length +
        vehicleList
            .where((vehicle) => _isPending(vehicle.biometricStatus))
            .length +
        serviceList.where((service) {
          return service.firstOwnerBiometricPending ||
              service.secondOwnerBiometricPending;
        }).length;
    final stuckThreshold = now.subtract(const Duration(days: 7));
    final stuckDocuments = pendingDocuments
        .where((vehicle) => vehicle.updatedAt.isBefore(stuckThreshold))
        .length;
    final recentSales = [...saleList]
      ..sort((a, b) => b.saleDate.compareTo(a.saleDate));
    final vehicleNames = <String, String>{
      for (final vehicle in vehicleList)
        vehicle.id: '${vehicle.make} ${vehicle.model}'.trim(),
    };
    final errors = <String>[
      if (agencies.hasError) 'agencies',
      if (vehicles.hasError) 'vehicles',
      if (sales.hasError) 'sales',
      if (expenses.hasError) 'expenses',
      if (payments.hasError) 'payments',
      if (services.hasError) 'biometric services',
    ];

    return RefreshIndicator(
      onRefresh: () => _refresh(agencyFilter),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.username}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<AgencyModel?>(
                      future: _agencyFilter == _allAgencies
                          ? null
                          : ref.read(agencyByIdProvider(_agencyFilter).future),
                      builder: (context, snapshot) {
                        final agencyName = snapshot.data?.name ??
                            (_agencyFilter == _allAgencies
                                ? 'All Agencies'
                                : 'Showroom');
                        return Text(
                          'Here is what is happening at $agencyName.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _AgencyFilter(
                          value: agencyFilter,
                          agencies: agencies.value ?? const [],
                          includeAll: isSuperAdmin,
                          enabled: !agencies.hasError,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _agencyFilter = value);
                            }
                          },
                        ),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              label: Text('This month'),
                              icon: Icon(Icons.calendar_month_outlined),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text('Today'),
                              icon: Icon(Icons.today_outlined),
                            ),
                          ],
                          selected: {_todayOnly},
                          onSelectionChanged: (selection) {
                            setState(() => _todayOnly = selection.first);
                          },
                        ),
                      ],
                    ),
                    if ((vehicles.isLoading && !vehicles.hasValue) ||
                        (sales.isLoading && !sales.hasValue)) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                    if (errors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _DataErrorNotice(
                        sources: errors,
                        onRetry: () => _refresh(agencyFilter),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _ResponsiveCards(
                      minItemWidth: 160,
                      maxColumns: 5,
                      children: [
                        _MetricCard(
                          title: 'In stock',
                          value: _countValue(vehicles, inStock),
                          icon: Icons.two_wheeler_outlined,
                          color: Colors.blue,
                          onTap: () => context.go('/vehicles'),
                        ),
                        _MetricCard(
                          title: 'Sold this month',
                          value: _countValue(sales, periodSales.length),
                          subtitle: _todayOnly ? 'Today' : null,
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                          onTap: () => context.go('/sales'),
                        ),
                        _MetricCard(
                          title: 'Payment pending',
                          value: _countValue(sales, pendingSales.length),
                          icon: Icons.schedule_outlined,
                          color: Colors.orange,
                          onTap: () => context.go('/pending-payments'),
                        ),
                        _MetricCard(
                          title: 'Documents pending',
                          value: _countValue(vehicles, pendingDocuments.length),
                          icon: Icons.description_outlined,
                          color: Colors.purple,
                          onTap: () => context.go('/documents'),
                        ),
                        _MetricCard(
                          title: 'To collect',
                          value: sales.hasValue
                              ? _currency.format(toCollect)
                              : _asyncPlaceholder(sales),
                          icon: Icons.account_balance_wallet_outlined,
                          color: Colors.teal,
                          onTap: () => context.go('/pending-payments'),
                        ),
                      ],
                    ),
                    if (AccessService.isStaff(user)) ...[
                      const SizedBox(height: 28),
                      _SectionHeading(
                        title: 'Financial summary',
                        subtitle: _todayOnly ? 'Today' : 'This month',
                      ),
                      const SizedBox(height: 12),
                      _ResponsiveCards(
                        minItemWidth: 175,
                        maxColumns: 5,
                        children: [
                          _FinancialCard(
                            title: 'Purchased',
                            value: sales.hasValue
                                ? _currency.format(purchased)
                                : _asyncPlaceholder(sales),
                            icon: Icons.shopping_cart_outlined,
                          ),
                          _FinancialCard(
                            title: 'Sold',
                            value: sales.hasValue
                                ? _currency.format(sold)
                                : _asyncPlaceholder(sales),
                            icon: Icons.sell_outlined,
                          ),
                          _FinancialCard(
                            title: 'Bike profit',
                            value: sales.hasValue
                                ? _currency.format(bikeProfit)
                                : _asyncPlaceholder(sales),
                            icon: Icons.trending_up_outlined,
                            valueColor: bikeProfit < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                          _FinancialCard(
                            title: 'Showroom expenses',
                            value: expenses.hasValue
                                ? _currency.format(showroomExpenses)
                                : _asyncPlaceholder(expenses),
                            icon: Icons.receipt_long_outlined,
                          ),
                          _FinancialCard(
                            title: 'Net profit',
                            value: sales.hasValue && expenses.hasValue
                                ? _currency.format(
                                    bikeProfit - showroomExpenses,
                                  )
                                : !sales.hasValue
                                ? _asyncPlaceholder(sales)
                                : _asyncPlaceholder(expenses),
                            icon: Icons.account_balance_outlined,
                            valueColor: bikeProfit - showroomExpenses < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 28),
                    const _SectionHeading(
                      title: 'Needs attention',
                      subtitle: 'Payment, biometric and document alerts',
                    ),
                    const SizedBox(height: 12),
                    if (overdue +
                            dueThisWeek +
                            biometricAlerts +
                            stuckDocuments ==
                        0)
                      const _AllCaughtUpCard()
                    else
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            if (overdue > 0)
                              _AlertTile(
                                title: 'Overdue payments',
                                subtitle:
                                    '$overdue payment${overdue == 1 ? '' : 's'} overdue',
                                icon: Icons.warning_amber_outlined,
                                color: Colors.red,
                                onTap: () => context.go('/pending-payments'),
                              ),
                            if (dueThisWeek > 0)
                              _AlertTile(
                                title: 'Payments due this week',
                                subtitle:
                                    '$dueThisWeek payment${dueThisWeek == 1 ? '' : 's'} due in the next 7 days',
                                icon: Icons.event_outlined,
                                color: Colors.orange,
                                onTap: () => context.go('/pending-payments'),
                              ),
                            if (biometricAlerts > 0)
                              _AlertTile(
                                title: 'Biometrics pending',
                                subtitle:
                                    '$biometricAlerts item${biometricAlerts == 1 ? '' : 's'} need attention',
                                icon: Icons.fingerprint_outlined,
                                color: Colors.deepOrange,
                                onTap: () => context.go('/biometrics'),
                              ),
                            if (stuckDocuments > 0)
                              _AlertTile(
                                title: 'Documents stuck',
                                subtitle:
                                    '$stuckDocuments document${stuckDocuments == 1 ? '' : 's'} unchanged for over 7 days',
                                icon: Icons.folder_open_outlined,
                                color: Colors.purple,
                                onTap: () => context.go('/documents'),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),
                    const _SectionHeading(
                      title: 'Recent sales',
                      subtitle: 'Latest showroom activity',
                    ),
                    const SizedBox(height: 12),
                    if (sales.hasError && !sales.hasValue)
                      const _EmptyCard(
                        icon: Icons.error_outline,
                        message: 'Recent sales are temporarily unavailable.',
                      )
                    else if (!sales.hasValue)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (recentSales.isEmpty)
                      const _EmptyCard(
                        icon: Icons.point_of_sale_outlined,
                        message: 'No sales have been recorded yet.',
                      )
                    else
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (final sale in recentSales.take(6))
                              ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    sale.buyerName.isEmpty
                                        ? '?'
                                        : sale.buyerName[0].toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  sale.buyerName.isEmpty
                                      ? 'Unnamed buyer'
                                      : sale.buyerName,
                                ),
                                subtitle: Text(
                                  '${vehicleNames[sale.vehicleId] ?? 'Vehicle'} · ${_saleDateFormat.format(sale.saleDate)}',
                                ),
                                trailing: _RecentSaleAmount(
                                  amount: sale.salePrice,
                                  pending: outstanding[sale.id] ?? 0,
                                ),
                                onTap: () => context.push('/sales/${sale.id}'),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _countValue(AsyncValue<Object?> state, int value) {
    if (state.hasValue) return value.toString();
    return _asyncPlaceholder(state);
  }

  static String _asyncPlaceholder(AsyncValue<Object?> state) {
    return state.hasError ? '—' : '…';
  }

  static bool _inSelectedPeriod(DateTime date, DateTime now, bool todayOnly) {
    if (todayOnly) {
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }
    return date.year == now.year && date.month == now.month;
  }

  static bool _isPending(String? status) {
    final normalized = status?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return false;
    return !const {
      'applied',
      'approved',
      'available',
      'clear',
      'complete',
      'completed',
      'done',
      'not required',
      'received',
      'registered',
      'verified',
    }.contains(normalized);
  }

  static double _outstandingAmount(
    SaleModel sale,
    List<PaymentModel> payments,
  ) {
    final explicitBalance = sale.balancePending ?? sale.pendingAmount;
    if (explicitBalance != null) return math.max(0, explicitBalance);
    final recordedPayments = payments
        .where((payment) => !payment.cancelled)
        .fold<double>(0, (total, payment) => total + payment.amount);
    final received = sale.amountReceived ?? sale.amountPaid ?? recordedPayments;
    return math.max(0, sale.salePrice - received);
  }

  static DateTime? _paymentDueDate(
    SaleModel sale,
    List<PaymentModel>? payments,
  ) {
    final promisedDates =
        (payments ?? const <PaymentModel>[])
            .where(
              (payment) => !payment.cancelled && payment.promisedDate != null,
            )
            .map((payment) => payment.promisedDate!)
            .toList()
          ..sort((a, b) => b.compareTo(a));
    return sale.dueDate ??
        sale.promisedDate ??
        sale.pendingDate ??
        (promisedDates.isEmpty ? null : promisedDates.first);
  }
}

class _AgencyFilter extends StatelessWidget {
  final String value;
  final List<dynamic> agencies;
  final bool includeAll;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _AgencyFilter({
    required this.value,
    required this.agencies,
    required this.includeAll,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      borderRadius: BorderRadius.circular(12),
      items: [
        if (includeAll)
          const DropdownMenuItem(
            value: _allAgencies,
            child: Text('All agencies'),
          ),
        for (final agency in agencies)
          DropdownMenuItem(
            value: agency.id as String,
            child: Text(agency.name as String),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _ResponsiveCards extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;

  const _ResponsiveCards({
    required this.children,
    required this.minItemWidth,
    required this.maxColumns,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = math.min(
          maxColumns,
          math.max(1, (constraints.maxWidth / minItemWidth).floor()),
        );
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: width, height: 132, child: child),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(icon, color: color, size: 22),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                subtitle ?? 'View details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _FinancialCard({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _AllCaughtUpCard extends StatelessWidget {
  const _AllCaughtUpCard();

  @override
  Widget build(BuildContext context) {
    return const _EmptyCard(
      icon: Icons.check_circle_outline,
      message: 'All caught up. No alerts need your attention.',
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _RecentSaleAmount extends StatelessWidget {
  final double amount;
  final double pending;

  const _RecentSaleAmount({required this.amount, required this.pending});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _currency.format(amount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (pending > 0)
          Text(
            '${_currency.format(pending)} pending',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade800),
          ),
      ],
    );
  }
}

class _DataErrorNotice extends StatelessWidget {
  final List<String> sources;
  final Future<void> Function() onRetry;

  const _DataErrorNotice({required this.sources, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Could not update ${sources.join(', ')}. Showing the latest available data.',
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _ProfileUnavailable extends StatelessWidget {
  final bool hasError;

  const _ProfileUnavailable({required this.hasError});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          hasError
              ? 'Error loading your profile. Pull down or try again later.'
              : 'Your profile was not found. Please contact the super admin.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
