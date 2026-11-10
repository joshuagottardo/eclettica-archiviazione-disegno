import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servizio di persistenza delle impostazioni dell'applicazione.
class SettingsService {
  static const _keyApiKey = 'gemini_api_key_secure';
  static const _keyLegacyApiKey = 'gemini_api_key';
  static const _keyModel = 'gemini_model';
  static const _keyDestination = 'destination_folder';
  static const _keyAuthorMap = 'author_map';
  static const _keyAutoRotate = 'auto_rotate';
  static const _keyDebugMode = 'debug_mode_enabled';

  static const String defaultModel = 'gemini-flash-lite-latest';
  static const Map<String, String> defaultAuthorMap = {};

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    mOptions: MacOsOptions(usesDataProtectionKeychain: false),
  );

  /// Recupera la chiave API (Keychain o SharedPreferences).
  static Future<String> getApiKey() async {
    try {
      final key = await _secureStorage.read(key: _keyApiKey);
      if (key != null && key.trim().isNotEmpty) return key.trim();
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_keyLegacyApiKey);
      if (key != null && key.trim().isNotEmpty) return key.trim();
    } catch (_) {}

    return '';
  }

  /// Salva la chiave API nelle preferenze locali protette.
  static Future<void> setApiKey(String key) async {
    final cleanKey = key.trim();
    try {
      await _secureStorage.write(key: _keyApiKey, value: cleanKey);
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLegacyApiKey, cleanKey);
    } catch (_) {}
  }

  static Future<String> getModel() async {
    return defaultModel;
  }

  static Future<void> setModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyModel, defaultModel);
  }

  static Future<String> getDestinationFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDestination) ?? '';
  }

  static Future<void> setDestinationFolder(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDestination, path);
  }

  /// Recupera il dizionario delle corrispondenze sigla -> nome cartella.
  static Future<Map<String, String>> getAuthorMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyAuthorMap);
    if (jsonStr == null || jsonStr.isEmpty) {
      return Map<String, String>.from(defaultAuthorMap);
    }
    try {
      final decoded = jsonDecode(jsonStr);
      return Map<String, String>.from(decoded);
    } catch (_) {
      return Map<String, String>.from(defaultAuthorMap);
    }
  }

  /// Salva il dizionario autori.
  static Future<void> setAuthorMap(Map<String, String> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthorMap, jsonEncode(map));
  }

  static Future<bool> getAutoRotate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoRotate) ?? true;
  }

  static Future<void> setAutoRotate(bool autoRotate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoRotate, autoRotate);
  }

  static Future<bool> getDebugMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDebugMode) ?? false;
  }

  static Future<void> setDebugMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDebugMode, enabled);
  }
}
