import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<AppUser> profile = Rxn<AppUser>();
  var isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  /// Initial screen logic
  void _setInitialScreen(User? user) async {
    if (user == null) {
      Future.microtask(() => Get.offAllNamed('/signin'));
    } else {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        profile.value =
            AppUser.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);

        if (profile.value!.role == "admin") {
          Future.microtask(() => Get.offAllNamed('/adminDashboard'));
        } else {
          Future.microtask(() => Get.offAllNamed('/home'));
        }
      } else {
        await _auth.signOut();
        Future.microtask(() => Get.offAllNamed('/signin'));
      }
    }
  }

  void checkAuth() {
    final user = _auth.currentUser;
    _setInitialScreen(user);
  }

  /// 🔹 Sign Up (always employee)
  Future<void> signUp(String email, String password, String fullName) async {
    try {
      isLoading.value = true; // ✅ start loader

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;

      final appUser = AppUser(
        uid: user.uid,
        email: email,
        fullName: fullName,
        role: "employee", // ✅ always employee
      );

      await _db.collection('users').doc(user.uid).set(appUser.toMap());
      profile.value = appUser;

      await _auth.signOut();

      Get.offAllNamed('/signin');
      Get.snackbar("Success", "Account created! Please sign in.");
    } catch (e) {
      Get.snackbar("Signup Error", e.toString());
    } finally {
      isLoading.value = false; // ✅ stop loader
    }
  }

  /// 🔹 Sign In
  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;

      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user!;
      final doc = await _db.collection('users').doc(user.uid).get();

      if (doc.exists) {
        profile.value = AppUser.fromFirestore(doc);

        if (profile.value!.role == "admin") {
          Get.offAllNamed('/adminDashboard');
        } else {
          Get.offAllNamed('/home');
        }
      } else {
        await _auth.signOut();
        Get.snackbar("Error", "No profile found. Contact Admin.");
      }
    } catch (e) {
      Get.snackbar("Sign In Error", e.toString());
    } finally {
      // ✅ Always reset loading state
      isLoading.value = false;
    }
  }

  /// 🔹 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
