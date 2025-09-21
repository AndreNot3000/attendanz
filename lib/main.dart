import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/attendance_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDlb6awcJbQOBrrKP-dAjMzSaPIvWZ44mk",
      authDomain: "attendanz-app.firebaseapp.com",
      projectId: "attendanz-app",
      storageBucket: "attendanz-app.firebasestorage.app",
      messagingSenderId: "86873546841",
      appId: "1:86873546841:web:89b63ac2fa74598787d148",
      measurementId: "G-GG9JL4P760",
    ),
  );

  Get.put(AuthController()); // manages authentication
  Get.put(AttendanceController()); // manages attendance

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: Routes.pages,
    );
  }
}
