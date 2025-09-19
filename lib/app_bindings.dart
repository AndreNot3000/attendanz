import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/attendance_controller.dart';


class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(AttendanceController());
  }
}