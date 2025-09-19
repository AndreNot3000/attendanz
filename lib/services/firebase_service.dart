import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class FirebaseService {
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase init error: $e');
      rethrow;
    }
  }
}