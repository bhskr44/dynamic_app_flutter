import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class DynamicWebViewWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;

  const DynamicWebViewWidget({super.key, required this.widgetData});

  @override
  State<DynamicWebViewWidget> createState() => _DynamicWebViewWidgetState();
}

class _DynamicWebViewWidgetState extends State<DynamicWebViewWidget> {
  final String _iframeId = 'webview-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _registerIframe();
  }

  void _registerIframe() {
    final url = widget.widgetData['url']?.toString() ?? '';
    final htmlContent = widget.widgetData['html']?.toString() ?? widget.widgetData['html_content']?.toString();

    // Create iframe element
    final iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    if (htmlContent != null && htmlContent.isNotEmpty) {
      // Create a blob URL from HTML content
      final blob = html.Blob([htmlContent], 'text/html');
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      iframe.src = blobUrl;
    } else if (url.isNotEmpty) {
      iframe.src = url;
    }

    // Register the view
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = (widget.widgetData['height'] as num?)?.toDouble() ?? 400.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: HtmlElementView(viewType: _iframeId),
        ),
      ),
    );
  }
}
