import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SuccessScreen extends StatelessWidget {
  final String action;

  const SuccessScreen({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final name = authController.profile.value?.fullName ?? "User";

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Success")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action == "Clock In" ? Icons.login : Icons.logout,
              size: 80,
              color: action == "Clock In" ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              "$action successful for $name!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed('/home'); // go straight to Home
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}
