import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/dealer_service.dart';
import '../services/user_service.dart';
import 'dealer_provider.dart';

// Auth Service Provider
final authServiceProvider = Provider((ref) => AuthService());

// User Service Provider
final userServiceProvider = Provider((ref) => UserService());

// Current User Stream Provider
final currentUserStreamProvider = StreamProvider((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// User Profile Provider
final userProfileProvider = FutureProvider.family((ref, String uid) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getUserProfile(uid);
});

// User Profile Stream Provider
final userProfileStreamProvider =
    StreamProvider.family<UserModel?, String>((ref, uid) {
  final userService = ref.watch(userServiceProvider);
  return userService.userProfileStream(uid);
});

// Current signed-in user's profile document
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUserStreamProvider).value?.uid;
  if (uid == null) {
    return Stream.value(null);
  }
  final userService = ref.watch(userServiceProvider);
  return userService.userProfileStream(uid);
});

// Login State Provider (staff login: super admin / admin)
final loginStateProvider =
    StateNotifierProvider<LoginStateNotifier, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginStateNotifier(authService);
});

class LoginStateNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  LoginStateNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.loginWithEmail(
        email: email,
        password: password,
      ),
    );
  }
}

// Registration State Provider.
// The super admin is set up manually (seeded in Firestore); every registration
// via the app requires a matching admin invite (created by the super admin)
// and creates an admin profile with the invite's agencies.
final registrationStateProvider =
    StateNotifierProvider<RegisterStateNotifier, AsyncValue<void>>((ref) {
  return RegisterStateNotifier(
    ref.watch(authServiceProvider),
    ref.watch(userServiceProvider),
  );
});

class RegisterStateNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final UserService _userService;

  RegisterStateNotifier(this._authService, this._userService)
      : super(const AsyncValue.data(null));

  Future<void> register({
    required String email,
    required String password,
    String? username,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final now = DateTime.now();

      final invite = await _userService.getAdminInvite(email);
      if (invite == null) {
        await _authService.logout();
        throw Exception(
          'No admin invite found for this email. '
          'Ask the super admin to invite you first.',
        );
      }
      final agencyIds = (invite['agencyIds'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      final inviteName = (invite['name'] as String?)?.trim();
      await _userService.createUserProfile(
        uid,
        UserModel(
          id: uid,
          email: email,
          username: (inviteName != null && inviteName.isNotEmpty)
              ? inviteName
              : (username ?? email.split('@').first),
          role: UserRole.admin.value,
          agencyIds: agencyIds,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _userService.deleteAdminInvite(email);
    });
  }
}

// Dealer Login State Provider
final dealerLoginStateProvider =
    StateNotifierProvider<DealerLoginStateNotifier, AsyncValue<void>>((ref) {
  return DealerLoginStateNotifier(
    ref.watch(authServiceProvider),
    ref.watch(dealerServiceProvider),
    ref.watch(userServiceProvider),
  );
});

class DealerLoginStateNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final DealerService _dealerService;
  final UserService _userService;

  DealerLoginStateNotifier(
    this._authService,
    this._dealerService,
    this._userService,
  ) : super(const AsyncValue.data(null));

  Future<void> dealerLogin({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final credential = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Login failed. Please try again.');

      final dealer = await _dealerService.getDealerByEmail(email);
      if (dealer == null) {
        await _authService.logout();
        throw Exception(
          'No dealer account found for this email. '
          'Please ask the showroom to add you.',
        );
      }

      await _dealerService.linkDealerToUser(
        dealer.id,
        user.uid,
      );

      final now = DateTime.now();
      try {
        final existing = await _userService.getUserProfile(user.uid);
        await _userService.updateUserProfile(
          user.uid,
          existing.copyWith(
            role: UserRole.dealer.value,
            agencyId: dealer.agencyId,
            updatedAt: now,
          ),
        );
      } catch (_) {
        await _userService.createUserProfile(
          user.uid,
          UserModel(
            id: user.uid,
            email: email,
            username: dealer.name,
            role: UserRole.dealer.value,
            agencyId: dealer.agencyId,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    });
  }
}

// Dealer Registration State Provider
final dealerRegistrationStateProvider =
    StateNotifierProvider<DealerRegistrationStateNotifier, AsyncValue<void>>(
        (ref) {
  return DealerRegistrationStateNotifier(
    ref.watch(authServiceProvider),
    ref.watch(dealerServiceProvider),
    ref.watch(userServiceProvider),
  );
});

class DealerRegistrationStateNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final DealerService _dealerService;
  final UserService _userService;

  DealerRegistrationStateNotifier(
    this._authService,
    this._dealerService,
    this._userService,
  ) : super(const AsyncValue.data(null));

  Future<void> registerDealer({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dealer = await _dealerService.getDealerByEmail(email);
      if (dealer == null) {
        throw Exception(
          'No dealer record found for this email. '
          'Ask the showroom to add you first.',
        );
      }

      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      await _dealerService.linkDealerToUser(
        dealer.id,
        user.uid,
      );

      final now = DateTime.now();
      await _userService.createUserProfile(
        user.uid,
        UserModel(
          id: user.uid,
          email: email,
          username: dealer.name,
          role: UserRole.dealer.value,
          agencyId: dealer.agencyId,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }
}

// Change password state (used by dealers on first login)
final changePasswordStateProvider =
    StateNotifierProvider<ChangePasswordNotifier, AsyncValue<void>>((ref) {
  return ChangePasswordNotifier(
    ref.watch(authServiceProvider),
    ref.watch(userServiceProvider),
  );
});

class ChangePasswordNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final UserService _userService;

  ChangePasswordNotifier(this._authService, this._userService)
      : super(const AsyncValue.data(null));

  Future<void> changePassword({
    required String uid,
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.changePassword(
        oldPassword: currentPassword,
        newPassword: newPassword,
      );
      final now = DateTime.now();
      final existing = await _userService.getUserProfile(uid);
      await _userService.updateUserProfile(
        uid,
        existing.copyWith(mustChangePassword: false, updatedAt: now),
      );
    });
  }
}

// Logout Provider
final logoutProvider = FutureProvider((ref) async {
  final authService = ref.watch(authServiceProvider);
  await authService.logout();
});

// Registered admins (Super Admin only)
final adminsProvider = FutureProvider<List<UserModel>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getAdmins();
});

// Pending admin invites (Super Admin only)
final adminInvitesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getAdminInvites();
});

// Create admin invite state
final createAdminInviteProvider =
    StateNotifierProvider<CreateAdminInviteNotifier, AsyncValue<void>>((ref) {
  final userService = ref.watch(userServiceProvider);
  return CreateAdminInviteNotifier(userService);
});

class CreateAdminInviteNotifier extends StateNotifier<AsyncValue<void>> {
  final UserService _userService;

  CreateAdminInviteNotifier(this._userService)
      : super(const AsyncValue.data(null));

  Future<void> createInvite({
    required String name,
    required String email,
    required List<String> agencyIds,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _userService.createAdminInvite(
          name: name,
          email: email,
          agencyIds: agencyIds,
        ));
  }
}

// Delete admin invite state
final deleteAdminInviteProvider =
    StateNotifierProvider<DeleteAdminInviteNotifier, AsyncValue<void>>((ref) {
  final userService = ref.watch(userServiceProvider);
  return DeleteAdminInviteNotifier(userService);
});

class DeleteAdminInviteNotifier extends StateNotifier<AsyncValue<void>> {
  final UserService _userService;

  DeleteAdminInviteNotifier(this._userService)
      : super(const AsyncValue.data(null));

  Future<void> deleteInvite(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _userService.deleteAdminInvite(email));
  }
}
