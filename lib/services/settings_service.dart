import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Servizio di persistenza delle impostazioni dell'applicazione.
class SettingsService {
  static const _keyApiKey = 'gemini_api_key';
  static const _keyModel = 'gemini_model';
  static const _keyDestination = 'destination_folder';
  static const _keyAuthorMap = 'author_map';
  static const _keyAutoRotate = 'auto_rotate';
  static const _keyDebugMode = 'debug_mode_enabled';

  static const String defaultModel = 'gemini-flash-lite-latest';
  static const Map<String, String> defaultAuthorMap = {};

  /// Recupera la chiave API salvata localmente.
  static Future<String> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyApiKey)?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Salva la chiave API nelle preferenze locali dell'applicazione.
  static Future<void> setApiKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiKey, key.trim());
    } catch (_) {}
  }

  static Future<String> getModel() async {
    return defaultModel;
  }

  static Future<void> setModel(String model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyModel, defaultModel);
    } catch (_) {}
  }

  static Future<String> getDestinationFolder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyDestination) ?? '';
    } catch (_) {
      return '';
    }
  }

  static Future<void> setDestinationFolder(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDestination, path);
    } catch (_) {}
  }

  /// Recupera il dizionario delle corrispondenze sigla -> nome cartella.
  static Future<Map<String, String>> getAuthorMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyAuthorMap);
      if (jsonStr == null || jsonStr.isEmpty) {
        return Map<String, String>.from(defaultAuthorMap);
      }
      final decoded = jsonDecode(jsonStr);
      return Map<String, String>.from(decoded);
    } catch (_) {
      return Map<String, String>.from(defaultAuthorMap);
    }
  }

  /// Salva il dizionario autori.
  static Future<void> setAuthorMap(Map<String, String> map) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAuthorMap, jsonEncode(map));
    } catch (_) {}
  }

  static Future<bool> getAutoRotate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyAutoRotate) ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> setAutoRotate(bool autoRotate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAutoRotate, autoRotate);
    } catch (_) {}
  }

  static Future<bool> getDebugMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyDebugMode) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setDebugMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDebugMode, enabled);
    } catch (_) {}
  }
}
