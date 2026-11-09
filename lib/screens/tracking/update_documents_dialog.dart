import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/reference_options.dart';
import '../../models/operations_models.dart';
import '../../models/vehicle_model.dart';
import '../../providers/operations_provider.dart';
import 'tracking_utils.dart';

class UpdateDocumentsDialog extends ConsumerStatefulWidget {
  final VehicleModel vehicle;
  final String changedBy;

  const UpdateDocumentsDialog({
    super.key,
    required this.vehicle,
    this.changedBy = '',
  });

  static Future<bool?> show(
    BuildContext context,
    VehicleModel vehicle, {
    String changedBy = '',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) =>
          UpdateDocumentsDialog(vehicle: vehicle, changedBy: changedBy),
    );
  }

  @override
  ConsumerState<UpdateDocumentsDialog> createState() =>
      _UpdateDocumentsDialogState();
}

class _UpdateDocumentsDialogState extends ConsumerState<UpdateDocumentsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _remarksController;
  late final TextEditingController _registeredFromController;
  late final TextEditingController _numberPlateController;
  late final TextEditingController _registrationBookController;
  late String _status;
  late String? _registrationStatus;
  late DateTime _statusDate;
  late Set<String> _checklist;
  bool _saving = false;
  bool _historyInitialized = false;

  List<String> get _checklistOptions => widget.vehicle.isZeroMeter
      ? ReferenceOptions.newChecklist
      : ReferenceOptions.usedChecklist;

  bool get _statusChanged =>
      _status != (widget.vehicle.documentStatus ?? 'PENDING');

  @override
  void initState() {
    super.initState();
    _status = widget.vehicle.documentStatus ?? 'PENDING';
    _registrationStatus = widget.vehicle.registrationStatus;
    _statusDate = DateTime.now();
    _remarksController = TextEditingController(text: widget.vehicle.remarks);
    _registeredFromController = TextEditingController(
      text: widget.vehicle.registeredFrom,
    );
    _numberPlateController = TextEditingController(
      text: widget.vehicle.plateNo ?? widget.vehicle.registrationNo,
    );
    _registrationBookController = TextEditingController();
    _checklist = <String>{};
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _registeredFromController.dispose();
    _numberPlateController.dispose();
    _registrationBookController.dispose();
    super.dispose();
  }

  void _initializeHistory(List<DocumentHistoryModel> history) {
    if (_historyInitialized || history.isEmpty) return;
    _historyInitialized = true;
    final latest = [...history]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final item = latest.first;
    _registrationBookController.text = item.registrationBook ?? '';
    _checklist = item.checklist.toSet();
    if ((_registrationStatus == null || _registrationStatus!.isEmpty) &&
        item.registrationStatus != null) {
      _registrationStatus = item.registrationStatus;
    }
    if (_registeredFromController.text.isEmpty) {
      _registeredFromController.text = item.registeredFrom ?? '';
    }
    if (_numberPlateController.text.isEmpty) {
      _numberPlateController.text = item.numberPlate ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final history = DocumentHistoryModel(
      vehicleId: widget.vehicle.id,
      status: _status,
      statusDate: _statusChanged ? _statusDate : widget.vehicle.updatedAt,
      changedBy: widget.changedBy,
      remarks: _remarksController.text.trim(),
      registrationStatus: _registrationStatus,
      registeredFrom: _registeredFromController.text.trim(),
      numberPlate: _numberPlateController.text.trim(),
      registrationBook: _registrationBookController.text.trim(),
      checklist: _checklistOptions.where(_checklist.contains).toList(),
      createdAt: DateTime.now(),
    );
    try {
      await ref.read(operationsServiceProvider).updateDocuments(history);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        showTrackingError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(documentHistoryProvider(widget.vehicle.id));
    history.whenData(_initializeHistory);

    return AlertDialog(
      title: Text(
        'Update documents — ${widget.vehicle.make} ${widget.vehicle.model}',
      ),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue:
                      ReferenceOptions.documentStatuses.containsKey(_status)
                      ? _status
                      : 'PENDING',
                  decoration: const InputDecoration(
                    labelText: 'Document status',
                    border: OutlineInputBorder(),
                  ),
                  items: ReferenceOptions.documentStatuses.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() {
                          _status = value!;
                          if (_statusChanged) _statusDate = DateTime.now();
                        }),
                ),
                if (_statusChanged) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Status change date',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                      helperText:
                          'Required because the document status changed',
                    ),
                    controller: TextEditingController(
                      text: trackingDate(_statusDate),
                    ),
                    onTap: _saving
                        ? null
                        : () async {
                            final date = await pickTrackingDate(
                              context,
                              initialDate: _statusDate,
                            );
                            if (date != null) {
                              setState(() => _statusDate = date);
                            }
                          },
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarksController,
                  enabled: !_saving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Remarks',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Document checklist',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                ..._checklistOptions.map(
                  (item) => CheckboxListTile(
                    value: _checklist.contains(item),
                    onChanged: _saving
                        ? null
                        : (checked) => setState(() {
                            if (checked == true) {
                              _checklist.add(item);
                            } else {
                              _checklist.remove(item);
                            }
                          }),
                    title: Text(item),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.vehicle.isZeroMeter
                      ? 'New registration'
                      : 'Registration details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _registrationStatus,
                  decoration: const InputDecoration(
                    labelText: 'Registration status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Not set'),
                    ),
                    ...ReferenceOptions.registrationStatuses.entries.map(
                      (entry) => DropdownMenuItem<String?>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _registrationStatus = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _registeredFromController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Registered from',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _numberPlateController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Number plate',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _registrationBookController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Registration book',
                    border: OutlineInputBorder(),
                    hintText: 'Book number or status',
                  ),
                ),
                const SizedBox(height: 12),
                history.when(
                  data: (items) => TextButton.icon(
                    onPressed: () =>
                        showDocumentHistory(context, widget.vehicle, items),
                    icon: const Icon(Icons.history),
                    label: Text('View history (${items.length})'),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text('History unavailable: $error'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Saving…' : 'Save update'),
        ),
      ],
    );
  }
}

Future<void> showDocumentHistory(
  BuildContext context,
  VehicleModel vehicle,
  List<DocumentHistoryModel> history,
) {
  final items = [...history]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Document history — ${vehicle.make} ${vehicle.model}'),
      content: SizedBox(
        width: 600,
        height: 480,
        child: items.isEmpty
            ? const TrackingEmptyView(
                title: 'No history yet',
                message: 'Document updates will appear here.',
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ReferenceOptions.label(
                                ReferenceOptions.documentStatuses,
                                item.status,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(trackingDate(item.statusDate)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Recorded ${trackingDate(item.createdAt)}'),
                      if (item.changedBy.isNotEmpty)
                        Text('By ${item.changedBy}'),
                      if (item.remarks?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(item.remarks!),
                        ),
                      if (item.checklist.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Checklist: ${item.checklist.join(', ')}',
                          ),
                        ),
                      if (item.registrationStatus != null)
                        Text(
                          'Registration: ${ReferenceOptions.label(ReferenceOptions.registrationStatuses, item.registrationStatus)}',
                        ),
                      if (item.registeredFrom?.isNotEmpty == true)
                        Text('From: ${item.registeredFrom}'),
                      if (item.numberPlate?.isNotEmpty == true)
                        Text('Plate: ${item.numberPlate}'),
                      if (item.registrationBook?.isNotEmpty == true)
                        Text('Book: ${item.registrationBook}'),
                    ],
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
