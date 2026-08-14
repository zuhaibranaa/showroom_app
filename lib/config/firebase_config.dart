import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Call this to test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // Test Firestore connection
      await FirebaseFirestore.instance
          .collection('_test')
          .doc('connection')
          .get()
          .timeout(const Duration(seconds: 5));

      debugPrint('Firebase connected successfully');
      return true;
    } catch (e) {
      debugPrint('Firebase connection failed: $e');
      return false;
    }
  }
}
