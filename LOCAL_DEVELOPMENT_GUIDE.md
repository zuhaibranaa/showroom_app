# ⚡ Quick Start: Local Development Without Firebase Configuration

## TL;DR
Your app **requires Firebase**, but you have **3 ways** to run it locally:

| Method | Setup Time | Requires Internet | Best For |
|--------|-----------|---|---|
| **Firebase Emulator** ⭐ | 5 min | ❌ No (runs locally) | Local dev & testing |
| **Free Firebase Project** | 15 min | ✅ Yes | Quick testing |
| **Mock Services** | 10 min | ❌ No | Prototyping UI |

---

## Method 1: Firebase Emulator (Recommended) ⭐

### 1️⃣ Run Setup Script
```bash
cd /Users/zohaib/FProjects/showroom_app
bash setup-emulator.sh
```

### 2️⃣ Start Emulator
```bash
firebase emulators:start
```

You'll see:
```
✔  All emulators started, it is now safe to connect
├─ Auth Emulator: http://localhost:9099
├─ Firestore Emulator: http://localhost:8080
├─ Storage Emulator: http://localhost:9199
└─ Emulator UI: http://localhost:4000
```

### 3️⃣ Enable Emulator in App
Open `lib/config/firebase_config.dart` and change:
```dart
static const bool useEmulator = true; // ← Change this to true
```

### 4️⃣ Run Flutter App
```bash
flutter run
```

### 5️⃣ View Data in Emulator UI
Visit: **http://localhost:4000**
- See all Firestore data in real-time
- Create test users
- Monitor Storage uploads

---

## Method 2: Free Firebase Project (Easiest) ✅

### 1️⃣ Create Firebase Project
1. Go to: https://console.firebase.google.com
2. Click "Create Project"
3. Name: "showroom-app-dev"
4. Click "Create"

### 2️⃣ Get Credentials
1. Go to Project Settings
2. Download JSON config
3. Copy values to `lib/config/firebase_options.dart`

### 3️⃣ Enable Services
- Authentication: Email/Password
- Firestore Database: Create "users", "vehicles", "sales", "dealers" collections
- Storage: Enable

### 4️⃣ Disable Emulator
```dart
static const bool useEmulator = false; // Keep this false
```

### 5️⃣ Run App
```bash
flutter run
```

---

## Method 3: Mock Services (No Setup)

Skip Firebase entirely for UI testing:

### 1️⃣ Update Auth Service
```dart
// lib/services/auth_service.dart
// Use mock credentials for testing
final mockUser = User(
  uid: 'mock_user_123',
  email: 'test@example.com',
  role: UserRole.admin,
);
```

### 2️⃣ Run App
```bash
flutter run
```

**Limitation**: Only for UI testing, not real data operations.

---

## Comparison Table

```
Feature              | Emulator  | Firebase | Mock
---------------------|-----------|----------|------
Local development    | ✅        | ✅       | ✅
No internet needed   | ✅        | ❌       | ✅
Real data testing    | ✅        | ✅       | ❌
View data in UI      | ✅        | ✅       | ❌
Production-like      | ✅        | ✅       | ❌
```

---

## Troubleshooting

### ❌ "Firebase Emulator not running"
```bash
firebase emulators:start
# Make sure you ran setup script first
```

### ❌ "Port 8080 already in use"
```bash
# Kill existing process
lsof -ti:8080 | xargs kill -9

# Or use different ports in firebase.json
```

### ❌ "Connection refused"
- Emulator not started?
- Firewall blocking? Try: `sudo lsof -i :8080`
- Wrong host in firebase_config.dart? Should be 'localhost' or '127.0.0.1'

### ❌ "Permission denied running emulators"
```bash
firebase login
firebase init
```

---

## Recommended Development Workflow

```
Phase 1: UI Development (Weeks 1-2)
├─ Use Mock Services (no setup)
├─ Test screens & navigation
└─ No Firebase needed

Phase 2: Integration (Week 3+)
├─ Use Firebase Emulator
├─ Test CRUD operations
├─ Verify Firestore data
└─ View in Emulator UI (localhost:4000)

Phase 3: Testing & QA (Week 4+)
├─ Use Real Firebase Project
├─ Test with real credentials
├─ Verify production rules
└─ Beta testing
```

---

## Files Created for You

```
showroom_app/
├─ firebase.json                    # Emulator config
├─ firestore.rules                  # Firestore security rules
├─ storage.rules                    # Storage security rules
├─ setup-emulator.sh               # Automated setup script
├─ FIREBASE_EMULATOR_SETUP.md      # Detailed guide
├─ lib/config/firebase_config.dart # Updated with emulator support
└─ lib/screens/dealer/            # NEW: Dealer screens
   ├─ dealer_dashboard_screen.dart
   ├─ dealer_sales_screen.dart
   └─ dealer_commission_screen.dart
```

---

## Start Now!

### Option A: Emulator (Recommended)
```bash
cd showroom_app
bash setup-emulator.sh
firebase emulators:start  # Terminal 1
flutter run              # Terminal 2
# Visit: http://localhost:4000
```

### Option B: Firebase Cloud
```bash
# Create project at https://console.firebase.google.com
# Copy credentials to firebase_options.dart
flutter run
```

### Option C: Mock (UI Only)
```bash
flutter run
# Login with any email/password
```

---

**Questions?** Check `FIREBASE_EMULATOR_SETUP.md` for detailed instructions.
