import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String action; // 'Clock In' / 'Clock Out'
  final String qrCode;
  final String role;   // admin / employee

  Attendance({
    required this.id,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.action,
    required this.qrCode,
    this.role = "employee",
  });

  factory Attendance.fromMap(Map<String, dynamic> m, String id) => Attendance(
    id: id,
    userId: m['userId'] ?? '',
    userName: m['userName'] ?? '',
    timestamp: m['timestamp'] != null
        ? (m['timestamp'] as Timestamp).toDate()
        : DateTime.now(),
    action: m['action'] ?? 'Clock In',
    qrCode: m['qrCode'] ?? '',
    role: m['role'] ?? 'employee',
  );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'timestamp': Timestamp.fromDate(timestamp), // ✅ safer than raw DateTime
    'action': action,
    'qrCode': qrCode,
    'role': role,
  };
}
