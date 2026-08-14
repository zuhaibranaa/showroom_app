# 🔐 Biometric Authentication Setup Guide

## Overview

Your Flutter Showroom App now includes **biometric authentication** (fingerprint, face recognition, iris scan) for quick and secure login.

## ✨ Features

✅ **Fingerprint Authentication** (Android & iOS)
✅ **Face Recognition** (Face ID on iOS, Face Unlock on Android)
✅ **Iris Scanning** (Samsung devices)
✅ **Secure Credential Storage** (Device-level encryption)
✅ **Fallback to Password** (If biometric fails)
✅ **User-Controlled** (Enable/disable anytime)
✅ **Works Offline** (No internet required)

---

## 📱 Platform Support

| Feature | Android | iOS | Windows |
|---------|---------|-----|---------|
| Fingerprint | ✅ | ✅ | ✅ |
| Face Recognition | ✅ (Android 10+) | ✅ (Face ID) | ❌ |
| Iris | ✅ (Samsung) | ❌ | ❌ |

---

## 🛠️ Android Setup

### Step 1: Update AndroidManifest.xml

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### Step 2: Update build.gradle

In `android/app/build.gradle`:

```gradle
dependencies {
    // Already included via local_auth package
    implementation 'androidx.biometric:biometric:1.1.0'
}
```

### Step 3: Verify Fingerprint Sensor

The app automatically detects available biometric methods on first launch.

---

## 🍎 iOS Setup

### Step 1: Update Info.plist

In `ios/Runner/Info.plist`, add:

```xml
<key>NSFaceIDUsageDescription</key>
<string>We need Face ID to securely authenticate you</string>
<key>NSBiometricsUsageDescription</key>
<string>We use biometric authentication for security</string>
```

### Step 2: Verify iPhone Support

Face ID works on:
- iPhone X and later
- iPad Air (3rd generation and later)

Fallback to passcode available for older devices.

---

## 🚀 How to Use

### 1. First-Time Setup

**User Flow:**
```
1. Open Login Screen
2. Enter email & password
3. Check "Enable Fingerprint/Face login" checkbox
4. Click "Login"
5. Authenticate with biometric (will prompt)
6. ✅ Biometric enabled for future logins
```

### 2. Subsequent Logins with Biometric

**User Flow:**
```
1. Open Login Screen
2. Biometric prompt appears automatically
3. Authenticate with finger/face
4. ✅ Auto-logged in (no password needed)
```

### 3. Disable Biometric

**User Flow:**
```
1. Go to Settings → Security Settings
2. Toggle biometric OFF
3. ✅ Biometric disabled (password login only)
```

---

## 📋 Code Architecture

### Service Layer: `lib/services/biometric_service.dart`

Core biometric operations:

```dart
// Check if device supports biometric
bool available = await bioService.isBiometricAvailable();

// Get available types (Face, Fingerprint, Iris)
List<BiometricType> types = await bioService.getAvailableBiometrics();

// Enable biometric (prompts user first)
bool success = await bioService.enableBiometric(
  email: 'user@example.com',
  password: 'password123',
  role: 'dealer',
);

// Login with biometric
Map<String, String>? credentials = await bioService.biometricLogin(
  reason: 'Login to Showroom App using Fingerprint',
);

// Disable biometric
await bioService.disableBiometric();
```

### Provider Layer: `lib/providers/biometric_provider.dart`

Riverpod state management:

```dart
// Check if device supports biometric
final isBiometricAvailableProvider = FutureProvider((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.isBiometricAvailable();
});

// Check if current user has biometric enabled
final isBiometricEnabledProvider = FutureProvider((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.isBiometricEnabled();
});

// Get biometric name for UI
final biometricNameProvider = FutureProvider((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.getBiometricName();
});
```

### UI Integration

**Login Screen** (`lib/screens/auth/login_screen.dart`):
- Checkbox to enable biometric on first login
- Quick login button with biometric icon
- Auto-prompt if biometric is already enabled

**Dealer Login Screen** (`lib/screens/auth/dealer_login_screen.dart`):
- Same biometric support as staff login
- Dealer-specific branding

**Security Settings Screen** (`lib/screens/profile/biometric_settings_screen.dart`):
- Toggle biometric on/off
- Security tips & best practices
- Shows device's supported biometric type

---

## 🔒 Security Implementation

### Credential Storage

Credentials are stored using **Flutter Secure Storage**:
- **Android**: Uses Android Keystore
- **iOS**: Uses Keychain
- **Encryption**: Hardware-backed when available
- **Isolation**: Per-app encrypted storage

### Authentication Flow

```
User Biometric Input
        ↓
Device Biometric Sensor
        ↓
OS-Level Verification (Keystore/Keychain)
        ↓
Retrieve Stored Credentials (Encrypted)
        ↓
Firebase Authentication
        ↓
App Access Granted
```

### Security Best Practices

1. **User's choice**: Biometric is opt-in
2. **Credentials encrypted**: Stored on device securely
3. **No password transmission**: Biometric only retrieves stored password
4. **Offline capable**: No internet required for biometric verification
5. **Fallback support**: Always can login with password

---

## ❌ Troubleshooting

### Issue: "Biometric not available"
**Cause**: Device doesn't have fingerprint/face sensor
**Solution**: User must use password login

### Issue: "Biometric authentication failed"
**Cause**: User cancelled, wrong biometric, sensor dirty
**Solution**: Try again or use password login

### Issue: "Stored credentials not found"
**Cause**: Biometric was disabled or storage cleared
**Solution**: Re-enable biometric after password login

### Issue: "Permission denied"
**Cause**: App doesn't have biometric permission
**Solution**: 
```bash
# Android: Check AndroidManifest.xml has permission
# iOS: Check Info.plist has NSFaceIDUsageDescription
```

### Issue: "Android: Always shows "not available""
**Cause**: Missing or incorrect `uses-permission` in AndroidManifest.xml
**Solution**: Add:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

---

## 📊 User Experience Flow

```
┌─────────────────────────────────────────────────┐
│           Login Screen (First Time)             │
├─────────────────────────────────────────────────┤
│  Email: [user@example.com                ]      │
│  Password: [••••••••••••             ]      │
│  ☐ Enable Fingerprint login                    │
│  [         LOGIN         ]                      │
│  OR                                             │
│  [  🔐 Login with Fingerprint  ]               │
└─────────────────────────────────────────────────┘
              ↓
    Biometric Prompt (OS-Level)
         ↓
    ┌─────────────────────────┐
    │ Fingerprint             │
    │                         │
    │  [Fingerprint Icon]     │
    │  Scan your finger       │
    │                         │
    │  [Cancel]               │
    └─────────────────────────┘
         ↓
    ✅ Authenticated
    
    
┌─────────────────────────────────────────────────┐
│        Login Screen (Subsequent Logins)         │
├─────────────────────────────────────────────────┤
│                                                 │
│  Biometric Prompt appears automatically:        │
│                                                 │
│  ┌─────────────────────────┐                   │
│  │ Fingerprint             │                   │
│  │                         │                   │
│  │  [Fingerprint Icon]     │                   │
│  │  Scan your finger       │                   │
│  │                         │                   │
│  │  [Cancel]               │                   │
│  └─────────────────────────┘                   │
│                                                 │
│  OR tap: [  🔐 Login with Fingerprint  ]      │
└─────────────────────────────────────────────────┘
```

---

## 🎛️ Configuration Options

### Customize Biometric Prompt

In `lib/services/biometric_service.dart`:

```dart
return await _localAuth.authenticate(
  localizedReason: 'Login to Showroom App',  // Custom message
  options: const AuthenticationOptions(
    stickyAuth: true,        // Keep prompt visible until result
    biometricOnly: true,     // Don't show PIN fallback
    useErrorDialogs: true,   // Show error messages
  ),
);
```

### Customize UI Icons

In `lib/screens/auth/login_screen.dart`:

```dart
Icon(
  name.contains('Face') 
    ? Icons.face
    : name.contains('Iris')
        ? Icons.remove_red_eye
        : Icons.fingerprint,
),
```

---

## 📝 API Reference

### BiometricService

```dart
class BiometricService {
  // Check availability
  Future<bool> isBiometricAvailable()
  Future<List<BiometricType>> getAvailableBiometrics()
  Future<String> getBiometricName()
  
  // Authentication
  Future<bool> authenticateWithBiometric({required String reason})
  Future<Map<String, String>?> biometricLogin({required String reason})
  
  // Management
  Future<bool> enableBiometric({...})
  Future<bool> isBiometricEnabled()
  Future<void> disableBiometric()
  Future<bool> updateStoredCredentials({...})
  
  // Storage
  Future<Map<String, String>?> getStoredCredentials()
}
```

---

## 🔄 Migration from Password-Only Login

**Step 1**: Users login with password normally
**Step 2**: Check "Enable Fingerprint" checkbox before clicking Login
**Step 3**: After successful password login, app prompts to authenticate with biometric
**Step 4**: Credentials are securely stored
**Step 5**: Next login shows biometric prompt automatically

---

## 📈 User Adoption Tips

1. **Show value**: "Skip password entry, login instantly"
2. **Emphasize security**: "Your fingerprint never leaves your device"
3. **Make it optional**: "Enable anytime in Security Settings"
4. **Provide fallback**: Always show "Login with password" option
5. **Test early**: Let users enable during registration

---

## 🚀 Testing on Emulator

### Android Emulator (Fingerprint)
```bash
# Connect to emulator
adb devices

# Simulate fingerprint
adb -s <emulator_id> emu finger touch 1

# Or use Android Studio → Extended controls → Fingerprint
```

### iOS Simulator (Face ID)
```bash
# Xcode → Features → Face ID → Enrolled
# Then simulate authentication when prompted
```

### Testing Checklist
- [ ] Biometric available on device
- [ ] First-time enable works
- [ ] Subsequent biometric logins work
- [ ] Disable biometric works
- [ ] Password login still works after enabling biometric
- [ ] Credentials stored securely
- [ ] Works offline

---

## 🔐 Security Considerations

### What's Secure ✅
- Biometric data never leaves device
- Credentials encrypted by OS (Keystore/Keychain)
- Biometric can't be extracted or spoofed
- Per-app isolated storage

### Limitations ⚠️
- Stored password still exists on device
- Device theft could compromise stored credentials
- Biometric can be fooled by twins/siblings
- Lost/reset device loses stored credentials

### Recommendations
1. Encourage strong passwords
2. Educate users about device security
3. Provide option to disable biometric
4. Implement account recovery options
5. Add remote logout capability

---

## 📞 Support

**Common Questions:**

Q: Can biometric work without internet?
A: Yes, completely offline.

Q: What happens if user changes password?
A: Call `updateStoredCredentials()` to sync new password.

Q: Can biometric be hacked?
A: Biometric data never leaves device, so technically no.

Q: Do users lose access if they disable biometric?
A: No, password login is always available.

Q: Can I see stored credentials?
A: No, stored encrypted by OS.

---

## 🎯 Next Steps

1. Update pubspec.yaml (already done ✅)
2. Add permissions (AndroidManifest.xml, Info.plist)
3. Test on physical devices
4. Monitor user adoption
5. Gather feedback for improvements

---

**Status**: ✅ Biometric Authentication Ready
**Last Updated**: August 2024
**Version**: 1.0
