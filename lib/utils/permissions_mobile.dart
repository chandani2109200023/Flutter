import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For storing state across app launches

class PermissionsHelper {
  /// Handle all permissions
  static Future<void> handlePermissions() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if the app is being run for the first time after reinstalling
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      await handleCameraPermission();
      if (Platform.isIOS) await handlePhotosPermission();
      await handleLocationPermission();
      await handleStoragePermission();
      if (Platform.isAndroid) await handleManageExternalStoragePermission();
      await handleNotificationPermission();

      // Set 'isFirstRun' to false after first run
      await prefs.setBool('isFirstRun', false);
    }
  }

  /// Handle Camera Permission
  static Future<void> handleCameraPermission() async {
    final granted = await _requestPermission(Permission.camera);
    if (!granted) {
      print('Camera permission not granted.');
    }
  }

  /// Handle Photos Permission (iOS-specific)
  static Future<void> handlePhotosPermission() async {
    final granted = await _requestPermission(Permission.photos);
    if (!granted) {
      print('Photos permission not granted.');
    }
  }

  /// Handle Location Permission
  static Future<void> handleLocationPermission() async {
    final granted = await _requestPermission(Permission.location);
    if (!granted) {
      print('Location permission not granted.');
    }
  }

  /// Handle Storage Permission
  static Future<void> handleStoragePermission() async {
    final granted = await _requestPermission(Permission.storage);
    if (!granted) {
      print('Storage permission not granted.');
    }
  }

  /// Handle Manage External Storage Permission (Android-specific)
  static Future<void> handleManageExternalStoragePermission() async {
    final granted = await _requestPermission(Permission.manageExternalStorage);
    if (!granted) {
      print('Manage External Storage permission not granted.');
    }
  }

  /// Handle Notification Permission
  static Future<void> handleNotificationPermission() async {
    final granted = await _requestPermission(Permission.notification);
    if (!granted) {
      print('Notification permission not granted.');
    }
  }

  /// Request permission explicitly (even if already granted)
  static Future<bool> _requestPermission(Permission permission) async {
    final result = await permission.request();

    if (result.isGranted) {
      print('${permission.toString()} permission granted.');
      return true;
    } else if (result.isDenied) {
      print('${permission.toString()} permission denied.');
      return false;
    } else if (result.isPermanentlyDenied) {
      print(
          '${permission.toString()} permission permanently denied. Please enable it in app settings.');
      openAppSettings(); // Optionally guide the user to app settings
      return false;
    }

    return false;
  }
}
