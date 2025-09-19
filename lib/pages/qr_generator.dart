import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorPage extends StatelessWidget {
  const QRGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String qrData = "attendance_office_main"; // 👈 unique ID for this location

    return Scaffold(
      appBar: AppBar(title: const Text("Company Attendance QR")),
      body: Center(
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 300.0,
        ),
      ),
    );
  }
}
