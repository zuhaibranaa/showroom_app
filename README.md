# 🚗 Showroom Management App

A **bike and car showroom management system** built with Flutter and Firebase — covering inventory, sales, dealers, agencies and staff administration with real-time Firestore data.

Runs on Android, iOS, Web, macOS, Windows and Linux from a single codebase.

---

## 🌟 Features

### Authentication & security
- Email registration with validation, Firebase Auth login, password reset
- Session management with secure token storage
- **Biometric quick-login** (`local_auth`) with encrypted credential storage
- Role-based access control — admin, dealer and agency portals each see different navigation and data
- Permission flags per dealer (`dealer_permissions`) restricting what a dealer account can do

### Vehicle inventory
- Full CRUD on vehicles — make, model, year, colour, VIN, licence plate, purchase price and status
- Live vehicle list via Firestore streams, so edits appear instantly on every device
- Inventory tracking and availability filtering

### Sales
- Record sale transactions with multiple image uploads per vehicle
- Buyer information capture
- Price validation — a sale can never be recorded below the purchase price
- Automatic profit calculation per sale and in aggregate
- Real-time updates across the dashboard

### Dealers & agencies
- Dealer CRUD with contact information, licence details and commission tracking
- Agency management module for multi-dealer networks
- Per-dealer permission sets and profile management

### Dashboard
- Statistics overview — vehicles, sales, dealers, profit
- Quick-action shortcuts and pull-to-refresh
- Responsive layout that adapts from phone to desktop

### Platform
- **Offline support** via Hive
- Image caching (`cached_network_image`) and shimmer loading placeholders
- Lottie animations, launcher icons, form validation with `formz`
- Environment configuration via `.env` (`flutter_dotenv`)

---

## 📂 Project structure

```
lib/
├── config/            # Firebase options, app & environment config
├── models/            # Data models (json_serializable)
│   ├── vehicle_model.dart
│   ├── sale_model.dart
│   ├── dealer_model.dart
│   ├── agency_model.dart
│   ├── user_model.dart
│   └── user_role.dart
├── services/          # Business logic & data access
│   ├── auth_service.dart
│   ├── vehicle_service.dart
│   ├── sale_service.dart
│   ├── dealer_service.dart
│   ├── agency_service.dart
│   ├── user_service.dart
│   ├── storage_service.dart
│   └── biometric_service.dart
├── providers/         # State management
│   ├── auth_provider.dart
│   ├── access_provider.dart
│   ├── vehicle_provider.dart
│   ├── sale_provider.dart
│   ├── dealer_provider.dart
│   ├── agency_provider.dart
│   ├── dealer_profile_provider.dart
│   └── biometric_provider.dart
├── screens/
│   ├── auth/          # Login & registration
│   ├── dashboard/     # Statistics overview
│   ├── vehicles/      # Inventory
│   ├── sales/         # Sale transactions
│   ├── dealers/       # Dealer management
│   ├── dealer/        # Dealer portal
│   ├── agencies/      # Agency management
│   ├── admins/        # Admin console
│   └── profile/       # User profile
├── widgets/           # Reusable UI components
├── utils/             # Helpers & formatters
└── main.dart          # Entry point
```

---

## 📦 Tech stack

| Concern | Choice |
|---------|--------|
| Framework | Flutter / Dart 3.11+ |
| Backend | Firebase — Auth, Cloud Firestore, Storage |
| State management | `provider` + `flutter_riverpod` |
| Navigation | `go_router` |
| Serialisation | `json_serializable` / `json_annotation` |
| Forms & validation | `formz` |
| Auth extras | `local_auth` (biometrics), `flutter_secure_storage` |
| Offline | Hive / `hive_flutter` |
| Media | `image_picker`, `cached_network_image` |
| UI | `shimmer`, `lottie`, `flutter_launcher_icons` |
| Networking | `http`, `dio` |
| Config | `flutter_dotenv` |
| Logging | `logger` |

---

## 🚀 Getting started

### 1. Clone & install

```bash
git clone https://github.com/zuhaibranaa/showroom_app.git
cd showroom_app

flutter pub get
```

### 2. Configure Firebase

1. Create a Firebase project and register the app for Android/iOS/Web.
2. Copy your config into `lib/config/firebase_options.dart` — or run `flutterfire configure`.
3. Enable **Authentication** (email/password), **Cloud Firestore** and **Storage** in the console.

Detailed instructions: **[FIREBASE_SETUP.md](./FIREBASE_SETUP.md)**.
Working without a Firebase project: **[WORKING_WITHOUT_FIREBASE.md](./WORKING_WITHOUT_FIREBASE.md)**.

### 3. Run

```bash
flutter devices
flutter run
```

---

## 🗂️ Additional documentation

| Document | Contents |
|----------|----------|
| [DOCUMENTATION.md](./DOCUMENTATION.md) | Full architecture & module documentation |
| [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) | Firebase project setup |
| [FIREBASE_EMULATOR_SETUP.md](./FIREBASE_EMULATOR_SETUP.md) | Run the Firebase emulator locally |
| [BIOMETRIC_AUTH_SETUP.md](./BIOMETRIC_AUTH_SETUP.md) | Biometric login setup |
| [LOCAL_DEVELOPMENT_GUIDE.md](./LOCAL_DEVELOPMENT_GUIDE.md) | Local dev environment |
| [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) | Project overview & status |
| [INDEX.md](./INDEX.md) | Documentation index |

Firestore indexes and rules live in `firestore.indexes.json`, `firestore.rules` and `storage.rules`.

---

## 🛣️ Routes

```
/login → /register → /dashboard
                         ├── /vehicles
                         ├── /sales
                         ├── /dealers
                         ├── /dealer      (dealer portal)
                         ├── /agencies
                         ├── /admins
                         └── /profile
```

---

## 🧪 Testing

```bash
flutter test
```

---

## 🔐 Security notes

- Firebase Authentication with role claims enforced per route
- Firestore & Storage security rules committed to the repo
- Encrypted local storage for credentials (`flutter_secure_storage`)
- Form-level input validation on every write path
- Biometric unlock for returning users

---

## 🐛 Troubleshooting

| Symptom | Fix |
|---------|-----|
| Firebase error at startup | Check `lib/config/firebase_options.dart` matches your project |
| Permission denied on read/write | Review `firestore.rules` / `storage.rules` and the user's role |
| Image upload fails | Confirm Firebase Storage is enabled and the bucket rules allow the path |
| Queries missing documents | Deploy `firestore.indexes.json` |

---

## 👤 Author

**M. Zohaib Shabbir** — Software Engineer

GitHub: [github.com/zuhaibranaa](https://github.com/zuhaibranaa) · LinkedIn: [muhammad-zohaib-92b013176](https://linkedin.com/in/muhammad-zohaib-92b013176/)

---

Built with Flutter & Firebase 🚀
