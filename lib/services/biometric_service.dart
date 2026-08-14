import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static const _secureStorage = FlutterSecureStorage();
  static const _bioAuthKey = 'biometric_enabled';
  static const _emailKey = 'stored_email';
  static const _passwordKey = 'stored_password';
  static const _roleKey = 'stored_role';

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device has biometric capability
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Get readable biometric names
  Future<String> getBiometricName() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.contains(BiometricType.face)) {
        return 'Face Recognition';
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (biometrics.contains(BiometricType.iris)) {
        return 'Iris Scan';
      }
      return 'Biometric';
    } catch (e) {
      return 'Biometric';
    }
  }

  /// Authenticate using biometric
  Future<bool> authenticateWithBiometric({
    required String reason,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  /// Enable biometric authentication and store credentials
  Future<bool> enableBiometric({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // First authenticate with biometric to enable it
      final authenticated = await authenticateWithBiometric(
        reason: 'Verify your identity to enable biometric login',
      );

      if (!authenticated) {
        return false;
      }

      // Store credentials securely
      await _secureStorage.write(key: _emailKey, value: email);
      await _secureStorage.write(key: _passwordKey, value: password);
      await _secureStorage.write(key: _roleKey, value: role);
      await _secureStorage.write(key: _bioAuthKey, value: 'true');

      return true;
    } catch (e) {
      debugPrint('Error enabling biometric: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _bioAuthKey);
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Get stored credentials for biometric login
  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      final email = await _secureStorage.read(key: _emailKey);
      final password = await _secureStorage.read(key: _passwordKey);
      final role = await _secureStorage.read(key: _roleKey);

      if (email == null || password == null || role == null) {
        return null;
      }

      return {
        'email': email,
        'password': password,
        'role': role,
      };
    } catch (e) {
      debugPrint('Error retrieving stored credentials: $e');
      return null;
    }
  }

  /// Biometric login flow
  Future<Map<String, String>?> biometricLogin({
    required String reason,
  }) async {
    try {
      // Check if biometric is enabled
      final enabled = await isBiometricEnabled();
      if (!enabled) {
        return null;
      }

      // Authenticate with biometric
      final authenticated = await authenticateWithBiometric(reason: reason);
      if (!authenticated) {
        return null;
      }

      // Get stored credentials
      return await getStoredCredentials();
    } catch (e) {
      debugPrint('Biometric login error: $e');
      return null;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _bioAuthKey);
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
      await _secureStorage.delete(key: _roleKey);
    } catch (e) {
      debugPrint('Error disabling biometric: $e');
    }
  }

  /// Update stored credentials (e.g., after password change)
  Future<bool> updateStoredCredentials({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      await _secureStorage.write(key: _emailKey, value: email);
      await _secureStorage.write(key: _passwordKey, value: password);
      await _secureStorage.write(key: _roleKey, value: role);
      return true;
    } catch (e) {
      debugPrint('Error updating stored credentials: $e');
      return false;
    }
  }
}
