import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<AppUser> profile = Rxn<AppUser>();

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  /// Decides initial screen based on auth state
  void _setInitialScreen(User? user) async {
    if (user == null) {
      Future.microtask(() => Get.offAllNamed('/signin'));
    } else {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        profile.value = AppUser.fromFirestore(
          doc,
        );
        Future.microtask(() => Get.offAllNamed('/home'));
      } else {
        await _auth.signOut();
        Future.microtask(() => Get.offAllNamed('/signin'));
      }
    }
  }

  void checkAuth() {
    final user = FirebaseAuth.instance.currentUser;
    _setInitialScreen(user);
  }

  /// 🔹 Sign Up and Save Profile
  Future<void> signUp(String email, String password, String fullName) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;

      final appUser = AppUser(
        uid: user.uid,
        email: email,
        fullName: fullName,
      );

      // Save user profile in Firestore
      await _db.collection('users').doc(user.uid).set(appUser.toMap());
      profile.value = appUser;

      // Sign out after signup
      await _auth.signOut();

      Get.offAllNamed('/signin');
      Get.snackbar("Success", "Account created! Please sign in.");
    } catch (e) {
      Get.snackbar("Signup Error", e.toString());
    }
  }

  /// 🔹 Sign In and Load Profile
  Future<void> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user!;
      final doc = await _db.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        // Create profile if missing
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? email,
          fullName: user.displayName ?? 'Unknown User',
        );
        await _db.collection('users').doc(user.uid).set(appUser.toMap());
        profile.value = appUser;
      } else {
        profile.value = AppUser.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
    } catch (e) {
      Get.snackbar("Sign In Error", e.toString());
    }
  }

  /// 🔹 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
