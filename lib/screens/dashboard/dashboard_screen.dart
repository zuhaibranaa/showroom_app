import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/agency_model.dart';
import '../../models/user_model.dart';
import '../../models/vehicle_model.dart';
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
    final isSuperAdmin = AccessService.isSuperAdmin(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Showroom'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {},
          ),
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
                      ]);
                    } else {
                      await Future.wait([
                        ref.refresh(vehiclesByAgencyProvider(_agencyFilter).future),
                        ref.refresh(salesByAgencyProvider(_agencyFilter).future),
                        ref.refresh(dealersByAgencyProvider(_agencyFilter).future),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stat cards grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _statCard(
                              title: 'New Bikes',
                              value: _countZeroMeterVehicles(
                                vehicles.valueOrNull,
                              ).toString(),
                              icon: Icons.add_circle_outline,
                              color: Colors.green,
                              onTap: () => context.push('/vehicles/add'),
                            ),
                            _statCard(
                              title: 'Used Bikes',
                              value: _countUsedVehicles(
                                vehicles.valueOrNull,
                              ).toString(),
                              icon: Icons.directions_car,
                              color: Colors.amber,
                              onTap: () => context.push('/vehicles/add'),
                            ),
                            _statCard(
                              title: 'Udhaar Bikes',
                              value: _countPendingDocs(
                                vehicles.valueOrNull,
                              ).toString(),
                              icon: Icons.payment,
                              color: Colors.lime,
                              onTap: () => context.push('/vehicles'),
                            ),
                            _statCard(
                              title: 'Sold Bikes',
                              value: sales.valueOrNull?.length.toString() ?? '...',
                              icon: Icons.check_circle,
                              color: Colors.red,
                              onTap: () => context.push('/sales'),
                            ),
                            _statCard(
                              title: 'Pending Docs',
                              value: _countPendingDocs(
                                vehicles.valueOrNull,
                              ).toString(),
                              icon: Icons.description,
                              color: Colors.purple,
                              onTap: () => context.push('/vehicles'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Quick Actions
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
                                onTap: () => _showAddBikeBottomSheet(context),
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

  int _countZeroMeterVehicles(List<VehicleModel>? vehicles) {
    if (vehicles == null) return 0;
    return vehicles.where((v) => v.isZeroMeter == true).length;
  }

  int _countUsedVehicles(List<VehicleModel>? vehicles) {
    if (vehicles == null) return 0;
    return vehicles.where((v) => v.isZeroMeter != true).length;
  }

  int _countPendingDocs(List<VehicleModel>? vehicles) {
    if (vehicles == null) return 0;
    return vehicles.where((v) => v.documentStatus != null && v.documentStatus!.isNotEmpty && v.documentStatus != 'Applied').length;
  }

  void _showAddBikeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.add_business, size: 28),
                SizedBox(width: 12),
                Text(
                  'Add Bike',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.green),
              title: const Text('Zero Meter Bike'),
              onTap: () {
                Navigator.pop(context);
                context.push('/vehicles/add?type=zero_meter');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.amber),
              title: const Text('Used Bike'),
              onTap: () {
                Navigator.pop(context);
                context.push('/vehicles/add?type=used');
              },
            ),
          ],
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
