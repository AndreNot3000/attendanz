import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String role; // ✅ Added

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
  });

  // Firestore map → AppUser
  factory AppUser.fromMap(Map<String, dynamic> map, {required String uid}) {
    return AppUser(
      uid: uid,
      email: map['email']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      role: map['role']?.toString() ?? 'employee', // default employee
    );
  }

  // Firestore document → AppUser
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return AppUser(
      uid: doc.id,
      email: data?['email'] ?? '',
      fullName: data?['fullName'] ?? '',
      role: data?['role'] ?? 'employee',
    );
  }

  // AppUser → Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
    };
  }
}
