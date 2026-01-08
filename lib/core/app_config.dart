// filepath: lib/core/app_config.dart
import 'package:flutter/material.dart';

/// Global app configuration loaded from splash screen API
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  String _appTitle = 'A Dynamic App By COMPLIT';
  String? _appLogoUrl;

  String get appTitle => _appTitle;
  String? get appLogoUrl => _appLogoUrl;

  void setAppTitle(String title) {
    _appTitle = title;
  }

  void setAppLogoUrl(String? url) {
    _appLogoUrl = url;
  }

  void clear() {
    _appTitle = 'A Dynamic App By COMPLIT';
    _appLogoUrl = null;
  }
}
