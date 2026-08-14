import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/agency_model.dart';
import '../../models/user_model.dart';
import '../../providers/access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dealer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/custom_card.dart';

const _allAgencies = '__all__';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _agencyFilter = _allAgencies;

  void _resolveDefaultAgency(List<AgencyModel> agencies, UserModel user) {
    if (agencies.isEmpty) return;
    if (_agencyFilter != _allAgencies) return;
    if (AccessService.isSuperAdmin(user)) {
      _agencyFilter = _allAgencies;
    } else if (user.agencyIds.isNotEmpty) {
      _agencyFilter = user.agencyIds.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final user = currentUserAsync.value;
    final agencies = ref.watch(accessibleAgenciesProvider);
    final agencyList = agencies.value;
    if (agencyList != null && user != null) {
      _resolveDefaultAgency(agencyList, user);
    }

    final isAll = _agencyFilter == _allAgencies;
    final vehicles = isAll
        ? ref.watch(vehiclesProvider)
        : ref.watch(vehiclesByAgencyProvider(_agencyFilter));
    final sales = isAll
        ? ref.watch(salesProvider)
        : ref.watch(salesByAgencyProvider(_agencyFilter));
    final dealers = isAll
        ? ref.watch(dealersProvider)
        : ref.watch(dealersByAgencyProvider(_agencyFilter));
    final totalProfit = isAll
        ? ref.watch(totalProfitProvider)
        : ref.watch(totalProfitByAgencyProvider(_agencyFilter));

    final isSuperAdmin = AccessService.isSuperAdmin(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: currentUserAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? Center(
                  child: Text(
                    currentUserAsync.hasError
                        ? 'Error loading your profile. Please try again.'
                        : 'Your profile was not found. Please contact the '
                            'super admin.',
                  ),
                )
              : RefreshIndicator(
              onRefresh: () async {
                if (isAll) {
                  await Future.wait([
                    ref.refresh(vehiclesProvider.future),
                    ref.refresh(salesProvider.future),
                    ref.refresh(dealersProvider.future),
                    ref.refresh(totalProfitProvider.future),
                  ]);
                } else {
                  await Future.wait([
                    ref.refresh(vehiclesByAgencyProvider(_agencyFilter).future),
                    ref.refresh(salesByAgencyProvider(_agencyFilter).future),
                    ref.refresh(dealersByAgencyProvider(_agencyFilter).future),
                    ref
                        .refresh(totalProfitByAgencyProvider(_agencyFilter).future),
                  ]);
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.username}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSuperAdmin ? 'Super Admin' : 'Admin',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    _AgencySelector(
                      agencies: agencyList ?? const [],
                      isSuperAdmin: isSuperAdmin,
                      selected: _agencyFilter,
                      onChanged: (value) => setState(() {
                        _agencyFilter = value;
                      }),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _statCard(
                          title: 'Vehicles',
                          value: vehicles.valueOrNull?.length.toString() ?? '...',
                          icon: Icons.directions_car,
                          color: Colors.blue,
                          onTap: () => context.push('/vehicles'),
                        ),
                        _statCard(
                          title: 'Sales',
                          value: sales.valueOrNull?.length.toString() ?? '...',
                          icon: Icons.shopping_cart,
                          color: Colors.green,
                          onTap: () => context.push('/sales'),
                        ),
                        _statCard(
                          title: 'Dealers',
                          value: dealers.valueOrNull?.length.toString() ?? '...',
                          icon: Icons.people,
                          color: Colors.orange,
                          onTap: () => context.push('/dealers'),
                        ),
                        _statCard(
                          title: 'Total Profit',
                          value: totalProfit.valueOrNull == null
                              ? '...'
                              : '\$${totalProfit.valueOrNull!.toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                          color: Colors.purple,
                          onTap: () => context.push('/sales'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          _ActionButton(
                            label: 'Add Vehicle',
                            icon: Icons.add_circle,
                            onTap: () => context.push('/vehicles/add'),
                          ),
                          const SizedBox(height: 12),
                          _ActionButton(
                            label: 'Record Sale',
                            icon: Icons.add_shopping_cart,
                            onTap: () => context.push('/sales/add'),
                          ),
                          const SizedBox(height: 12),
                          _ActionButton(
                            label: 'Add Dealer',
                            icon: Icons.person_add,
                            onTap: () => context.push('/dealers/add'),
                          ),
                          if (isSuperAdmin) ...[
                            const SizedBox(height: 12),
                            _ActionButton(
                              label: 'Manage Agencies',
                              icon: Icons.business,
                              onTap: () => context.push('/agencies'),
                            ),
                            const SizedBox(height: 12),
                            _ActionButton(
                              label: 'Manage Admins',
                              icon: Icons.admin_panel_settings,
                              onTap: () => context.push('/admins'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}

class _AgencySelector extends StatelessWidget {
  final List<AgencyModel> agencies;
  final bool isSuperAdmin;
  final String selected;
  final ValueChanged<String> onChanged;

  const _AgencySelector({
    required this.agencies,
    required this.isSuperAdmin,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (agencies.isEmpty) {
      return const Text('No agencies yet.');
    }
    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Agency',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business_outlined),
      ),
      items: [
        if (isSuperAdmin)
          const DropdownMenuItem(
            value: _allAgencies,
            child: Text('All Agencies'),
          ),
        ...agencies.map(
          (a) => DropdownMenuItem(
            value: a.id,
            child: Text(a.name),
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
