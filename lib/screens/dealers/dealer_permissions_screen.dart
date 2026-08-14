import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/dealer_permissions.dart';
import '../../providers/dealer_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_and_error.dart';

class DealerPermissionsScreen extends ConsumerStatefulWidget {
  final String dealerId;

  const DealerPermissionsScreen({super.key, required this.dealerId});

  @override
  ConsumerState<DealerPermissionsScreen> createState() =>
      _DealerPermissionsScreenState();
}

class _DealerPermissionsScreenState
    extends ConsumerState<DealerPermissionsScreen> {
  DealerPermissions? _draft;
  bool _loaded = false;

  void _load(DealerPermissions permissions) {
    if (_loaded) return;
    _draft = permissions;
    _loaded = true;
  }

  Future<void> _save() async {
    final dealer = ref.read(dealerByIdProvider(widget.dealerId)).value;
    if (dealer == null || _draft == null) return;
    await ref.read(updateDealerProvider.notifier).updateDealer(
          widget.dealerId,
          dealer.copyWith(permissions: _draft),
        );
  }

  @override
  Widget build(BuildContext context) {
    final dealer = ref.watch(dealerByIdProvider(widget.dealerId));
    final updateState = ref.watch(updateDealerProvider);
    final data = dealer.value;
    if (data != null) {
      _load(data.permissions);
    }

    ref.listen(updateDealerProvider, (_, state) {
      if (!_loaded) return;
      state.when(
        data: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permissions saved')),
            );
            ref.invalidate(dealerByIdProvider(widget.dealerId));
            context.pop();
          }
        },
        error: (error, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          }
        },
        loading: () {},
      );
    });

    final draft = _draft;

    return Scaffold(
      appBar: AppBar(title: const Text('Dealer Permissions'), elevation: 0),
      body: data == null || draft == null
          ? dealer.when(
              loading: () => const LoadingWidget(message: 'Loading dealer...'),
              error: (error, _) => ErrorView(message: error.toString()),
              data: (_) => const LoadingWidget(message: 'Loading dealer...'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control what this dealer can do in the app.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  _ModulePermissionsCard(
                    title: 'Vehicles',
                    icon: Icons.directions_car,
                    permission: draft.vehicles,
                    onChanged: (p) =>
                        setState(() => _draft = draft.copyWith(vehicles: p)),
                  ),
                  const SizedBox(height: 12),
                  _ModulePermissionsCard(
                    title: 'Sales',
                    icon: Icons.shopping_cart,
                    permission: draft.sales,
                    onChanged: (p) =>
                        setState(() => _draft = draft.copyWith(sales: p)),
                  ),
                  const SizedBox(height: 12),
                  _ModulePermissionsCard(
                    title: 'Dealers',
                    icon: Icons.people,
                    permission: draft.dealers,
                    onChanged: (p) =>
                        setState(() => _draft = draft.copyWith(dealers: p)),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Save Permissions',
                    isLoading: updateState.isLoading,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}

class _ModulePermissionsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ModulePermission permission;
  final ValueChanged<ModulePermission> onChanged;

  const _ModulePermissionsCard({
    required this.title,
    required this.icon,
    required this.permission,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: Colors.blue),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                _PermissionCheckbox(
                  label: 'View',
                  value: permission.view,
                  onChanged: (v) =>
                      onChanged(permission.copyWith(view: v)),
                ),
                _PermissionCheckbox(
                  label: 'Create',
                  value: permission.create,
                  onChanged: (v) =>
                      onChanged(permission.copyWith(create: v)),
                ),
                _PermissionCheckbox(
                  label: 'Edit',
                  value: permission.edit,
                  onChanged: (v) => onChanged(permission.copyWith(edit: v)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontSize: 13)),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }
}
