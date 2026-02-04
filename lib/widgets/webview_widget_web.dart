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
  late final String _iframeId;

  @override
  void initState() {
    super.initState();

    // ✅ Stable & unique ID per widget instance
    _iframeId = 'webview-${identityHashCode(this)}';

    _registerIframe();
  }

  void _registerIframe() {
    final url = widget.widgetData['url']?.toString() ?? '';
    final htmlContent =
        widget.widgetData['html']?.toString() ??
        widget.widgetData['html_content']?.toString();

    final iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.display = 'block'
      ..allow =
          'camera; microphone; fullscreen; clipboard-read; clipboard-write';
      iframe.sandbox?.add('allow-scripts');
      iframe.sandbox?.add('allow-same-origin');
      iframe.sandbox?.add('allow-forms');
      iframe.sandbox?.add('allow-popups');
      iframe.sandbox?.add('allow-modals');


    if (htmlContent != null && htmlContent.isNotEmpty) {
      final blob = html.Blob([htmlContent], 'text/html');
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      iframe.src = blobUrl;
    } else if (url.isNotEmpty) {
      iframe.src = url;
    }

    // ✅ Register ONLY ONCE
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawHeight = widget.widgetData['height'];

    final height = rawHeight == 'match_parent'
        ? MediaQuery.of(context).size.height * 0.75
        : (rawHeight as num?)?.toDouble() ?? 400;

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
