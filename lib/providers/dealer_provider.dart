import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dealer_model.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/dealer_service.dart';
import '../services/user_service.dart';

// Dealer Service Provider
final dealerServiceProvider = Provider((ref) => DealerService());

// Get all dealers
final dealersProvider = FutureProvider<List<DealerModel>>((ref) async {
  final dealerService = ref.watch(dealerServiceProvider);
  return dealerService.getDealers();
});

// Stream dealers
final dealersStreamProvider = StreamProvider<List<DealerModel>>((ref) {
  final dealerService = ref.watch(dealerServiceProvider);
  return dealerService.dealersStream();
});

// Get dealers for an agency (Admin)
final dealersByAgencyProvider =
    FutureProvider.family<List<DealerModel>, String>((ref, agencyId) async {
  final dealerService = ref.watch(dealerServiceProvider);
  return dealerService.getDealersByAgency(agencyId);
});

// Stream dealers for an agency (Admin)
final dealersStreamByAgencyProvider =
    StreamProvider.family<List<DealerModel>, String>((ref, agencyId) {
  final dealerService = ref.watch(dealerServiceProvider);
  return dealerService.dealersStreamByAgency(agencyId);
});

// Get dealer by ID
final dealerByIdProvider =
    FutureProvider.family<DealerModel, String>((ref, id) async {
  final dealerService = ref.watch(dealerServiceProvider);
  return dealerService.getDealerById(id);
});

/// Dealer lookup that resolves to `null` for an empty/missing id instead of
/// throwing, for screens that reference an optional related record.
final dealerByIdOrNullProvider =
    FutureProvider.family<DealerModel?, String>((ref, id) async {
  if (id.isEmpty) return null;
  final dealerService = ref.watch(dealerServiceProvider);
  return dealerService.getDealerById(id);
});

// Create dealer state
final createDealerProvider =
    StateNotifierProvider<CreateDealerNotifier, AsyncValue<String>>((ref) {
  final dealerService = ref.watch(dealerServiceProvider);
  return CreateDealerNotifier(dealerService);
});

class CreateDealerNotifier extends StateNotifier<AsyncValue<String>> {
  final DealerService _dealerService;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  CreateDealerNotifier(this._dealerService)
      : super(const AsyncValue.data(''));

  Future<void> createDealer(DealerModel dealer, {String? tempPassword}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dealerId = await _dealerService.createDealer(dealer);

      final password = tempPassword?.trim();
      if (password == null || password.isEmpty) {
        return dealerId;
      }

      try {
        final uid = await _authService.createAccount(
          email: dealer.email,
          password: password,
        );
        await _dealerService.linkDealerToUser(dealerId, uid);

        final now = DateTime.now();
        await _userService.createUserProfile(
          uid,
          UserModel(
            id: uid,
            email: dealer.email,
            username: dealer.name,
            role: UserRole.dealer.value,
            agencyId: dealer.agencyId,
            isActive: true,
            mustChangePassword: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } catch (e) {
        await _dealerService.deleteDealer(dealerId);
        rethrow;
      }

      return dealerId;
    });
  }
}

// Update dealer state
final updateDealerProvider =
    StateNotifierProvider<UpdateDealerNotifier, AsyncValue<void>>((ref) {
  final dealerService = ref.watch(dealerServiceProvider);
  return UpdateDealerNotifier(dealerService);
});

class UpdateDealerNotifier extends StateNotifier<AsyncValue<void>> {
  final DealerService _dealerService;

  UpdateDealerNotifier(this._dealerService)
      : super(const AsyncValue.data(null));

  Future<void> updateDealer(String id, DealerModel dealer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _dealerService.updateDealer(id, dealer),
    );
  }
}

// Delete dealer state
final deleteDealerProvider =
    StateNotifierProvider<DeleteDealerNotifier, AsyncValue<void>>((ref) {
  final dealerService = ref.watch(dealerServiceProvider);
  return DeleteDealerNotifier(dealerService);
});

class DeleteDealerNotifier extends StateNotifier<AsyncValue<void>> {
  final DealerService _dealerService;

  DeleteDealerNotifier(this._dealerService)
      : super(const AsyncValue.data(null));

  Future<void> deleteDealer(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _dealerService.deleteDealer(id),
    );
  }
}
