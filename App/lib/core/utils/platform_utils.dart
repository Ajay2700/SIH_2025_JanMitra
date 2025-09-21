import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  /// Check if the app is running on the web
  static bool get isWeb => kIsWeb;

  /// Check if the app is running on Android
  static bool get isAndroid => !isWeb && Platform.isAndroid;

  /// Check if the app is running on iOS
  static bool get isIOS => !isWeb && Platform.isIOS;

  /// Check if Google Maps is likely to work
  ///
  /// This is a simple check that doesn't guarantee Maps will work,
  /// but helps handle potential issues in different environments
  static bool get isGoogleMapsSupported {
    if (isWeb) {
      // On web, we can't be sure if Maps will work without trying
      // The script might be loaded but could fail due to API key issues
      return true; // We'll handle errors with try/catch in the UI
    } else if (isAndroid || isIOS) {
      // Maps should work on mobile platforms with proper permissions
      return true;
    }
    // Desktop platforms may not support Maps
    return false;
  }
}
