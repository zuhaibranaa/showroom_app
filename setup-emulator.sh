#!/bin/bash

# Firebase Emulator Setup Script for Flutter Showroom App
# This script sets up Firebase Emulator Suite for local development

echo "🚀 Firebase Emulator Setup for Showroom App"
echo "==========================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
else
    echo "✅ Firebase CLI found"
    firebase --version
fi

# Create firebase.json if it doesn't exist
if [ ! -f firebase.json ]; then
    echo ""
    echo "📝 Creating firebase.json configuration..."
    cat > firebase.json << 'EOF'
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
EOF
    echo "✅ firebase.json created"
else
    echo "✅ firebase.json already exists"
fi

# Create sample Firestore rules
if [ ! -f firestore.rules ]; then
    echo "📝 Creating firestore.rules..."
    cat > firestore.rules << 'EOF'
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes in development
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
EOF
    echo "✅ firestore.rules created"
fi

# Create sample Storage rules
if [ ! -f storage.rules ]; then
    echo "📝 Creating storage.rules..."
    cat > storage.rules << 'EOF'
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow all reads and writes in development
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
EOF
    echo "✅ storage.rules created"
fi

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Update lib/config/firebase_config.dart:"
echo "   - Change: static const bool useEmulator = true;"
echo ""
echo "2. Start Firebase Emulator in a new terminal:"
echo "   firebase emulators:start"
echo ""
echo "3. Access Emulator UI:"
echo "   http://localhost:4000"
echo ""
echo "4. Run Flutter app:"
echo "   flutter run"
echo ""
