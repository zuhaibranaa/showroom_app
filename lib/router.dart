import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/admins/admin_invite_screen.dart';
import 'screens/admins/admins_screen.dart';
import 'screens/agencies/agency_add_screen.dart';
import 'screens/agencies/agency_list_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/auth/dealer_login_screen.dart';
import 'screens/auth/dealer_register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dealer/dealer_commission_screen.dart';
import 'screens/dealer/dealer_dashboard_screen.dart';
import 'screens/dealer/dealer_sales_screen.dart';
import 'screens/dealer/dealer_vehicles_screen.dart';
import 'screens/dealers/dealer_add_screen.dart';
import 'screens/dealers/dealer_detail_screen.dart';
import 'screens/dealers/dealer_list_screen.dart';
import 'screens/dealers/dealer_permissions_screen.dart';
import 'screens/profile/biometric_settings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sales/sale_add_screen.dart';
import 'screens/sales/sale_detail_screen.dart';
import 'screens/sales/sales_list_screen.dart';
import 'screens/vehicles/vehicle_add_screen.dart';
import 'screens/vehicles/vehicle_detail_screen.dart';
import 'screens/vehicles/vehicle_list_screen.dart';
import 'screens/expenses/expense_list_screen.dart';
import 'screens/expenses/expense_add_screen.dart';
import 'widgets/app_shell.dart';
import 'screens/tracking/documents_screen.dart';
import 'screens/tracking/biometrics_screen.dart';

import 'screens/receipts/receipt_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/options_screen.dart';
import 'screens/settings/retail_prices_screen.dart';
import 'screens/vehicle_services/registration_transfer_screen.dart';


/// Notifies [GoRouter] whenever the auth state or the signed-in user's
/// profile changes, so redirects can react to login/logout/role changes.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._ref) {
    _authSub = _ref.listen(currentUserStreamProvider, (_, next) {
      if (next.hasValue) _onAuthChanged(next.value);
    });
  }

  final Ref _ref;
  late final ProviderSubscription _authSub;
  ProviderSubscription? _profileSub;

  User? _user;
  String? _role;
  bool? _isAgencyOwner;
  bool? _isActive;
  bool? _mustChangePassword;

  User? get user => _user;
  String? get role => _role;
  bool get isLoggedIn => _user != null;
  bool get isDealer => _role == 'dealer';
  bool get isSuperAdmin => _role == 'super_admin';
  bool get isAgencyOwner => _isAgencyOwner == true;
  bool get isActive => _isActive == true;
  bool get mustChangePassword => _mustChangePassword == true;

  void _onAuthChanged(User? user) {
    _user = user;
    _role = null;
    _mustChangePassword = null;
    _profileSub?.close();
    _profileSub = null;
    if (user != null) {
      _profileSub = _ref.listen(userProfileStreamProvider(user.uid), (_, next) {
        if (next.hasValue) {
          _role = next.value?.role;
          _isAgencyOwner = next.value?.isAgencyOwner;
          _isActive = next.value?.isActive;
          _mustChangePassword = next.value?.mustChangePassword;
          notifyListeners();
        }
      });
      final current = _ref.read(userProfileStreamProvider(user.uid));
      if (current.hasValue) {
        _role = current.value?.role;
        _isAgencyOwner = current.value?.isAgencyOwner;
        _isActive = current.value?.isActive;
        _mustChangePassword = current.value?.mustChangePassword;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub.close();
    _profileSub?.close();
    super.dispose();
  }
}

final goRouterRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

const _authLocations = [
  '/login',
  '/register',
  '/dealer-login',
  '/dealer-register',
];

const _dealerLocations = [
  '/dealer-dashboard',
  '/dealer-sales',
  '/dealer-commission',
  '/dealer-vehicles',
];

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(goRouterRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = notifier.isLoggedIn;
      final isDealer = notifier.isDealer;
      final location = state.matchedLocation;
      final isAuthPage = _authLocations.contains(location);
      final isDealerRoute = _dealerLocations.contains(location);
      final isSuperAdminRoute =
          location.startsWith('/agencies') || location.startsWith('/admins');

      if (!isLoggedIn) {
        return isAuthPage ? null : '/login';
      }

      if (isAuthPage) {
        return '/dashboard';
      }

      // Deactivated users cannot access the app.
      if (!notifier.isActive) {
        return '/login';
      }

      // Dealer on a temporary password must change it before anything else.
      if (notifier.isDealer && notifier.mustChangePassword) {
        return location == '/change-password' ? null : '/change-password';
      }

      if (isDealer) {
        if (isDealerRoute) return null;
        if (location == '/profile' || location == '/biometric-settings') {
          return null;
        }
        return '/dealer-dashboard';
      }

      if (isDealerRoute) {
        return '/dashboard';
      }

      if (isSuperAdminRoute && !notifier.isSuperAdmin && !notifier.isAgencyOwner) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const MaterialPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            const MaterialPage(child: RegisterScreen()),
      ),
      GoRoute(
        path: '/dealer-login',
        pageBuilder: (context, state) =>
            const MaterialPage(child: DealerLoginScreen()),
      ),
      GoRoute(
        path: '/dealer-register',
        pageBuilder: (context, state) =>
            const MaterialPage(child: DealerRegisterScreen()),
      ),
      GoRoute(
        path: '/change-password',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ChangePasswordScreen()),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => DashboardScreen())),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => ProfileScreen())),
      ),
      GoRoute(
        path: '/biometric-settings',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => BiometricSettingsScreen())),
      ),
      GoRoute(
        path: '/vehicles',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => VehicleListScreen())),
      ),
      GoRoute(
        path: '/vehicles/add',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => VehicleAddScreen())),
      ),
      GoRoute(
        path: '/vehicles/:id',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => VehicleDetailScreen(vehicleId: state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/vehicles/:id/edit',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => VehicleAddScreen(id: state.pathParameters['id'])),
        ),
      ),
      GoRoute(
        path: '/sales',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => SalesListScreen())),
      ),
      GoRoute(
        path: '/sales/add',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => SaleAddScreen())),
      ),
      GoRoute(
        path: '/sales/:id',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => SaleDetailScreen(saleId: state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/sales/:id/edit',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => SaleAddScreen(id: state.pathParameters['id'])),
        ),
      ),
      GoRoute(
        path: '/dealers',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => DealerListScreen())),
      ),
      GoRoute(
        path: '/dealers/add',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => DealerAddScreen())),
      ),
      GoRoute(
        path: '/dealers/:id',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => DealerDetailScreen(dealerId: state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/dealers/:id/edit',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => DealerAddScreen(id: state.pathParameters['id'])),
        ),
      ),
      GoRoute(
        path: '/dealers/:id/permissions',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => DealerPermissionsScreen(dealerId: state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/agencies',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => AgencyListScreen())),
      ),
      GoRoute(
        path: '/agencies/add',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => AgencyAddScreen())),
      ),
      GoRoute(
        path: '/agencies/:id/edit',
        pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => AgencyAddScreen(id: state.pathParameters['id'])),
        ),
      ),
      GoRoute(
        path: '/admins',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => AdminsScreen())),
      ),
      GoRoute(
        path: '/admins/add',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => AdminInviteScreen())),
      ),
      GoRoute(
        path: '/dealer-dashboard',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => DealerDashboardScreen())),
      ),
      GoRoute(
        path: '/dealer-sales',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => DealerSalesScreen())),
      ),
      GoRoute(
        path: '/dealer-commission',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => DealerCommissionScreen())),
      ),
      GoRoute(
        path: '/dealer-vehicles',
        pageBuilder: (context, state) =>
            MaterialPage(child: AppShell(builder: (_) => DealerVehiclesScreen())),
      ),
      GoRoute(path: '/documents', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => DocumentsScreen()))),
      GoRoute(path: '/biometrics', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => BiometricsScreen()))),

      GoRoute(path: '/registration-transfer', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => RegistrationTransferScreen()))),
      GoRoute(path: '/reports', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => ReportsScreen()))),
      GoRoute(path: '/retail-prices', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => RetailPricesScreen()))),
      GoRoute(path: '/options', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => OptionsScreen()))),
      GoRoute(path: '/sales/:id/receipt', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => ReceiptScreen(saleId: state.pathParameters['id']!)))),
      GoRoute(path: '/expenses', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => const ExpenseListScreen()))),
      GoRoute(path: '/expenses/add', pageBuilder: (context, state) => MaterialPage(child: AppShell(builder: (_) => const ExpenseAddScreen()))),
    ],
  );
});
