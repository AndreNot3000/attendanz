import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class AttendanceController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthController authController = Get.find();

  /// Record a scan with automatic Clock In / Clock Out toggle
  Future<String> recordScan(String qrCode, String actionType) async {
    final user = authController.firebaseUser.value;

    if (user == null) {
      throw Exception("No user logged in");
    }

    // Reload profile from Firestore if it's null
    AppUser? profile = authController.profile.value;
    if (profile == null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception("User profile not found");

      profile = AppUser.fromFirestore(doc);
      authController.profile.value = profile;
    }

    // Check last action to prevent duplicate Clock In or Clock Out
    final snapshot = await _db
        .collection('attendance')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final lastAction = snapshot.docs.first['action'] as String;

      if (lastAction == actionType) {
        return "duplicate"; // special flag for duplicate actions
      }

    }

    // Save record
    await _db.collection('attendance').add({
      'userId': user.uid,
      'userName': profile.fullName,
      'timestamp': FieldValue.serverTimestamp(),
      'action': actionType,
      'qrCode': qrCode,
    });

    print("✅ Saved: $actionType for ${profile.fullName} at QR $qrCode");
    return actionType;
  }



  /// Stream attendance records for current user as a List<Attendance>
  Stream<List<Attendance>> streamForUser() {
    final user = authController.firebaseUser.value;
    if (user == null) throw Exception("No user logged in");

    return _db
        .collection('attendance')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true) // ✅ newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Attendance.fromMap(doc.data(), doc.id))
        .toList());
  }

}
