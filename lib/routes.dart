import 'package:attendance_app/pages/attendance_list.dart';
import 'package:attendance_app/pages/home.dart';
import 'package:attendance_app/pages/qr_generator.dart';
import 'package:attendance_app/pages/scan_qr.dart';
import 'package:attendance_app/pages/sign_in.dart';
import 'package:attendance_app/pages/sign_up.dart';
import 'package:get/get.dart';
import 'pages/splash_page.dart';



class Routes {
  static const splash = '/';
  static const signin = '/signin';
  static const signup = '/signup';
  static const home = '/home';
  static const scan = '/scan';
  static const list = '/attendance_list';
  static const qrGen = '/qr-generator';



  static final pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: signin, page: () => SignInPage()),
    GetPage(name: signup, page: () => const SignUpPage()),
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: scan, page: () => ScanQRPage(action: Get.arguments as String,)),
    GetPage(name: list, page: () => const AttendanceHistoryScreen()),
    GetPage(name: qrGen, page: () => const QRGeneratorPage()),

  ];
}