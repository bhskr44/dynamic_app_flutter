import 'package:flutter/material.dart';

/// Manages form data across widgets in a screen
class FormDataManager extends ChangeNotifier {
  final Map<String, String> _formData = {};
  final Map<String, bool> _widgetVisibility = {};

  /// Set a form field value
  void setValue(String key, String value) {
    _formData[key] = value;
    notifyListeners();
  }

  /// Get a form field value
  String? getValue(String key) {
    return _formData[key];
  }

  /// Get all form data
  Map<String, dynamic> getAllData() {
    return Map<String, dynamic>.from(_formData);
  }

  /// Clear all form data
  void clear() {
    _formData.clear();
    notifyListeners();
  }

  /// Set widget visibility
  void setWidgetVisibility(String widgetId, bool visible) {
    _widgetVisibility[widgetId] = visible;
    notifyListeners();
  }

  /// Get widget visibility
  bool isWidgetVisible(String widgetId) {
    return _widgetVisibility[widgetId] ?? true;
  }

  /// Clear visibility states
  void clearVisibility() {
    _widgetVisibility.clear();
    notifyListeners();
  }
}
