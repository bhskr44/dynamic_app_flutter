import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

class DynamicWebViewWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;

  const DynamicWebViewWidget({super.key, required this.widgetData});

  @override
  State<DynamicWebViewWidget> createState() => _DynamicWebViewWidgetState();
}

class _DynamicWebViewWidgetState extends State<DynamicWebViewWidget> {
  late final webview.WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final url = widget.widgetData['url']?.toString() ?? '';
    final html = widget.widgetData['html']?.toString();
    final javaScriptEnabled = widget.widgetData['javascript_enabled'] ?? true;

    _controller = webview.WebViewController()
      ..setJavaScriptMode(
        javaScriptEnabled ? webview.JavaScriptMode.unrestricted : webview.JavaScriptMode.disabled,
      )
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        webview.NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (webview.WebResourceError error) {
            setState(() => _isLoading = false);
          },
        ),
      );

    if (html != null && html.isNotEmpty) {
      _controller.loadHtmlString(html);
    } else if (url.isNotEmpty) {
      _controller.loadRequest(Uri.parse(url));
    }
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
          child: Stack(
            children: [
              webview.WebViewWidget(controller: _controller),
              if (_isLoading)
                Container(
                  color: const Color(0xFFF8FAFC),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
