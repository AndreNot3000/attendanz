import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance History")),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("attendance")
            .where("userId", isEqualTo: userId)
            .snapshots(), // no orderBy
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No records found."));
          }

          // Sort in memory by timestamp descending
          docs.sort((a, b) {
            final t1 = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            final t2 = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            return t2.compareTo(t1);
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final action = data["action"] ?? "";
              final qrCode = data["qrCode"] ?? "";
              final timestamp = (data["timestamp"] as Timestamp?)?.toDate();
              final name = data["userName"] ?? "Unknown";

              return ListTile(
                leading: Icon(
                  action == "Clock In" ? Icons.login : Icons.logout,
                  color: action == "Clock In" ? Colors.green : Colors.red,
                ),
                title: Text("$action by $name at $qrCode"),
                subtitle: Text(
                  timestamp != null
                      ? "${timestamp.toLocal()}".split('.')[0]
                      : "Time unknown",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
