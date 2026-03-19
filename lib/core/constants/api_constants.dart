import 'package:flutter/foundation.dart';

class ApiConstants {
  // use the wifi
  /// Web can reach localhost, mobile cannot.
  static const String _baseUrlWeb = "http://localhost:3000/api/v1";

  /// Default for Android emulator.
  // static const String _baseUrlEmulator = "http://10.0.2.2:3000/api/v1";
  // static const String _baseUrlEmulator = "http://192.168.1.33:3000/api/v1"; home
  static const String _baseUrlEmulator =
      "http://192.168.18.119:3000/api/v1"; // office techey
  // static const String _baseUrlEmulator = "http://192.168.1.33:3000/api/v1"; // RUPP

  /// Optional override for physical devices: pass --dart-define=API_BASE_URL=http://<your-ip>:3000/api/v1
  static const String _baseUrlDefine = String.fromEnvironment('API_BASE_URL');

  /// Picks the right base URL based on platform and optional dart-define.
  static String get baseUrl {
    if (kIsWeb) return _baseUrlWeb;

    if (_baseUrlDefine.isNotEmpty) return _baseUrlDefine;

    // Fallback for emulator; for physical devices set API_BASE_URL via --dart-define or update this value.
    return _baseUrlEmulator;
  }

  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String me = "/auth/me";
  static const String logout = "/auth/logout";
  static const String categories = "/categories";
  static const String authors = "/authors";
  static const String books = "/books";
  static const String cart = "/carts";
  static const String order = "/orders";
  static const String payment = "/payments";
  static const String stripePublishableKey =
      "pk_test_51T5IgFQ1geBHVp8Zpzt0OQK3R1n04Va4ynpPilEAnweHZWj6ZvWQZvmPuB1QynHEsaA5dlEGhBcJix2Ix6o4gSLp00uDz1mKiq";
}
