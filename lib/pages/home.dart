import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes.dart';
import '../controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Attendance Dashboard'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
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
      body: Obx(() {
        final user = authController.profile.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Profile Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0] : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user.fullName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email),
                ),
              ),
              const SizedBox(height: 30),

              // 📌 Action Buttons
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildActionCard(
                      icon: Icons.qr_code,
                      label: "Show Company QR",
                      color: Colors.blue,
                      onTap: () => Get.toNamed(Routes.qrGen),
                    ),
                    _buildActionCard(
                      icon: Icons.login,
                      label: "Clock In",
                      color: Colors.green,
                      onTap: () =>
                          Get.toNamed(Routes.scan, arguments: "Clock In"),
                    ),
                    _buildActionCard(
                      icon: Icons.logout,
                      label: "Clock Out",
                      color: Colors.red,
                      onTap: () =>
                          Get.toNamed(Routes.scan, arguments: "Clock Out"),
                    ),
                    _buildActionCard(
                      icon: Icons.list,
                      label: "Attendance Records",
                      color: Colors.orange,
                      onTap: () => Get.toNamed(Routes.list),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionCard(
      {required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: color.withOpacity(0.1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
