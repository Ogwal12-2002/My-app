import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

/// Renders the live QR preview, wrapped in a [Screenshot] widget so the
/// caller can capture it as PNG bytes for save/share.
class QrPreview extends StatelessWidget {
  final String data;
  final ScreenshotController controller;

  const QrPreview({super.key, required this.data, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: data.isEmpty
            ? const SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Icon(Icons.qr_code_2, size: 80, color: Colors.black12),
                ),
              )
            : QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
      ),
    );
  }
}
