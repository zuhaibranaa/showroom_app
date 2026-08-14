# 🚗 Showroom Management App - Flutter Edition

A comprehensive **Car Showroom Management Application** built with Flutter and Firebase, featuring real-time database, authentication, and multi-module management system.

## 🌟 Features

### Authentication & Security
- ✅ User Registration with email validation
- ✅ Secure Login with Firebase Auth
- ✅ Password Reset functionality
- ✅ Session management
- ✅ Encrypted secure credential storage for biometric quick login

### Vehicle Management
- ✅ Add, read, update, delete vehicles
- ✅ Vehicle details (make, model, year, color, VIN, license plate)
- ✅ Real-time vehicle list with streaming
- ✅ Inventory tracking

### Sales Management
- ✅ Record sales transactions
- ✅ Multiple image uploads per sale
- ✅ Buyer information tracking
- ✅ Price validation (sale >= purchase price)
- ✅ Automatic profit calculation
- ✅ Real-time sales updates

### Dealer Management
- ✅ Add and manage dealers
- ✅ Contact information
- ✅ License and commission tracking
- ✅ Real-time updates

### Dashboard
- ✅ Statistics overview (vehicles, sales, dealers, profit)
- ✅ Quick action buttons
- ✅ Refresh capability
- ✅ Responsive design

## 🚀 Quick Start

1. **Get dependencies**
   ```bash
   cd /Users/zohaib/FProjects/showroom_app
   flutter pub get
   ```

2. **Configure Firebase**
   - See [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)
   - Update `lib/config/firebase_options.dart`

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Key Dependencies

- `firebase_core` & `firebase_auth` - Authentication
- `cloud_firestore` - Real-time database
- `firebase_storage` - Image storage
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `image_picker` - Image selection
- `flutter_secure_storage` - Secure storage

## 📂 Project Structure

```
lib/
├── config/           # Firebase & app config
├── models/           # Data models
├── services/         # Business logic
├── providers/        # Riverpod state
├── screens/          # UI screens
├── widgets/          # Reusable components
├── utils/            # Utilities
└── main.dart        # Entry point
```

## 🎯 Core Modules

### 1. Authentication
- User registration & login
- Password management
- Role-based navigation (staff vs. dealer portal)

### 2. Vehicle Management
- CRUD operations
- Real-time updates
- Inventory tracking

### 3. Sales Management
- Transaction recording
- Image uploads
- Profit calculation

### 4. Dealer Management
- CRUD operations
- Contact tracking
- Commission management

### 5. Dashboard
- Statistics & metrics
- Quick actions
- Overview view

## 📚 Documentation

- **[DOCUMENTATION.md](./DOCUMENTATION.md)** - Complete docs
- **[FIREBASE_SETUP.md](./FIREBASE_SETUP.md)** - Firebase guide

## 🔐 Security

- Firebase Authentication
- Firestore security rules
- Encrypted local storage
- Input validation
- HTTPS only

## 🛣️ Routes

```
/login → /register → /dashboard
                        ↓
              /vehicles, /sales, /dealers
```

## 🧪 Testing

```bash
flutter test
```

## 📈 Performance

- Stream-based real-time updates
- Image caching
- Lazy loading
- Optimized queries

## 🐛 Troubleshooting

**Firebase error?** → Check `firebase_options.dart`
**Permission denied?** → Check Firestore security rules
**Image upload fails?** → Check Firebase Storage is enabled

## 🔮 Future Enhancements

- Push notifications
- PDF export
- Advanced analytics
- Dark mode
- Offline support
- Biometric auth

## 📄 License

ISC License

## 👤 Author

Rana Zuhaib - zuhaibshabbir1@gmail.com

---

**Built with ❤️ using Flutter & Firebase** 🚀
