import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String fullName;

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
  });

  // Convert Firestore map → AppUser
  factory AppUser.fromMap(Map<String, dynamic> map, {required String uid}) {
    return AppUser(
      uid: uid,
      email: map['email']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
    );
  }

  // Convert Firestore document → AppUser
  factory AppUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return AppUser(
      uid: doc.id,
      email: data?['email'] ?? '',
      fullName: data?['fullName'] ?? '',
    );
  }

  // Convert AppUser → Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
    };
  }
}
