import 'package:attendance_app/pages/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/attendance_controller.dart';

class ScanQRPage extends StatefulWidget {
  final String action; // <-- required argument

  const ScanQRPage({super.key, required this.action});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  String? result;
  final AttendanceController attendanceController = Get.find();
  bool isProcessing = false;

  Future<void> handleScan(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    setState(() => result = code);

    if (code == "attendance_office_main") {
      try {
        final actionType =
        await attendanceController.recordScan(code, widget.action);

        // ✅ Success → Navigate to SuccessScreen
        Get.to(() => SuccessScreen(action: actionType));
      } catch (e) {
        // ✅ Error → Show snackbar
        Get.snackbar(
          "Action Not Allowed",
          e.toString().replaceFirst("Exception: ", ""), // clean up text
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } else {
      Get.snackbar("Error", "Invalid QR Code");
    }

    await Future.delayed(const Duration(seconds: 2));
    isProcessing = false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR - ${widget.action}")), // ✅ Safe now
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (capture) {
                for (final barcode in capture.barcodes) {
                  final String? code = barcode.rawValue;
                  if (code != null) handleScan(code);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(result != null ? 'Result: $result' : 'Scan a code'),
            ),
          ),
        ],
      ),
    );
  }
}
