# Firebase Setup Guide for Showroom Flutter App

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: `showroom-app`
4. Accept terms and click "Create project"
5. Wait for project creation to complete

## Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Under **Sign-in method**, click **Email/Password**
4. Enable it and click **Save**

## Step 3: Create Firestore Database

1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
   - Note: Use production mode for live apps
4. Select region (default: us-central1)
5. Click **Enable**
6. Create collections:

### Create Collections in Firestore:

**Collection: users**
```
- Document: [auto-generated uid]
  - id: string
  - email: string
  - username: string
  - fullName: string (optional)
  - profileImageUrl: string (optional)
  - createdAt: timestamp
  - updatedAt: timestamp
```

**Collection: vehicles**
```
- Document: [auto-generated id]
  - id: string
  - make: string
  - model: string
  - year: number
  - color: string
  - licensePlate: string
  - vin: string
  - description: string (optional)
  - createdAt: timestamp
  - updatedAt: timestamp
```

**Collection: sales**
```
- Document: [auto-generated id]
  - id: string
  - vehicleId: string
  - dealerId: string
  - buyerName: string
  - buyerEmail: string
  - buyerPhone: string
  - purchasePrice: number
  - salePrice: number
  - imageUrls: array of strings
  - notes: string (optional)
  - saleDate: timestamp
  - createdAt: timestamp
  - updatedAt: timestamp
```

**Collection: dealers**
```
- Document: [auto-generated id]
  - id: string
  - name: string
  - email: string
  - phone: string
  - address: string
  - city: string
  - licenseNumber: string (optional)
  - commissionPercent: string (optional)
  - createdAt: timestamp
  - updatedAt: timestamp
```

## Step 4: Enable Firebase Storage

1. Go to **Storage**
2. Click **Get Started**
3. Choose **Start in test mode**
4. Select region
5. Click **Done**

## Step 5: Get Firebase Credentials

### For Android:
1. In Firebase Console, go to **Project Settings** (gear icon)
2. Under **Your apps**, click the Android app
3. Copy the `google-services.json` file
4. Place it in `android/app/` directory

### For iOS:
1. In Firebase Console, go to **Project Settings**
2. Under **Your apps**, click the iOS app
3. Download the `GoogleService-Info.plist` file
4. Open Xcode: `open ios/Runner.xcworkspace`
5. Drag and drop the `.plist` file into Xcode
6. Make sure it's added to the Runner target

### For Web:
1. In Firebase Console, go to **Project Settings**
2. Copy the Firebase configuration
3. Update `lib/config/firebase_options.dart` with web config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT.appspot.com',
);
```

## Step 6: Update Firebase Options

Edit `lib/config/firebase_options.dart` and update all placeholders with your Firebase credentials.

You can use FlutterFire CLI to automate this:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure FlutterFire
flutterfire configure
```

## Step 7: Create Firestore Security Rules (Test Mode)

**For Development:**
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**For Production:**
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Vehicles collection
    match /vehicles/{doc=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        request.auth.token.email_verified == true;
    }
    
    // Sales collection
    match /sales/{doc=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        request.auth.token.email_verified == true;
    }
    
    // Dealers collection
    match /dealers/{doc=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        request.auth.token.email_verified == true;
    }
  }
}
```

## Step 8: Create Firebase Storage Security Rules

**For Development:**
```firestore
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**For Production:**
```firestore
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Vehicle images
    match /vehicles/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId && 
        request.resource.size < 5 * 1024 * 1024 && 
        request.resource.contentType.matches('image/.*');
    }
    
    // Sale images
    match /sales/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId && 
        request.resource.size < 5 * 1024 * 1024 && 
        request.resource.contentType.matches('image/.*');
    }
    
    // Profile images
    match /profiles/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId && 
        request.resource.size < 2 * 1024 * 1024 && 
        request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Step 9: Install Dependencies

```bash
cd /Users/zohaib/FProjects/showroom_app
flutter pub get
```

## Step 10: Run the App

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d web
```

## Step 11: Test the App

1. **Register** a new account
2. **Login** with your credentials
3. **Navigate to Dashboard** and view statistics
4. **Add a Vehicle** from the dashboard
5. **Record a Sale** with images
6. **Add Dealers** and manage them
7. **View Reports** showing total profit

## Troubleshooting

### Firebase initialization error
- Ensure `firebase_core` is initialized before `runApp()`
- Check that Firebase credentials are correctly configured

### Authentication errors
- Enable Email/Password authentication in Firebase Console
- Check security rules allow unauthenticated registration

### Firestore permission denied
- Check Firestore security rules
- Ensure user is authenticated
- Verify collection paths match

### Image upload fails
- Check Firebase Storage is enabled
- Verify storage security rules
- Ensure file size is under limit (5MB)

### Connection timeout
- Check internet connection
- Verify Firebase project is active
- Check if backend API is accessible

## Environment Variables (Optional)

Create `.env` file in project root:
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
```

Then use in code:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
```

## Next Steps

1. Deploy to Firebase Hosting (web)
2. Set up CI/CD pipeline
3. Configure Analytics
4. Set up Crash Reporting
5. Implement Push Notifications

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Plugins](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security)
- [Firebase Storage Rules](https://firebase.google.com/docs/storage/security)

---

**Setup Complete! You're ready to develop.** 🚀
