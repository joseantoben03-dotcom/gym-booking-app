import 'package:flutter/foundation.dart';

class AppConstants {
  // ─── AUTO-DETECTED BASE URL PER PLATFORM ────────────────────────────────────
  //
  // Web & Desktop (Windows/macOS/Linux) → backend runs on localhost
  // Android Emulator                    → 10.0.2.2 maps to host machine
  // iOS Simulator                       → localhost works fine
  // Physical device (any)               → set YOUR_PC_IP below
  //
  // For physical devices, replace with your machine's local IP (run `ipconfig`
  // on Windows or `ifconfig` on Mac/Linux to find it).
  static const String _physicalDeviceIp = '192.168.1.100'; // ← change this

  static String get baseUrl {
    if (kIsWeb) {
      // Web runs in browser on same machine as backend
      return 'http://localhost:5000/api';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // 10.0.2.2 = host machine from Android emulator
        // If on physical Android device, swap to _physicalDeviceIp
        return 'http://10.0.2.2:5000/api';
      case TargetPlatform.iOS:
        // localhost works for iOS simulator
        // If on physical iOS device, swap to _physicalDeviceIp
        return 'http://localhost:5000/api';
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return 'http://localhost:5000/api';
      default:
        return 'http://localhost:5000/api';
    }
  }

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // Timeouts (milliseconds)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
