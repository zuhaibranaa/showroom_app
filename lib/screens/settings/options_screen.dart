import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/operations_models.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/operations_provider.dart';
import 'option_merge.dart';

class OptionsScreen extends ConsumerStatefulWidget {
  const OptionsScreen({super.key});

  @override
  ConsumerState<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends ConsumerState<OptionsScreen> {
  String _kind = 'make';
  String _makeFilter = '';
  String _scopeFilter = '';

  static const _scopesByKind = <String, List<String>>{
    'expense_category': ['bike', 'showroom'],
    'checklist': ['new', 'used'],
  };

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final storedAsync = ref.watch(appOptionsProvider);

    if (userAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!AccessService.isSuperAdmin(user)) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Only the owner can manage options.'),
          ),
        ),
      );
    }

    final stored = storedAsync.valueOrNull ?? const <AppOptionModel>[];
    final merged = mergeOptions(stored);
    final makes = optionNames(stored, 'make');

    final items =
        merged.where((item) {
          if (item.kind != _kind) return false;
          if (_kind == 'model' &&
              _makeFilter.isNotEmpty &&
              item.make != _makeFilter) {
            return false;
          }
          if ((_kind == 'expense_category' || _kind == 'checklist') &&
              _scopeFilter.isNotEmpty &&
              item.scope != _scopeFilter) {
            return false;
          }
          return true;
        }).toList()..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, stored, null),
        icon: const Icon(Icons.add),
        label: Text('Add ${optionKinds[_kind] ?? _kind}'),
      ),
      body: storedAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : storedAsync.hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load options: ${storedAsync.error}'),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _kind,
                          decoration: const InputDecoration(
                            labelText: 'Option type',
                            border: OutlineInputBorder(),
                          ),
                          items: optionKinds.entries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _kind = value;
                              _makeFilter = '';
                              _scopeFilter = '';
                            });
                          },
                        ),
                      ),
                      if (_kind == 'model')
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<String>(
                            initialValue: _makeFilter.isEmpty
                                ? null
                                : _makeFilter,
                            decoration: const InputDecoration(
                              labelText: 'Make',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('All makes'),
                              ),
                              ...makes.map(
                                (make) => DropdownMenuItem(
                                  value: make,
                                  child: Text(make),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _makeFilter = value ?? ''),
                          ),
                        ),
                      if (_kind == 'expense_category' || _kind == 'checklist')
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<String>(
                            initialValue: _scopeFilter.isEmpty
                                ? null
                                : _scopeFilter,
                            decoration: const InputDecoration(
                              labelText: 'Scope',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('All scopes'),
                              ),
                              ...(_scopesByKind[_kind] ?? const <String>[]).map(
                                (scope) => DropdownMenuItem(
                                  value: scope,
                                  child: Text(_scopeLabel(scope)),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _scopeFilter = value ?? ''),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No options found.'),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final option = items[index];
                            return _OptionTile(
                              option: option,
                              onToggle: (value) =>
                                  _toggleVisibility(option, value),
                              onEdit: () =>
                                  _showEditor(context, stored, option),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _toggleVisibility(DisplayOption option, bool visible) async {
    try {
      final model = option.toModel(visible: visible);
      await ref
          .read(operationsServiceProvider)
          .saveOption(model, id: option.id.isEmpty ? null : option.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update visibility: $error')),
        );
      }
    }
  }

  Future<void> _showEditor(
    BuildContext context,
    List<AppOptionModel> stored,
    DisplayOption? existing,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    var scope = existing?.scope ?? _defaultScope(_kind);
    var make = existing?.make ?? '';
    var saving = false;
    String? error;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final makes = optionNames(stored, 'make');
          if (make.isNotEmpty && !makes.contains(make)) makes.add(make);
          final needsScope =
              _kind == 'expense_category' || _kind == 'checklist';
          final needsMake = _kind == 'model';

          return AlertDialog(
            title: Text(existing == null ? 'Add option' : 'Edit option'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      enabled: !saving,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        final merged = mergeOptions(stored);
                        final duplicate = merged.any(
                          (item) =>
                              item.kind == _kind &&
                              item.scope.trim().toLowerCase() ==
                                  scope.trim().toLowerCase() &&
                              item.make.trim().toLowerCase() ==
                                  make.trim().toLowerCase() &&
                              item.name.trim().toLowerCase() ==
                                  value.trim().toLowerCase() &&
                              item != existing,
                        );
                        if (duplicate) {
                          return 'This option already exists';
                        }
                        return null;
                      },
                    ),
                    if (needsScope) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: scope.isEmpty ? null : scope,
                        decoration: const InputDecoration(
                          labelText: 'Scope',
                          border: OutlineInputBorder(),
                        ),
                        items: (_scopesByKind[_kind] ?? const <String>[])
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(_scopeLabel(value)),
                              ),
                            )
                            .toList(),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Select a scope'
                            : null,
                        onChanged: saving
                            ? null
                            : (value) =>
                                  setDialogState(() => scope = value ?? ''),
                      ),
                    ],
                    if (needsMake) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: make.isEmpty ? null : make,
                        decoration: const InputDecoration(
                          labelText: 'Make',
                          border: OutlineInputBorder(),
                        ),
                        items: makes
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Select a make'
                            : null,
                        onChanged: saving
                            ? null
                            : (value) =>
                                  setDialogState(() => make = value ?? ''),
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          final newName = nameController.text.trim();
                          final newScope = needsScope ? scope : '';
                          final newMake = needsMake ? make : '';

                          final identityChanged =
                              existing != null &&
                              existing.isDefault &&
                              (newName.toLowerCase() !=
                                      existing.name.toLowerCase() ||
                                  newScope.toLowerCase() !=
                                      existing.scope.toLowerCase() ||
                                  newMake.toLowerCase() !=
                                      existing.make.toLowerCase());

                          if (identityChanged) {
                            final hiddenModel = AppOptionModel(
                              kind: _kind,
                              name: existing.name,
                              scope: existing.scope,
                              make: existing.make,
                              visible: false,
                            );
                            await ref
                                .read(operationsServiceProvider)
                                .saveOption(
                                  hiddenModel,
                                  id: existing.id.isEmpty ? null : existing.id,
                                );
                            await ref
                                .read(operationsServiceProvider)
                                .saveOption(
                                  AppOptionModel(
                                    kind: _kind,
                                    name: newName,
                                    scope: newScope,
                                    make: newMake,
                                    visible: existing.visible,
                                  ),
                                );
                          } else if (existing != null &&
                              existing.id.isNotEmpty) {
                            await ref
                                .read(operationsServiceProvider)
                                .saveOption(
                                  AppOptionModel(
                                    id: existing.id,
                                    kind: _kind,
                                    name: newName,
                                    scope: newScope,
                                    make: newMake,
                                    visible: existing.visible,
                                  ),
                                  id: existing.id,
                                );
                          } else if (existing != null) {
                            if (newName.toLowerCase() !=
                                existing.name.toLowerCase()) {
                              await ref
                                  .read(operationsServiceProvider)
                                  .saveOption(
                                    AppOptionModel(
                                      kind: _kind,
                                      name: newName,
                                      scope: newScope,
                                      make: newMake,
                                      visible: existing.visible,
                                    ),
                                  );
                            }
                          } else {
                            await ref
                                .read(operationsServiceProvider)
                                .saveOption(
                                  AppOptionModel(
                                    kind: _kind,
                                    name: newName,
                                    scope: newScope,
                                    make: newMake,
                                    visible: true,
                                  ),
                                );
                          }
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } catch (exception) {
                          setDialogState(() {
                            saving = false;
                            error = 'Could not save: $exception';
                          });
                        }
                      },
                child: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    nameController.dispose();
  }

  String _defaultScope(String kind) {
    switch (kind) {
      case 'expense_category':
        return 'bike';
      case 'checklist':
        return 'new';
      default:
        return '';
    }
  }

  String _scopeLabel(String scope) {
    switch (scope) {
      case 'bike':
        return 'Bike';
      case 'showroom':
        return 'Showroom';
      case 'new':
        return 'New';
      case 'used':
        return 'Used';
      default:
        return scope;
    }
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.onToggle,
    required this.onEdit,
  });

  final DisplayOption option;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          option.visible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: option.visible ? null : Theme.of(context).disabledColor,
        ),
        title: Text(
          option.name,
          style: TextStyle(
            color: option.visible ? null : Theme.of(context).disabledColor,
            decoration: option.visible ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(_subtitle(option)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.isDefault)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text('Default'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            Switch(value: option.visible, onChanged: onToggle),
            IconButton(
              tooltip: 'Rename / edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(DisplayOption option) {
    final parts = <String>[];
    if (option.make.isNotEmpty) parts.add('Make: ${option.make}');
    if (option.scope.isNotEmpty) {
      parts.add('Scope: ${_scopeLabelStatic(option.scope)}');
    }
    if (parts.isEmpty) parts.add('Custom option');
    return parts.join(' · ');
  }

  String _scopeLabelStatic(String scope) {
    switch (scope) {
      case 'bike':
        return 'Bike';
      case 'showroom':
        return 'Showroom';
      case 'new':
        return 'New';
      case 'used':
        return 'Used';
      default:
        return scope;
    }
  }
}
