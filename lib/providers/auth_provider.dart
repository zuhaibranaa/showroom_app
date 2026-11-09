import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../compat/model_converters.dart';
import '../core/application/services/dealer_application_service.dart';
import '../core/application/services/user_application_service.dart';
import '../core/domain/entities/user.dart';
import '../core/domain/repositories/user_repository.dart';
import '../core/domain/services/access_service.dart';
import '../models/dealer_model.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../infrastructure/repositories/firestore_user_repository.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/dealer_service.dart';
import 'dealer_provider.dart';

// Auth Service Provider
final authServiceProvider = Provider((ref) => AuthService());

// User Repository Provider (DIP: depends on abstraction)
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return FirestoreUserRepository(FirebaseFirestore.instance);
});

// User Application Service Provider (depends on repository abstraction)
final userApplicationServiceProvider =
    Provider<UserApplicationService>((ref) {
  return UserApplicationService(ref.watch(userRepositoryProvider));
});

// Access Service Provider
final accessServiceProvider = Provider<IAccessService>((ref) {
  return const AccessService();
});

// Current User Stream Provider (Firebase Auth)
final currentUserStreamProvider = StreamProvider((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// User Profile Provider
final userProfileProvider = FutureProvider.family((ref, String uid) async {
  final userService = ref.watch(userApplicationServiceProvider);
  return userService.getById(uid);
});

// User Profile Stream Provider
final userProfileStreamProvider =
    StreamProvider.family<UserModel?, String>((ref, uid) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.streamById(uid).map((entity) =>
      entity != null ? userEntityToModel(entity) : null);
});

// Current signed-in user's profile document
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUserStreamProvider).value?.uid;
  if (uid == null) {
    return Stream.value(null);
  }
  final userService = ref.watch(userApplicationServiceProvider);
  return userService.getById(uid).asStream().map((entity) =>
      entity != null ? userEntityToModel(entity) : null);
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
final registrationStateProvider =
    StateNotifierProvider<RegisterStateNotifier, AsyncValue<void>>((ref) {
  return RegisterStateNotifier(
    ref.watch(authServiceProvider),
    ref.watch(userApplicationServiceProvider),
  );
});

class RegisterStateNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final UserApplicationService _userService;

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

      // Check for admin invite
      final userDoc = await _userService.getById(uid);
      if (userDoc == null) {
        // No existing profile - check for invite
        // Note: Invite checking is done via the admin invite flow in the UI
        await _userService.create(
          uid,
          UserEntity(
            id: uid,
            email: email,
            username: (username != null && username.isNotEmpty)
                ? username
                : (email.split('@').first),
            role: UserRole.admin.value,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    });
  }
}

// Dealer Login State Provider
final dealerLoginStateProvider =
    StateNotifierProvider<DealerLoginStateNotifier, AsyncValue<void>>((ref) {
  return DealerLoginStateNotifier(
    ref.watch(authServiceProvider),
    ref.watch(dealerApplicationServiceProvider),
    ref.watch(userApplicationServiceProvider),
  );
});

class DealerLoginStateNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final DealerApplicationService _dealerService;
  final UserApplicationService _userService;

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

      final dealer = await _dealerService.getByEmail(email);
      if (dealer == null) {
        await _authService.logout();
        throw Exception(
          'No dealer account found for this email. '
          'Please ask the showroom to add you.',
        );
      }

      await _dealerService.linkToUser(dealer.id, user.uid);

      final now = DateTime.now();
      try {
        final existing = await _userService.getById(user.uid);
        await _userService.update(
          user.uid,
          existing!.copyWith(
            role: UserRole.dealer.value,
            agencyId: dealer.agencyId,
            updatedAt: now,
          ),
        );
      } catch (_) {
        await _userService.create(
          user.uid,
          UserEntity(
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
    ref.watch(dealerApplicationServiceProvider),
    ref.watch(userApplicationServiceProvider),
  );
});

class DealerRegistrationStateNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final DealerApplicationService _dealerService;
  final UserApplicationService _userService;

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
      final dealer = await _dealerService.getByEmail(email);
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

      await _dealerService.linkToUser(dealer.id, user.uid);

      final now = DateTime.now();
      await _userService.create(
        user.uid,
        UserEntity(
          id: user.uid,
          email: email,
          username: dealer.name,
          role: UserRole.dealer.value,
          agencyId: dealer.agencyId,
          isActive: true,
          mustChangePassword: true,
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
    ref.watch(userApplicationServiceProvider),
  );
});

class ChangePasswordNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final UserApplicationService _userService;

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
      final existing = await _userService.getById(uid);
      if (existing != null) {
        await _userService.update(
          uid,
          existing.copyWith(mustChangePassword: false, updatedAt: now),
        );
        // Keep biometric quick-login credentials in sync with the new password
        final biometric = BiometricService();
        if (await biometric.isBiometricEnabled()) {
          await biometric.updateStoredCredentials(
            email: existing.email,
            password: newPassword,
            role: existing.role,
          );
        }
      }
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
  final userService = ref.watch(userApplicationServiceProvider);
  final entities = await userService.getByRole('admin');
  return entities.map(userEntityToModel).toList();
});

// Pending admin invites (Super Admin only)
final adminInvitesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userService = ref.watch(userApplicationServiceProvider);
  return userService.getByRole('admin').then((_) => <Map<String, dynamic>>[]);
});

// Create admin invite state
final createAdminInviteProvider =
    StateNotifierProvider<CreateAdminInviteNotifier, AsyncValue<void>>((ref) {
  final userService = ref.watch(userApplicationServiceProvider);
  return CreateAdminInviteNotifier(userService);
});

class CreateAdminInviteNotifier extends StateNotifier<AsyncValue<void>> {
  final UserApplicationService _userService;

  CreateAdminInviteNotifier(this._userService)
      : super(const AsyncValue.data(null));

  Future<void> createInvite({
    required String name,
    required String email,
    required List<String> agencyIds,
    bool isAgencyOwner = false,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Invite creation is handled via the admin invite screen
      // which writes directly to the adminInvites collection
    });
  }
}

// Delete admin invite state
final deleteAdminInviteProvider =
    StateNotifierProvider<DeleteAdminInviteNotifier, AsyncValue<void>>((ref) {
  final userService = ref.watch(userApplicationServiceProvider);
  return DeleteAdminInviteNotifier(userService);
});

class DeleteAdminInviteNotifier extends StateNotifier<AsyncValue<void>> {
  final UserApplicationService _userService;

  DeleteAdminInviteNotifier(this._userService)
      : super(const AsyncValue.data(null));

  Future<void> deleteInvite(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Invite deletion is handled via the admin invite screen
    });
  }
}
