import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScannerWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;

  const QRScannerWidget({super.key, required this.widgetData});

  @override
  Widget build(BuildContext context) {
    final mode = widgetData['mode']?.toString() ?? 'scan';
    final height = (widgetData['height'] as num?)?.toDouble() ?? 300.0;

    if (mode == 'generate') {
      // QR Generation works on web
      final data = widgetData['data']?.toString() ?? '';
      final size = (widgetData['size'] as num?)?.toDouble() ?? 200.0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: size,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    // QR Scanner not available on web
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 16),
              Text(
                'QR Scanner Not Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'QR code scanning is only available on mobile devices.\nPlease use the mobile app to scan QR codes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
