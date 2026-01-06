import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;

  const PdfViewerWidget({super.key, required this.widgetData});

  @override
  Widget build(BuildContext context) {
    final url = widgetData['url']?.toString() ?? '';
    final height = (widgetData['height'] as num?)?.toDouble() ?? 600.0;
    final enableZoom = widgetData['enable_zoom'] ?? true;

    if (url.isEmpty) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('No PDF URL provided'),
        ),
      );
    }

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
          child: SfPdfViewer.network(
            url,
            enableDoubleTapZooming: enableZoom,
            canShowScrollHead: true,
            canShowScrollStatus: true,
          ),
        ),
      ),
    );
  }
}
