import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScannerWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;

  const QRScannerWidget({super.key, required this.widgetData});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;
  bool _isScanning = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code;
        _isScanning = false;
      });
      controller.pauseCamera();
    });
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      scannedData = null;
    });
    controller?.resumeCamera();
  }

  void _toggleFlash() {
    controller?.toggleFlash();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.widgetData['mode']?.toString() ?? 'scan'; // scan or generate
    final height = (widget.widgetData['height'] as num?)?.toDouble() ?? 300.0;

    if (mode == 'generate') {
      final data = widget.widgetData['data']?.toString() ?? '';
      final size = (widget.widgetData['size'] as num?)?.toDouble() ?? 200.0;

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

    // Scanner mode
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              if (!_isScanning && scannedData == null)
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner,
                            size: 80,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _startScanning,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Start Scanning'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_isScanning)
                Expanded(
                  child: Stack(
                    children: [
                      QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                        overlay: QrScannerOverlayShape(
                          borderColor: const Color(0xFF3B82F6),
                          borderRadius: 10,
                          borderLength: 30,
                          borderWidth: 10,
                          cutOutSize: 250,
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: _toggleFlash,
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.flash_on,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (scannedData != null)
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'QR Code Scanned',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: SelectableText(
                            scannedData!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _startScanning,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Scan Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
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
