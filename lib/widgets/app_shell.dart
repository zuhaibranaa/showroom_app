import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/access_provider.dart';
import '../providers/auth_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget? child;
  final Widget Function(BuildContext)? builder;
  final String title;

  const AppShell({super.key, this.child, this.builder, this.title = 'Showroom'});

  static const _items = [
    _NavigationItem('Dashboard', Icons.dashboard_outlined, '/dashboard'),
    _NavigationItem('Vehicles', Icons.two_wheeler_outlined, '/vehicles'),
    _NavigationItem('Sales', Icons.point_of_sale_outlined, '/sales'),
    _NavigationItem(
      'Pending payments',
      Icons.payments_outlined,
      '/sales',
    ),
    _NavigationItem('Documents', Icons.description_outlined, '/documents'),
    _NavigationItem('Biometrics', Icons.fingerprint_outlined, '/biometrics'),
    _NavigationItem('Expenses', Icons.receipt_long_outlined, '/expenses'),
    _NavigationItem(
      'Registration & transfer',
      Icons.app_registration_outlined,
      '/registration-transfer',
    ),
    _NavigationItem('Agencies', Icons.business_outlined, '/agencies'),
    _NavigationItem(
      'Reports',
      Icons.analytics_outlined,
      '/reports',
      staffOnly: true,
    ),
    _NavigationItem(
      'Admins',
      Icons.admin_panel_settings_outlined,
      '/admins',
      superAdminOnly: true,
    ),
    _NavigationItem(
      'Dealers',
      Icons.handshake_outlined,
      '/dealers',
      staffOnly: true,
    ),
    _NavigationItem(
      'Retail prices',
      Icons.sell_outlined,
      '/retail-prices',
      superAdminOnly: true,
    ),
    _NavigationItem(
      'Options',
      Icons.tune_outlined,
      '/options',
      superAdminOnly: true,
    ),
    _NavigationItem('Profile', Icons.person_outline, '/profile'),
  ];

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authServiceProvider).logout();
      if (context.mounted) context.go('/login');
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not sign out: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final isSuperAdmin = AccessService.isSuperAdmin(user);
    final isStaff = AccessService.isStaff(user);
    
    // Resolve the agency name for the drawer header.
    String agencyName = 'Showroom';
    final agencies = ref.watch(accessibleAgenciesProvider).valueOrNull;
    if (agencies != null && agencies.isNotEmpty) {
      agencyName = agencies.first.name;
    }

    final items = _items.where((item) {
      if (item.superAdminOnly) return isSuperAdmin;
      if (item.staffOnly) return isStaff;
      return true;
    }).toList();
    String location;
    try {
      location = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      location = '/dashboard';
    }
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final content = builder != null ? builder!(context) : child!;
    final scaffold = content is Scaffold ? content : null;
    final childAppBar = scaffold?.appBar is AppBar ? scaffold!.appBar as AppBar : null;
    final body = scaffold?.body ?? content;

    return Scaffold(
      appBar: AppBar(
        title: childAppBar?.title ?? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.two_wheeler, size: 26),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title == 'Showroom' ? agencyName : '$agencyName · $title',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          ...?childAppBar?.actions,
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        width: 310,
        child: SafeArea(
          child: Column(
            children: [
              _DrawerHeader(
                name: user?.username ?? 'Showroom',
                email: user?.email ?? '',
                role: isSuperAdmin ? 'Super admin' : (AccessService.isAgencyOwner(user) ? 'Agency owner' : 'Admin'),
                agencyName: agencyName,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final item in items)
                      ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.label),
                        selected: location == item.route,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          if (location != item.route) context.push(item.route);
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () {
                  Navigator.of(context).pop();
                  _signOut(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
      body: body,
      floatingActionButton: child is Scaffold ? (child as Scaffold).floatingActionButton : null,
      bottomNavigationBar: isMobile
          ? Builder(
              builder: (context) {
                final mobileItems = items.take(4).toList();
                var selectedIndex = mobileItems.indexWhere(
                  (item) => item.route == location,
                );
                if (selectedIndex < 0) selectedIndex = 4;
                return NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    if (index == 4) {
                      Scaffold.of(context).openDrawer();
                    } else {
                      context.go(mobileItems[index].route);
                    }
                  },
                  destinations: [
                    for (final item in mobileItems)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label == 'Pending payments'
                            ? 'Payments'
                            : item.label,
                      ),
                    const NavigationDestination(
                      icon: Icon(Icons.menu),
                      label: 'More',
                    ),
                  ],
                );
              },
            )
          : null,
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String agencyName;

  const _DrawerHeader({
    required this.name,
    required this.email,
    required this.role,
    required this.agencyName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: colors.primary,
      child: DefaultTextStyle(
        style: TextStyle(color: colors.onPrimary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.two_wheeler, size: 38),
            const SizedBox(height: 12),
            Text(
              agencyName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (email.isNotEmpty)
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(role, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  final String label;
  final IconData icon;
  final String route;
  final bool superAdminOnly;
  final bool staffOnly;

  const _NavigationItem(
    this.label,
    this.icon,
    this.route, {
    this.superAdminOnly = false,
    this.staffOnly = false,
  });
}
