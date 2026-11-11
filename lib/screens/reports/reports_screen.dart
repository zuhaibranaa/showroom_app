import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/reference_options.dart';
import '../../models/dealer_model.dart';
import '../../models/expense_model.dart';
import '../../models/sale_model.dart';
import '../../models/vehicle_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import 'report_export.dart';

final _money = NumberFormat('#,##0.00');
final _day = DateFormat('dd MMM yyyy');

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _dateAppliesTo = 'sold';
  String _period = 'all';
  DateTime _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now();
  String _stock = 'all';
  String _document = 'all';
  String _type = 'all';
  String _dealer = 'all';
  String _sort = 'date';
  bool _ascending = false;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    if (userAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null || !AccessService.isStaff(user)) {
      return const Scaffold(
        body: Center(child: Text('Reports are available to admins only.')),
      );
    }

    final vehiclesAsync = ref.watch(accessibleVehiclesProvider);
    final salesAsync = ref.watch(accessibleSalesProvider);
    final expensesAsync = ref.watch(accessibleExpensesProvider);
    final dealersAsync = ref.watch(accessibleDealersProvider);
    final loading =
        vehiclesAsync.isLoading ||
        salesAsync.isLoading ||
        expensesAsync.isLoading ||
        dealersAsync.isLoading;
    final error =
        vehiclesAsync.error ??
        salesAsync.error ??
        expensesAsync.error ??
        dealersAsync.error;
    final dealers = dealersAsync.valueOrNull ?? const <DealerModel>[];
    final rows = _rows(
      vehiclesAsync.valueOrNull ?? const [],
      salesAsync.valueOrNull ?? const [],
    );
    final expenses = _filteredExpenses(
      expensesAsync.valueOrNull ?? const [],
      user.agencyIds,
      AccessService.isSuperAdmin(user),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            onPressed: loading || _exporting
                ? null
                : () => _export(rows, expenses, pdf: false),
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            tooltip: 'Save print-friendly PDF',
            onPressed: loading || _exporting
                ? null
                : () => _export(rows, expenses, pdf: true),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
          if (_exporting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load report: $error'),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.refresh(expensesProvider.future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _filters(dealers),
                  const SizedBox(height: 16),
                  _summaries(rows, expenses),
                  const SizedBox(height: 20),
                  Text(
                    '${rows.length} report row${rows.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (rows.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No vehicles match these filters.'),
                      ),
                    )
                  else
                    ...rows.map(_rowCard),
                ],
              ),
            ),
    );
  }

  Widget _filters(List<DealerModel> dealers) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.filter_alt_outlined),
        title: const Text('Filters'),
        subtitle: Text(
          '${_periodLabel()} · $_sort ${_ascending ? 'ascending' : 'descending'}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dropdown('Date applies to', _dateAppliesTo, const {
                  'purchase': 'Purchase',
                  'sold': 'Sold',
                  'added': 'Added',
                }, (value) => setState(() => _dateAppliesTo = value)),
                _dropdown('Period', _period, const {
                  'all': 'All time',
                  'today': 'Today',
                  'custom': 'From / to',
                }, (value) => setState(() => _period = value)),
                _dropdown('Stock', _stock, const {
                  'all': 'All',
                  'stock': 'In stock',
                  'sold': 'Sold',
                }, (value) => setState(() => _stock = value)),
                _dropdown('Documents', _document, {
                  'all': 'All',
                  ...ReferenceOptions.documentStatuses.map(
                    (key, value) => MapEntry(key, value),
                  ),
                }, (value) => setState(() => _document = value)),
                _dropdown('Type', _type, const {
                  'all': 'All',
                  'new': 'New',
                  'used': 'Used',
                }, (value) => setState(() => _type = value)),
                _dropdown('Dealer', _dealer, {
                  'all': 'All',
                  'direct': 'Direct / no dealer',
                  for (final dealer in dealers) dealer.id: dealer.name,
                }, (value) => setState(() => _dealer = value)),
                _dropdown('Sort by', _sort, const {
                  'date': 'Date',
                  'make': 'Make / model',
                  'purchase': 'Purchase price',
                  'sale': 'Sale price',
                  'profit': 'Profit',
                }, (value) => setState(() => _sort = value)),
                SizedBox(
                  width: 180,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Order',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<bool>(
                        value: _ascending,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: false,
                            child: Text('Descending'),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Ascending'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _ascending = value ?? false),
                      ),
                    ),
                  ),
                ),
                if (_period == 'custom') ...[
                  _dateButton(
                    'From',
                    _from,
                    (date) => setState(() => _from = date),
                  ),
                  _dateButton('To', _to, (date) => setState(() => _to = date)),
                ],
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    Map<String, String> choices,
    ValueChanged<String> onChanged,
  ) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        initialValue: choices.containsKey(value) ? value : 'all',
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: choices.entries
            .map(
              (entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  Widget _dateButton(
    String label,
    DateTime value,
    ValueChanged<DateTime> onChanged,
  ) {
    return SizedBox(
      width: 180,
      child: OutlinedButton.icon(
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) onChanged(date);
        },
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text('$label: ${_day.format(value)}'),
      ),
    );
  }

  Widget _summaries(List<_ReportRow> rows, List<ExpenseModel> expenses) {
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _summaryCard(
          'Used',
          _ReportSummary.of(rows.where((r) => !r.vehicle.isZeroMeter)),
        ),
        _summaryCard(
          'New',
          _ReportSummary.of(rows.where((r) => r.vehicle.isZeroMeter)),
        ),
        _summaryCard('Total', _ReportSummary.of(rows), totalExpenses),
      ],
    );
  }

  Widget _summaryCard(
    String title,
    _ReportSummary summary, [
    double expenses = 0,
  ]) {
    return SizedBox(
      width: 285,
      child: Card(
        color: title == 'Total'
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text('${summary.count} vehicles · ${summary.soldCount} sold'),
              const Divider(),
              _amountLine('Purchase', summary.purchase),
              _amountLine('Sales', summary.sales),
              _amountLine('Gross profit', summary.gross),
              if (title == 'Total') ...[
                _amountLine('Expenses', expenses),
                _amountLine('Net profit', summary.gross - expenses, bold: true),
              ] else
                _amountLine('Stock value', summary.stockValue, bold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountLine(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            _money.format(amount),
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }

  Widget _rowCard(_ReportRow row) {
    final vehicle = row.vehicle;
    final sale = row.sale;
    return Card(
      child: ListTile(
        title: Text('${vehicle.make} ${vehicle.model} (${vehicle.year})'),
        subtitle: Text(
          '${vehicle.isZeroMeter ? 'New' : 'Used'} · ${sale == null ? 'In stock' : 'Sold ${_day.format(sale.saleDate)}'}\n'
          '${vehicle.chassisNo ?? vehicle.vin} · ${ReferenceOptions.label(ReferenceOptions.documentStatuses, sale?.documentStatus ?? vehicle.documentStatus)}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _money.format(sale?.salePrice ?? vehicle.priceAmount ?? 0),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (sale != null) Text('Profit ${_money.format(sale.profit)}'),
          ],
        ),
      ),
    );
  }

  List<_ReportRow> _rows(List<VehicleModel> vehicles, List<SaleModel> sales) {
    final salesByVehicle = <String, SaleModel>{
      for (final sale in sales) sale.vehicleId: sale,
    };
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final fromStart = DateTime(_from.year, _from.month, _from.day);
    final toEnd = DateTime(
      _to.year,
      _to.month,
      _to.day,
    ).add(const Duration(days: 1));
    final result = <_ReportRow>[];

    for (final vehicle in vehicles) {
      final sale = salesByVehicle[vehicle.id];
      if (_stock == 'sold' && sale == null) continue;
      if (_stock == 'stock' && sale != null) continue;
      if (_type == 'new' && !vehicle.isZeroMeter) continue;
      if (_type == 'used' && vehicle.isZeroMeter) continue;
      final document = sale?.documentStatus ?? vehicle.documentStatus ?? '';
      if (_document != 'all' && document != _document) continue;
      if (_dealer == 'direct' && (sale?.dealerId?.isNotEmpty ?? false)) continue;
      if (_dealer != 'all' &&
          _dealer != 'direct' &&
          sale?.dealerId != _dealer) {
        continue;
      }
      DateTime? date;
      switch (_dateAppliesTo) {
        case 'sold':
          date = sale?.saleDate;
          break;
        case 'purchase':
          date = vehicle.purchaseDate ?? vehicle.createdAt;
          break;
        case 'added':
          date = vehicle.createdAt;
          break;
      }
      if (date == null) continue;
      if (_period == 'today' &&
          (date.isBefore(todayStart) ||
              !date.isBefore(todayStart.add(const Duration(days: 1))))) {
        continue;
      }
      if (_period == 'custom' &&
          (date.isBefore(fromStart) || !date.isBefore(toEnd))) {
        continue;
      }
      result.add(_ReportRow(vehicle, sale));
    }

    int compare(_ReportRow a, _ReportRow b) {
      switch (_sort) {
        case 'make':
          return '${a.vehicle.make} ${a.vehicle.model}'.compareTo(
            '${b.vehicle.make} ${b.vehicle.model}',
          );
        case 'purchase':
          return (a.vehicle.priceAmount ?? 0).compareTo(
            b.vehicle.priceAmount ?? 0,
          );
        case 'sale':
          return (a.sale?.salePrice ?? 0).compareTo(b.sale?.salePrice ?? 0);
        case 'profit':
          return (a.sale?.profit ?? 0).compareTo(b.sale?.profit ?? 0);
        default:
          return a.date.compareTo(b.date);
      }
    }

    result.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return result;
  }

  List<ExpenseModel> _filteredExpenses(
    List<ExpenseModel> expenses,
    List<String> agencyIds,
    bool isSuperAdmin,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final fromStart = DateTime(_from.year, _from.month, _from.day);
    final toEnd = DateTime(
      _to.year,
      _to.month,
      _to.day,
    ).add(const Duration(days: 1));
    return expenses.where((expense) {
      if (!isSuperAdmin && !agencyIds.contains(expense.agencyId)) return false;
      if (_period == 'today' &&
          (expense.date.isBefore(todayStart) ||
              !expense.date.isBefore(
                todayStart.add(const Duration(days: 1)),
              ))) {
        return false;
      }
      if (_period == 'custom' &&
          (expense.date.isBefore(fromStart) || !expense.date.isBefore(toEnd))) {
        return false;
      }
      return true;
    }).toList();
  }

  String _periodLabel() {
    if (_period == 'today') return 'Today';
    if (_period == 'custom') {
      return '${_day.format(_from)} - ${_day.format(_to)}';
    }
    return 'All time';
  }

  void _reset() {
    setState(() {
      _dateAppliesTo = 'sold';
      _period = 'all';
      _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _to = DateTime.now();
      _stock = 'all';
      _document = 'all';
      _type = 'all';
      _dealer = 'all';
      _sort = 'date';
      _ascending = false;
    });
  }

  Future<void> _export(
    List<_ReportRow> rows,
    List<ExpenseModel> expenses, {
    required bool pdf,
  }) async {
    setState(() => _exporting = true);
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final content = pdf
        ? createTextPdf(_pdfLines(rows, expenses))
        : utf8.encode(_csv(rows, expenses));
    try {
      final path = await saveReportFile(
        'showroom_report_$stamp.${pdf ? 'pdf' : 'csv'}',
        content,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Report saved: $path')));
      }
    } catch (_) {
      if (!pdf) {
        await Clipboard.setData(ClipboardData(text: _csv(rows, expenses)));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pdf
                  ? 'This platform cannot save PDF files directly.'
                  : 'Saving is unavailable; CSV copied to clipboard.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _csv(List<_ReportRow> rows, List<ExpenseModel> expenses) {
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final summary = _ReportSummary.of(rows);
    final lines = <String>[
      csvLine([
        'Showroom report',
        _periodLabel(),
        'Date applies to',
        _dateAppliesTo,
      ]),
      csvLine([
        'Vehicles',
        'Sold',
        'Purchase',
        'Sales',
        'Gross profit',
        'Expenses',
        'Net profit',
      ]),
      csvLine([
        summary.count,
        summary.soldCount,
        summary.purchase,
        summary.sales,
        summary.gross,
        totalExpenses,
        summary.gross - totalExpenses,
      ]),
      '',
      csvLine([
        'Make',
        'Model',
        'Year',
        'Type',
        'Status',
        'Date',
        'Chassis / VIN',
        'Documents',
        'Dealer',
        'Purchase',
        'Sale',
        'Profit',
      ]),
      ...rows.map(
        (row) => csvLine([
          row.vehicle.make,
          row.vehicle.model,
          row.vehicle.year,
          row.vehicle.isZeroMeter ? 'New' : 'Used',
          row.sale == null ? 'In stock' : 'Sold',
          _day.format(row.date),
          row.vehicle.chassisNo ?? row.vehicle.vin,
          row.sale?.documentStatus ?? row.vehicle.documentStatus,
          row.sale?.dealerId,
          row.vehicle.priceAmount ?? 0,
          row.sale?.salePrice ?? 0,
          row.sale?.profit ?? 0,
        ]),
      ),
    ];
    return '\uFEFF${lines.join('\r\n')}';
  }

  List<String> _pdfLines(List<_ReportRow> rows, List<ExpenseModel> expenses) {
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final summary = _ReportSummary.of(rows);
    return [
      'SHOWROOM REPORT',
      'Period: ${_periodLabel()} | Date: $_dateAppliesTo | Type: $_type | Stock: $_stock',
      'Vehicles: ${summary.count} | Sold: ${summary.soldCount} | Purchase: ${_money.format(summary.purchase)}',
      'Sales: ${_money.format(summary.sales)} | Gross: ${_money.format(summary.gross)} | Expenses: ${_money.format(totalExpenses)} | Net: ${_money.format(summary.gross - totalExpenses)}',
      '',
      ...rows.expand(
        (row) => [
          '${row.vehicle.make} ${row.vehicle.model} ${row.vehicle.year} | ${row.vehicle.isZeroMeter ? 'New' : 'Used'} | ${row.sale == null ? 'Stock' : 'Sold'}',
          '${_day.format(row.date)} | ${row.vehicle.chassisNo ?? row.vehicle.vin} | Purchase ${_money.format(row.vehicle.priceAmount ?? 0)} | Sale ${_money.format(row.sale?.salePrice ?? 0)} | Profit ${_money.format(row.sale?.profit ?? 0)}',
        ],
      ),
    ];
  }
}

class _ReportRow {
  final VehicleModel vehicle;
  final SaleModel? sale;
  const _ReportRow(this.vehicle, this.sale);

  DateTime get date => sale?.saleDate ?? vehicle.createdAt;
}

class _ReportSummary {
  final int count;
  final int soldCount;
  final double purchase;
  final double sales;
  final double gross;
  final double stockValue;

  const _ReportSummary(
    this.count,
    this.soldCount,
    this.purchase,
    this.sales,
    this.gross,
    this.stockValue,
  );

  factory _ReportSummary.of(Iterable<_ReportRow> rows) {
    var soldCount = 0;
    var purchase = 0.0;
    var sales = 0.0;
    var gross = 0.0;
    var stockValue = 0.0;
    var count = 0;
    for (final row in rows) {
      count++;
      purchase += row.vehicle.priceAmount ?? 0;
      if (row.sale == null) {
        stockValue += row.vehicle.priceAmount ?? 0;
      } else {
        soldCount++;
        sales += row.sale!.salePrice;
        gross += row.sale!.profit;
      }
    }
    return _ReportSummary(count, soldCount, purchase, sales, gross, stockValue);
  }
}
