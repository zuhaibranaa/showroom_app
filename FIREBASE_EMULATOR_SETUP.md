# Firebase Emulator Setup Guide - Local Development

## Quick Answer: Working Without Firebase Configured

Your Flutter app **requires Firebase configuration** to run, but you have 2 options for local development:

### Option 1: Firebase Emulator Suite (Recommended) ✅
Run a **local Firebase** on your machine. No real Firebase project needed.

### Option 2: Mock Services
Use fake data services that don't need Firebase at all.

---

## Option 1: Firebase Emulator Suite Setup

### Step 1: Install Firebase Emulator
```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Verify installation
firebase --version
```

### Step 2: Initialize Firebase in Your Project
```bash
cd /Users/zohaib/FProjects/showroom_app

# Create firebase.json in your project root
firebase init emulator

# Select these emulators:
# - Authentication
# - Firestore Database
# - Storage
# - Pub/Sub (optional)
```

### Step 3: Create `firebase.json` (emulator config)
Create this file in your project root:

```json
{
  "emulators": {
    "auth": {
      "host": "localhost",
      "port": 9099
    },
    "firestore": {
      "host": "localhost",
      "port": 8080
    },
    "storage": {
      "host": "localhost",
      "port": 9199
    },
    "pubsub": {
      "host": "localhost",
      "port": 8085
    },
    "ui": {
      "enabled": true,
      "host": "localhost",
      "port": 4000
    }
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

### Step 4: Update Flutter App Configuration

Modify `lib/config/firebase_config.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Connect to emulator in development
    if (kDebugMode) {
      try {
        // Auth Emulator
        await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        
        // Firestore Emulator
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        
        // Storage Emulator
        FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
        
        print('✅ Connected to Firebase Emulator');
      } catch (e) {
        print('Emulator already connected: $e');
      }
    }
  }
}
```

### Step 5: Create Placeholder Firebase Options

Update `lib/config/firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

const firebaseOptionsWeb = FirebaseOptions(
  apiKey: 'AIzaSyDQVN...',  // Any value for emulator
  appId: '1:000000000000:web:abcdef123456',
  messagingSenderId: '000000000000',
  projectId: 'demo-project',  // Match emulator project
  authDomain: 'demo-project.firebaseapp.com',
  storageBucket: 'demo-project.appspot.com',
);

const firebaseOptionsAndroid = FirebaseOptions(
  apiKey: 'AIzaSyDQVN...',
  appId: '1:000000000000:android:abcdef123456',
  messagingSenderId: '000000000000',
  projectId: 'demo-project',
  storageBucket: 'demo-project.appspot.com',
);

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return firebaseOptionsWeb;  // or Android
  }
}
```

### Step 6: Start Firebase Emulator
```bash
# From your project root
firebase emulators:start

# Output will show:
# ┌─────────────────────────────────────────────────────────────┐
# │ ✔  All emulators started, it is now safe to connect        │
# ├─────────────────────────────────────────────────────────────┤
# │ Auth Emulator: http://localhost:9099                        │
# │ Firestore Emulator: http://localhost:8080                   │
# │ Storage Emulator: http://localhost:9199                     │
# │ Pub/Sub Emulator: http://localhost:8085                     │
# │ Emulator UI: http://localhost:4000                          │
# └─────────────────────────────────────────────────────────────┘
```

### Step 7: Run Flutter App
```bash
# In another terminal
cd /Users/zohaib/FProjects/showroom_app
flutter run
```

### Step 8: Access Emulator UI
Visit: **http://localhost:4000**
- View all data in Firestore
- Monitor Authentication
- Check Storage uploads

---

## Option 2: Mock Services (No External Setup)

If you don't want to install Firebase Emulator, use mock services:

### Create `lib/services/mock_auth_service.dart`
```dart
import 'package:firebase_auth/firebase_auth.dart';

class MockAuthService {
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock response
    print('Mock Registration: $email');
    throw UnimplementedError('Use real Firebase or emulator');
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock Login: $email');
    throw UnimplementedError('Use real Firebase or emulator');
  }
}
```

**Limitation**: Mock services can't replicate Firebase, so Option 1 (Emulator) is **recommended**.

---

## Testing Without Internet

Both options work offline:
- **Emulator**: Runs completely locally ✅
- **Mock**: No network calls at all ✅

---

## Troubleshooting

### Issue: "Emulator not running"
```bash
firebase emulators:start --only firestore,auth
```

### Issue: "Port already in use"
```bash
# Kill existing process
lsof -ti:8080 | xargs kill -9

# Or use different ports in firebase.json
```

### Issue: "Project ID mismatch"
Ensure `firebase.json` project ID matches `firebase_options.dart`:
```json
{
  "projectId": "demo-project"
}
```

---

## Summary

| Option | Setup Time | Features | Best For |
|--------|-----------|----------|----------|
| **Emulator** | 10 min | Full Firebase locally | Local development, testing |
| **Mock** | 5 min | Basic fake data | Quick prototyping |
| **Real Firebase** | 15 min | Production-ready | Testing integrations |

**Recommendation**: Start with **Emulator** → Test locally → Deploy with real Firebase

