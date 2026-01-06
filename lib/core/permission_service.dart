import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  /// Request camera permission
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library permission
  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  /// Request location permission
  static Future<bool> requestLocation() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Request contacts permission
  static Future<bool> requestContacts() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  /// Request microphone permission
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Request storage permission (Android)
  static Future<bool> requestStorage() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Request notification permission
  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  /// Check if photos permission is granted
  static Future<bool> hasPhotosPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  /// Check if contacts permission is granted
  static Future<bool> hasContactsPermission() async {
    return await Permission.contacts.isGranted;
  }

  /// Request permission with user-friendly dialog
  static Future<bool> requestPermissionWithDialog({
    required BuildContext context,
    required Permission permission,
    required String title,
    required String message,
  }) async {
    // Check current status
    final status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      return await _showOpenSettingsDialog(
        context: context,
        title: title,
        message: '$message\n\nPermission was permanently denied. Please enable it in settings.',
      );
    }

    // Show explanation dialog
    final shouldRequest = await _showPermissionDialog(
      context: context,
      title: title,
      message: message,
    );

    if (!shouldRequest) {
      return false;
    }

    // Request permission
    final newStatus = await permission.request();
    return newStatus.isGranted || newStatus.isLimited;
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Show dialog to open app settings
  static Future<bool> _showOpenSettingsDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Check multiple permissions status
  static Future<bool> checkMultiple(List<Permission> permissions) async {
    for (var permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted && !status.isLimited) {
        return false;
      }
    }
    return true;
  }
}
