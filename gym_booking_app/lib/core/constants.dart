import 'package:flutter/foundation.dart';

class AppConstants {
  // ─── PRODUCTION URL ───────────────────────────────────────────────────────
  // After deploying backend to Vercel, set this to your Vercel URL.
  // e.g. 'https://gymbook-backend.vercel.app/api'
  static const String _productionUrl = 'https://YOUR-PROJECT.vercel.app/api';

  // ─── LOCAL DEV URLs ───────────────────────────────────────────────────────
  static const String _physicalDeviceIp = '192.168.1.100'; // ← your PC's local IP

  // ─── AUTO-DETECT ──────────────────────────────────────────────────────────
  static String get baseUrl {
    // Toggle this to true once you have deployed to Vercel
    const bool useProduction = false; // ← change to true after Vercel deploy

    if (useProduction) return _productionUrl;

    if (kIsWeb) return 'http://localhost:5000/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000/api';
      case TargetPlatform.iOS:
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
  static const String userKey  = 'auth_user';

  // Timeouts
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
