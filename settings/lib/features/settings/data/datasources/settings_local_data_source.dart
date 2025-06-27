import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart' show CacheException;
import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> cacheSettings(SettingsModel settings);
  Future<void> clearCache();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedSettingsKey = 'cached_settings';

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<SettingsModel> getSettings() async {
    final jsonString = sharedPreferences.getString(_cachedSettingsKey);
    
    if (jsonString != null) {
      try {
        // In a real app, you would parse the JSON string to SettingsModel
        // For now, we'll return default settings
        return _getDefaultSettings();
      } catch (e) {
        throw const CacheException('Failed to parse cached settings');
      }
    } else {
      return _getDefaultSettings();
    }
  }

  @override
  Future<void> cacheSettings(SettingsModel settings) async {
    try {
      // In a real app, you would convert settings to JSON string
      // For now, we'll just store a placeholder
      await sharedPreferences.setString(
        _cachedSettingsKey, 
        'cached_settings_data',
      );
    } catch (e) {
      throw const CacheException('Failed to cache settings');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cachedSettingsKey);
    } catch (e) {
      throw const CacheException('Failed to clear cache');
    }
  }

  SettingsModel _getDefaultSettings() {
    // Using non-const constructor to allow runtime evaluation of enum index
    return SettingsModel(
      themeModeIndex: ThemeMode.system.index,
      languageCode: 'en',
      notificationsEnabled: true,
      darkModeEnabled: false,
      textScaleFactor: 1.0,
      useSystemTheme: true,
    );
  }
}
