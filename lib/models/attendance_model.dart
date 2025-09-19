import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String userId;
  final String userName; // ✅ Added
  final DateTime timestamp;
  final String action; // 'Clock In' / 'Clock Out'
  final String qrCode;

  Attendance({
    required this.id,
    required this.userId,
    required this.userName, // ✅ Added
    required this.timestamp,
    required this.action,
    required this.qrCode,
  });

  factory Attendance.fromMap(Map<String, dynamic> m, String id) => Attendance(
    id: id,
    userId: m['userId'] ?? '',
    userName: m['userName'] ?? '', // ✅ Added
    timestamp: m['timestamp'] != null
        ? (m['timestamp'] as Timestamp).toDate()
        : DateTime.now(),
    action: m['action'] ?? 'Clock In',
    qrCode: m['qrCode'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName, // ✅ Added
    'timestamp': timestamp,
    'action': action,
    'qrCode': qrCode,
  };
}
