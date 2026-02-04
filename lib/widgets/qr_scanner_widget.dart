import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;

  const QRScannerWidget({super.key, required this.widgetData});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final MobileScannerController _scannerController =
      MobileScannerController();

  String? scannedData;
  bool _isScanning = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      scannedData = null;
      _isScanning = true;
    });
  }

  void _toggleFlash() {
    _scannerController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.widgetData['mode']?.toString() ?? 'scan';
    final height = (widget.widgetData['height'] as num?)?.toDouble() ?? 300.0;

    /// =======================
    /// QR GENERATE MODE
    /// =======================
    if (mode == 'generate') {
      final data = widget.widgetData['data']?.toString() ?? '';
      final size = (widget.widgetData['size'] as num?)?.toDouble() ?? 200.0;

      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: QrImageView(
            data: data,
            size: size,
            backgroundColor: Colors.white,
          ),
        ),
      );
    }

    /// =======================
    /// WEB → NO SCANNER
    /// =======================
    if (kIsWeb) {
      return _webNotSupportedUI(height);
    }

    /// =======================
    /// MOBILE SCANNER UI
    /// =======================
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _buildMobileContent(),
      ),
    );
  }

  Widget _buildMobileContent() {
    if (!_isScanning && scannedData == null) {
      return _startScanUI();
    }

    if (_isScanning && scannedData == null) {
      return Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              if (barcode.rawValue != null) {
                setState(() {
                  scannedData = barcode.rawValue;
                  _isScanning = false;
                });
              }
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _toggleFlash,
              backgroundColor: Colors.white,
              child: const Icon(Icons.flash_on, color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      );
    }

    return _resultUI();
  }

  Widget _startScanUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _startScanning,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Start Scanning'),
          ),
        ],
      ),
    );
  }

  Widget _resultUI() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 60, color: Color(0xFF10B981)),
          const SizedBox(height: 16),
          const Text(
            'QR Code Scanned',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SelectableText(scannedData ?? ''),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _startScanning,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  Widget _webNotSupportedUI(double height) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: const Text(
        'QR Scanner not available on Web.\nUse mobile app.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
