import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../compat/model_converters.dart';
import '../providers/access_provider.dart';
import '../providers/auth_provider.dart' hide accessServiceProvider;

/// Gate that shows [child] only when the current user can [action]
/// (view/create/edit/delete) on [module] within their agency.
///
/// - Super admin / agency owner / staff: always see the child
///   (if the agency matches).
/// - Dealer: sees the child only if their stored RBAC bits allow [action].
///
/// Falls back to [fallback] (or an empty SizedBox) when access is denied.
class RbacGate extends ConsumerWidget {
  final String module; // e.g. 'vehicles', 'sales', 'expenses', ...
  final String action; // 'view' | 'create' | 'edit' | 'delete'
  final Widget child;
  final Widget? fallback;

  const RbacGate({
    super.key,
    required this.module,
    required this.action,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final agencyAsync = ref.watch(currentAgencyProvider);
    final accessService = ref.watch(accessServiceProvider);

    return agencyAsync.when(
      data: (agency) {
        if (user == null || agency == null) {
          return fallback ?? const SizedBox.shrink();
        }

        // Super admin can access everything.
        if (accessService.isSuperAdmin(userModelToEntity(user))) {
          return child;
        }

        // Staff / agency owner: must belong to the agency.
        if ((accessService.isStaff(userModelToEntity(user)) ||
                accessService.isAgencyOwner(userModelToEntity(user))) &&
            user.agencyIds.contains(agency.id)) {
          return child;
        }

        // Dealer: must belong to the agency AND have the RBAC bit.
        if (accessService.isDealer(userModelToEntity(user)) &&
            user.agencyId == agency.id) {
          final dealerId = user.id;
          final rbac = ref.watch(dealerRbacProvider(dealerId));
          final perm = rbac[module];
          if (perm != null) {
            final allowed = switch (action) {
              'view' => perm.view,
              'create' => perm.create,
              'edit' => perm.edit,
              'delete' => perm.edit, // reuse edit as delete
              _ => false,
            };
            if (allowed) return child;
          }
        }

        return fallback ?? const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => fallback ?? const SizedBox.shrink(),
    );
  }
}

/// Convenience gate for view access on a module.
class RbacViewGate extends RbacGate {
  const RbacViewGate({
    super.key,
    required super.module,
    required super.child,
    super.fallback,
  }) : super(action: 'view');
}

/// Convenience gate for create access on a module.
class RbacCreateGate extends RbacGate {
  const RbacCreateGate({
    super.key,
    required super.module,
    required super.child,
    super.fallback,
  }) : super(action: 'create');
}

/// Convenience gate for edit access on a module.
class RbacEditGate extends RbacGate {
  const RbacEditGate({
    super.key,
    required super.module,
    required super.child,
    super.fallback,
  }) : super(action: 'edit');
}

/// Convenience gate for delete access on a module.
class RbacDeleteGate extends RbacGate {
  const RbacDeleteGate({
    super.key,
    required super.module,
    required super.child,
    super.fallback,
  }) : super(action: 'delete');
}
