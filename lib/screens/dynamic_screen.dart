// filepath: lib/screens/dynamic_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../core/api_service.dart';
import '../widgets/dynamic_widget_builder.dart';

class DynamicScreen extends StatefulWidget {
  final String apiUrl;
  const DynamicScreen({super.key, required this.apiUrl});

  @override
  State<DynamicScreen> createState() => _DynamicScreenState();
}

class _DynamicScreenState extends State<DynamicScreen> {
  Map<String, dynamic>? screenData;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      Map<String, dynamic> data;
      if (widget.apiUrl.startsWith('http')) {
        data = await ApiService.fetchJson(widget.apiUrl);
      } else {
        // treat as asset path (e.g., "sampleapi.json")
        final raw = await rootBundle.loadString(widget.apiUrl);
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          data = {'widgets': decoded};
        }
      }

      setState(() {
        screenData = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadScreen, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final widgets = (screenData?['widgets'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(screenData?['title']?.toString() ?? 'Dynamic Screen'),
        leading: Navigator.canPop(context)
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _loadScreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgets.map((w) {
              final map = (w as Map<String, dynamic>);
              return DynamicWidgetBuilder.build(map, context, onNavigateRefresh: _loadScreen);
            }).toList(),
          ),
        ),
      ),
    );
  }
}