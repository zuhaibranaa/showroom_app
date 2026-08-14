# 🚀 Quick Start Checklist - Firebase Emulator

## ✅ What's Already Done
- [x] Flutter project structure created
- [x] All dependencies installed (25+)
- [x] All screens created (10+)
- [x] Role-based access control (Admin/Staff/Dealer)
- [x] Dealer login & dashboard screens
- [x] Firebase configuration template
- [x] Emulator setup script
- [x] Security rules
- [x] Documentation

## 📋 To Get Started (Choose One Path)

### Path 1: Firebase Emulator ⭐ (RECOMMENDED)

**Prerequisites:**
- [ ] Node.js & npm installed
- [ ] Firebase CLI installed (`npm install -g firebase-tools`)

**Setup (5 minutes):**
1. [ ] Open terminal in project root
2. [ ] Run: `bash setup-emulator.sh`
3. [ ] Run: `firebase emulators:start`
4. [ ] Open new terminal
5. [ ] Edit: `lib/config/firebase_config.dart`
   - Find: `static const bool useEmulator = false;`
   - Change to: `useEmulator = true;`
6. [ ] Run: `flutter run`
7. [ ] Open: `http://localhost:4000` (see database)

**Test Dealer Flow:**
- [ ] Login as dealer
- [ ] View dealer dashboard
- [ ] Check commission tracking
- [ ] View sales (filtered to dealer only)

### Path 2: Firebase Cloud (Alternative)

**Prerequisites:**
- [ ] Google account
- [ ] Internet connection

**Setup (15 minutes):**
1. [ ] Visit: https://console.firebase.google.com
2. [ ] Create new project "showroom-app-dev"
3. [ ] Enable: Authentication, Firestore, Storage
4. [ ] Download JSON config
5. [ ] Open: `lib/config/firebase_options.dart`
6. [ ] Copy values from JSON to this file
7. [ ] Run: `flutter run`

### Path 3: Mock Data (Quick Test)

**Setup (2 minutes):**
1. [ ] Run: `flutter run`
2. [ ] App launches with demo data
3. [ ] Test UI only (no real data)

---

## 🎯 Commands Reference

### Firebase Emulator
```bash
# Terminal 1: Start emulator
firebase emulators:start

# Terminal 2: Run app
flutter run

# Terminal 3: Optional - view data
open http://localhost:4000
```

### Firebase Cloud
```bash
flutter run
```

### Troubleshooting
```bash
# Check firebase installation
firebase --version

# Install firebase if missing
npm install -g firebase-tools

# Test connection
firebase login

# Kill port if in use
lsof -ti:8080 | xargs kill -9
```

---

## 📁 Key Files You'll Need

| File | Purpose | Status |
|------|---------|--------|
| `lib/config/firebase_config.dart` | Firebase setup | ✅ Updated |
| `lib/config/firebase_options.dart` | Credentials template | ✅ Ready |
| `firebase.json` | Emulator config | ✅ Created |
| `setup-emulator.sh` | Setup script | ✅ Ready |
| `lib/screens/dealer/*` | Dealer screens | ✅ New |

---

## 🧪 Testing After Setup

### 1. Dealer Login Flow
```
✓ Open app
✓ Tap "Dealer Login" button
✓ Enter: test@dealer.com / password123
✓ Should see dealer dashboard
```

### 2. Dealer Dashboard
```
✓ View commission earned (mock: $12,000)
✓ View sales count (mock: 12)
✓ Navigate to Sales tab
✓ Navigate to Commission tab
```

### 3. Data Verification (Emulator Only)
```
✓ Open http://localhost:4000
✓ Click "Firestore"
✓ Expand "users" collection
✓ See test user data
✓ Expand "sales" collection
✓ See test sales data
```

---

## 📚 Documentation Files

| File | Read Time | Use Case |
|------|-----------|----------|
| `LOCAL_DEVELOPMENT_GUIDE.md` | 5 min | Quick setup |
| `FIREBASE_EMULATOR_SETUP.md` | 10 min | Detailed guide |
| `WORKING_WITHOUT_FIREBASE.md` | 5 min | Troubleshooting |
| `DOCUMENTATION.md` | 30 min | Complete reference |
| `FIREBASE_SETUP.md` | 15 min | Production setup |

---

## ⏱️ Expected Times

| Task | Time |
|------|------|
| Emulator setup | 5 min |
| Firebase Cloud setup | 15 min |
| Mock data setup | 2 min |
| First `flutter run` | 3 min |
| Testing dealer flow | 5 min |
| **Total** | **15-30 min** |

---

## ✨ What Works After Setup

- ✅ User authentication (all roles)
- ✅ Dealer login & separate dashboard
- ✅ View dealer sales (filtered)
- ✅ Commission tracking
- ✅ Real-time data updates
- ✅ Image uploads to Storage
- ✅ Form validation
- ✅ Loading states
- ✅ Error handling

---

## 🐛 Common Issues

### "Firebase Emulator not running"
```bash
firebase emulators:start
```

### "Port 8080 already in use"
```bash
lsof -ti:8080 | xargs kill -9
```

### "useAuthEmulator already called"
- Emulator already connected
- Restart both terminals (emulator + app)

### "No internet but using Firebase Cloud"
- Switch to Emulator option
- Run: `bash setup-emulator.sh`

---

## ✅ Final Checklist Before Starting

- [ ] Project folder: `/Users/zohaib/FProjects/showroom_app`
- [ ] All files present: `lib/`, `pubspec.yaml`, documentation
- [ ] Node.js installed (if using Emulator): `node --version`
- [ ] Firebase CLI installed (if using Emulator): `firebase --version`
- [ ] Flutter installed: `flutter --version`
- [ ] Android emulator or iPhone simulator ready

---

## 🎉 You're Ready!

Choose your path above and follow the steps. 

**Quickest path**: `bash setup-emulator.sh` → `firebase emulators:start` → `flutter run`

**Questions?** Check the documentation files or error messages.

**Stuck?** See `WORKING_WITHOUT_FIREBASE.md` troubleshooting section.

---

**Happy coding! 🚀**

Created: August 2024
Status: Ready to Use ✅
