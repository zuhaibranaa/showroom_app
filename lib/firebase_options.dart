import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAR3ZEbM18GtyW9A8TQ2fnEZzeXrqaJ2d0',
    appId: '1:980299890377:android:f6f0435275d45f8f5a1718',
    messagingSenderId: '980299890377',
    projectId: 'showroom-38240',
    storageBucket: 'showroom-38240.firebasestorage.app',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_-lNddSe2izzQ4j0v9gcZkOGfPOakRRM',
    appId: '1:980299890377:web:7bdd3de74d0715ac5a1718',
    messagingSenderId: '980299890377',
    projectId: 'showroom-38240',
    authDomain: 'showroom-38240.firebaseapp.com',
    storageBucket: 'showroom-38240.firebasestorage.app',
  );
}
