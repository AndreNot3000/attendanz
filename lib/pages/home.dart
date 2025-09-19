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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Attendance Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Welcome Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.fullName.isNotEmpty ? user.fullName[0] : "?",
                          style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome,",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14),
                          ),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 📌 Action Buttons Grid
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                      icon: Icons.list_alt,
                      label: "Attendance Records",
                      color: Colors.orange,
                      onTap: () => Get.toNamed(Routes.list),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 30,
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
