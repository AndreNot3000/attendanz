import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AuthController authController = Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Set<String> _selectedRecords = {};

  void _toggleSelection(String recordId) {
    setState(() {
      if (_selectedRecords.contains(recordId)) {
        _selectedRecords.remove(recordId);
      } else {
        _selectedRecords.add(recordId);
      }
    });

    // ✅ Show how many records are selected
    if (_selectedRecords.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_selectedRecords.length} record(s) selected"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _deleteSelected() async {
    final confirm = await _confirmDialog("Delete selected records?");
    if (!confirm) return;

    final batch = _db.batch();
    for (final id in _selectedRecords) {
      final docRef = _db.collection('attendance').doc(id);
      batch.delete(docRef);
    }

    await batch.commit();

    setState(() {
      _selectedRecords.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Selected records deleted successfully")),
    );
  }

  Future<void> _deleteAll() async {
    final confirm = await _confirmDialog("Delete ALL records?");
    if (!confirm) return;

    final snapshot = await _db.collection('attendance').get();
    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    setState(() {
      _selectedRecords.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All records deleted successfully")),
    );
  }



  Future<bool> _confirmDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final attendanceRef =
    _db.collection('attendance').orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        actions: [
          if (_selectedRecords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: "Delete Selected",
              onPressed: _deleteSelected,
            ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Delete All",
            onPressed: _deleteAll,
          ),
          // ✅ Select All / Deselect All toggle
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('attendance').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final docs = snapshot.data!.docs;
              final allSelected = _selectedRecords.length == docs.length && docs.isNotEmpty;

              return IconButton(
                icon: Icon(allSelected ? Icons.deselect : Icons.select_all),
                tooltip: allSelected ? "Deselect All" : "Select All",
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      _selectedRecords.clear();
                    } else {
                      _selectedRecords
                        ..clear()
                        ..addAll(docs.map((doc) => doc.id));
                    }
                  });
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await authController.signOut();
              Get.offAllNamed(Routes.signin);
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: attendanceRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No attendance records yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final fullName = data['userName'] ?? 'Unknown';
              final action = data['action'] ?? '';
              final qrCode = data['qrCode'] ?? '';
              final scannedAt = (data['timestamp'] as Timestamp?)?.toDate();

              final isSelected = _selectedRecords.contains(doc.id);
              final isClockIn = action == "Clock In";

              return GestureDetector(
                onTap: () => _toggleSelection(doc.id),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? const BorderSide(color: Colors.blue, width: 2)
                        : BorderSide.none,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: isSelected ? Colors.blue.withOpacity(0.08) : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isClockIn ? Colors.green : Colors.red,
                      radius: 24,
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : "?",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isClockIn
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  action,
                                  style: TextStyle(
                                    color: isClockIn
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (qrCode.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    "QR: $qrCode",
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                scannedAt != null
                                    ? scannedAt.toLocal().toString().split('.')[0]
                                    : "Unknown",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

    );
  }
}
