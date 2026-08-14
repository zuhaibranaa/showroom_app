import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';

// Biometric service provider
final biometricServiceProvider = Provider((ref) {
  return BiometricService();
});

// Check if biometric is available on device
final isBiometricAvailableProvider = FutureProvider((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.isBiometricAvailable();
});

// Check if biometric authentication is enabled for current user
final isBiometricEnabledProvider = FutureProvider((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.isBiometricEnabled();
});

// Get available biometric types (Face, Fingerprint, Iris, etc.)
final availableBiometricsProvider = FutureProvider((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.getAvailableBiometrics();
});

// Get biometric name for UI display
final biometricNameProvider = FutureProvider((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.getBiometricName();
});

// State notifier for biometric login
class BiometricLoginStateNotifier extends StateNotifier<AsyncValue<String?>> {
  final BiometricService _service;

  BiometricLoginStateNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> loginWithBiometric({
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credentials = await _service.biometricLogin(reason: reason);
      if (credentials != null) {
        state = AsyncValue.data(credentials['email']!);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> enableBiometric({
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _service.enableBiometric(
        email: email,
        password: password,
        role: role,
      );
      if (success) {
        state = AsyncValue.data(email);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> disableBiometric() async {
    state = const AsyncValue.loading();
    try {
      await _service.disableBiometric();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Biometric login state provider
final biometricLoginProvider =
    StateNotifierProvider<BiometricLoginStateNotifier, AsyncValue<String?>>((ref) {
  final service = ref.watch(biometricServiceProvider);
  return BiometricLoginStateNotifier(service);
});
