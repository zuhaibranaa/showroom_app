# Showroom Flutter App - Complete Documentation

## Project Overview

This is a comprehensive **Showroom Management Flutter Application** built with **Firebase** and inspired by the Node.js/Vue.js reference project. The app includes complete features for managing vehicles, sales, dealers, and user authentication.

## Architecture & Technologies

### Frontend Stack
- **Flutter 3.11+** - Cross-platform mobile framework
- **Dart** - Programming language
- **Riverpod** - State management solution
- **Go Router** - Navigation and routing
- **Firebase** - Backend services (Auth, Firestore, Storage)

### Backend Services
- **Firebase Authentication** - User registration & login
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - Image storage

## Project Structure

```
lib/
├── config/              # Configuration files
│   ├── app_config.dart
│   ├── firebase_config.dart
│   └── firebase_options.dart
├── models/              # Data models
│   ├── user_model.dart
│   ├── vehicle_model.dart
│   ├── sale_model.dart
│   └── dealer_model.dart
├── services/            # Business logic & Firebase integration
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── vehicle_service.dart
│   ├── sale_service.dart
│   ├── dealer_service.dart
│   └── storage_service.dart
├── providers/           # Riverpod state management
│   ├── auth_provider.dart
│   ├── vehicle_provider.dart
│   ├── sale_provider.dart
│   └── dealer_provider.dart
├── screens/             # UI Screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── vehicles/
│   │   ├── vehicle_list_screen.dart
│   │   ├── vehicle_detail_screen.dart
│   │   └── add_vehicle_screen.dart
│   ├── sales/
│   │   ├── sales_list_screen.dart
│   │   ├── sales_detail_screen.dart
│   │   └── add_sale_screen.dart
│   ├── dealers/
│   │   ├── dealer_list_screen.dart
│   │   ├── dealer_detail_screen.dart
│   │   └── add_dealer_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/             # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── custom_card.dart
│   └── loading_and_error.dart
├── utils/               # Utility functions
│   ├── constants.dart
│   ├── validators.dart
│   └── extensions.dart
└── main.dart           # App entry point
```

## Features Implemented

### ✅ Authentication Module
- **User Registration** with email validation
- **User Login** with email and password
- **Password Reset** functionality
- **Password Change** for logged-in users
- **Session Management** with JWT tokens
- **Secure Token Storage** using Flutter Secure Storage

### ✅ Vehicle Management
- **Create Vehicle** - Add new vehicles with details
- **Read Vehicle** - View all vehicles and individual details
- **Update Vehicle** - Modify vehicle information
- **Delete Vehicle** - Remove vehicles from system
- **Vehicle List View** - Display with filtering and sorting
- **Real-time Updates** - Stream-based data synchronization

### ✅ Sales Management
- **Create Sale Record** - Add new sales transactions
- **Read Sales** - View all sales and individual details
- **Update Sale** - Modify sale information
- **Delete Sale** - Remove sales records
- **Price Validation** - Ensure sale_price >= purchase_price
- **Image Upload** - Support multiple image uploads to Firebase Storage
- **Profit Calculation** - Automatic profit tracking
- **Real-time Sales** - Stream-based updates

### ✅ Dealer Management
- **Create Dealer** - Add new dealers to system
- **Read Dealers** - View all dealers and individual details
- **Update Dealer** - Modify dealer information
- **Delete Dealer** - Remove dealers from system
- **Dealer Tracking** - Commission and license management
- **Real-time Updates** - Stream-based dealer data

### ✅ User Management
- **User Profile** - Create and manage user profiles
- **Profile Information** - Store user details
- **Profile Image** - Upload and manage profile pictures
- **User Stream** - Real-time profile updates

### ✅ Dashboard
- **Statistics Overview** - Display key metrics
  - Total Vehicles
  - Total Sales
  - Total Dealers
  - Total Profit
- **Quick Actions** - Fast navigation to common tasks
- **Responsive Design** - Adapts to different screen sizes
- **Refresh Capability** - Pull-to-refresh all data

### ✅ State Management
- **Riverpod Providers** for all data entities
- **Async State Handling** - Loading, success, error states
- **Real-time Streaming** - Stream providers for live updates
- **Global State** - App-wide authentication state

### ✅ Security
- **Password Hashing** - Firebase handles bcrypt hashing
- **JWT Tokens** - Token-based authentication
- **Secure Storage** - Encrypted local storage
- **Input Validation** - Client-side form validation
- **CORS Enabled** - Secure API communication

## Models & Data Structures

### User Model
```dart
UserModel {
  id: String,
  email: String,
  username: String,
  fullName: String?,
  profileImageUrl: String?,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### Vehicle Model
```dart
VehicleModel {
  id: String,
  make: String,
  model: String,
  year: int,
  color: String,
  licensePlate: String,
  vin: String,
  description: String?,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### Sale Model
```dart
SaleModel {
  id: String,
  vehicleId: String,
  dealerId: String,
  buyerName: String,
  buyerEmail: String,
  buyerPhone: String,
  purchasePrice: double,
  salePrice: double,
  imageUrls: List<String>?,
  notes: String?,
  saleDate: DateTime,
  createdAt: DateTime,
  updatedAt: DateTime,
  profit: double (calculated),
}
```

### Dealer Model
```dart
DealerModel {
  id: String,
  name: String,
  email: String,
  phone: String,
  address: String,
  city: String,
  licenseNumber: String?,
  commissionPercent: String?,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

## Setup Instructions

### Prerequisites
- Flutter 3.11 or higher
- Dart SDK 3.11 or higher
- Firebase Project
- Firebase CLI (optional)

### Installation Steps

1. **Clone the repository**
   ```bash
   cd /Users/zohaib/FProjects/showroom_app
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Firebase Authentication (Email/Password)
   - Create a Firestore database
   - Enable Firebase Storage
   - Update `lib/config/firebase_options.dart` with your Firebase credentials
   
   For iOS/Android setup:
   ```bash
   flutterfire configure
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Firestore Collections

### users
```
- userId (doc ID)
  - id: string
  - email: string
  - username: string
  - fullName: string
  - profileImageUrl: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

### vehicles
```
- vehicleId (doc ID)
  - id: string
  - make: string
  - model: string
  - year: number
  - color: string
  - licensePlate: string
  - vin: string
  - description: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

### sales
```
- saleId (doc ID)
  - id: string
  - vehicleId: string
  - dealerId: string
  - buyerName: string
  - buyerEmail: string
  - buyerPhone: string
  - purchasePrice: number
  - salePrice: number
  - imageUrls: array
  - notes: string
  - saleDate: timestamp
  - createdAt: timestamp
  - updatedAt: timestamp
```

### dealers
```
- dealerId (doc ID)
  - id: string
  - name: string
  - email: string
  - phone: string
  - address: string
  - city: string
  - licenseNumber: string
  - commissionPercent: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

## State Management with Riverpod

### Providers Overview

**Auth Providers**
- `authServiceProvider` - Firebase Auth service
- `currentUserStreamProvider` - Current user stream
- `loginStateProvider` - Login state notifier
- `registrationStateProvider` - Registration state notifier
- `userProfileProvider` - User profile future
- `userProfileStreamProvider` - Real-time user profile

**Vehicle Providers**
- `vehicleServiceProvider` - Vehicle service
- `vehiclesProvider` - All vehicles (future)
- `vehiclesStreamProvider` - Real-time vehicles
- `vehicleByIdProvider` - Single vehicle
- `createVehicleProvider` - Create vehicle state
- `updateVehicleProvider` - Update vehicle state
- `deleteVehicleProvider` - Delete vehicle state

**Sale Providers**
- `saleServiceProvider` - Sale service
- `salesProvider` - All sales (future)
- `salesStreamProvider` - Real-time sales
- `saleByIdProvider` - Single sale
- `salesByVehicleProvider` - Sales by vehicle
- `totalProfitProvider` - Total profit calculation
- `createSaleProvider` - Create sale state
- `updateSaleProvider` - Update sale state
- `deleteSaleProvider` - Delete sale state

**Dealer Providers**
- `dealerServiceProvider` - Dealer service
- `dealersProvider` - All dealers (future)
- `dealersStreamProvider` - Real-time dealers
- `dealerByIdProvider` - Single dealer
- `createDealerProvider` - Create dealer state
- `updateDealerProvider` - Update dealer state
- `deleteDealerProvider` - Delete dealer state

## Routing

The app uses `go_router` for navigation:

- `/login` - Login screen
- `/register` - Registration screen
- `/dashboard` - Main dashboard
- `/vehicles` - Vehicle list
- `/vehicles/add` - Add new vehicle
- `/vehicles/:id` - Vehicle details
- `/sales` - Sales list
- `/sales/add` - Record new sale
- `/sales/:id` - Sale details
- `/dealers` - Dealer list
- `/dealers/add` - Add new dealer
- `/dealers/:id` - Dealer details

## Validation Rules

### Email Validation
- Valid email format required
- Pattern: `user@domain.com`

### Password Validation
- Minimum 6 characters
- Required field

### Phone Validation
- Minimum 10 digits
- Must contain only numbers

### Numeric Fields
- Sale price must be >= purchase price
- All numeric inputs validated

## Widgets & Components

### CustomButton
Reusable button component with loading state

### CustomTextField
Form input with validators and icons

### CustomCard
Material card with tap action support

### LoadingWidget
Loading indicator with optional message

### ErrorWidget
Error display with retry option

## Utilities

### Validators
- Email validation
- Password validation
- Username validation
- Phone number validation
- Numeric validation
- Required field validation

### Extensions
- DateTime formatting
- Number formatting (currency, percentage)
- String utilities (capitalize, email validation)

## Error Handling

The app implements comprehensive error handling:
- Firebase Auth exceptions mapped to user-friendly messages
- Network error handling
- Validation error messages
- Try-catch blocks in all services
- Error UI components with retry options

## Dependencies

```yaml
firebase_core: ^3.1.0
firebase_auth: ^5.1.0
cloud_firestore: ^5.1.0
firebase_storage: ^12.1.0
provider: ^6.1.0
riverpod: ^2.5.0
flutter_riverpod: ^2.5.0
go_router: ^14.2.0
http: ^1.2.0
dio: ^5.4.0
cached_network_image: ^3.3.1
image_picker: ^1.1.0
flutter_secure_storage: ^9.2.0
intl: ^0.19.0
```

## Build & Deployment

### Building for iOS
```bash
flutter build ios
```

### Building for Android
```bash
flutter build apk
```

### Building for Release
```bash
flutter build appbundle
```

## Performance Optimization

- Stream-based real-time updates prevent unnecessary rebuilds
- Image caching with `cached_network_image`
- Lazy loading in list views
- Efficient Riverpod state management
- Optimized queries with Firestore indexing

## Testing

Run tests:
```bash
flutter test
```

## Future Enhancements

- [ ] Offline support with local Hive database
- [ ] Advanced filtering and search
- [ ] PDF export for reports
- [ ] Image gallery for sales records
- [ ] Dealer commission calculations
- [ ] Analytics dashboard
- [ ] Push notifications
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Biometric authentication

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

ISC License - See LICENSE file

## Support

For issues and questions, please create an issue in the repository.

---

**Built with ❤️ using Flutter & Firebase**
