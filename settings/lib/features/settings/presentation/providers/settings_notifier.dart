import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import '../../domain/usecases/update_theme_mode.dart';
import '../../domain/usecases/update_language.dart';
import '../../domain/usecases/toggle_notifications.dart';
import '../../domain/usecases/toggle_dark_mode.dart';
import '../../domain/usecases/update_text_scale_factor.dart';
import '../../domain/usecases/toggle_system_theme.dart';
import '../../domain/usecases/reset_to_default.dart';

class SettingsNotifier extends StateNotifier<AsyncValue<Settings>> {
  final GetSettings _getSettings;
  final SaveSettings _saveSettings;
  final UpdateThemeMode _updateThemeMode;
  final UpdateLanguage _updateLanguage;
  final ToggleNotifications _toggleNotifications;
  final ToggleDarkMode _toggleDarkMode;
  final UpdateTextScaleFactor _updateTextScaleFactor;
  final ToggleSystemTheme _toggleSystemTheme;
  final ResetToDefault _resetToDefault;

  SettingsNotifier({
    required GetSettings getSettings,
    required SaveSettings saveSettings,
    required UpdateThemeMode updateThemeMode,
    required UpdateLanguage updateLanguage,
    required ToggleNotifications toggleNotifications,
    required ToggleDarkMode toggleDarkMode,
    required UpdateTextScaleFactor updateTextScaleFactor,
    required ToggleSystemTheme toggleSystemTheme,
    required ResetToDefault resetToDefault,
  })  : _getSettings = getSettings,
        _saveSettings = saveSettings,
        _updateThemeMode = updateThemeMode,
        _updateLanguage = updateLanguage,
        _toggleNotifications = toggleNotifications,
        _toggleDarkMode = toggleDarkMode,
        _updateTextScaleFactor = updateTextScaleFactor,
        _toggleSystemTheme = toggleSystemTheme,
        _resetToDefault = resetToDefault,
        super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    final result = await _getSettings();
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (settings) => AsyncValue.data(settings),
    );
  }

  Future<void> _handleOperation(
    Future<Either<Failure, void>> Function() operation,
  ) async {
    try {
      state = const AsyncValue.loading();
      final result = await operation();
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => loadSettings(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> saveSettings(Settings settings) async {
    await _handleOperation(() => _saveSettings(settings));
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await _handleOperation(() => _updateThemeMode(themeMode));
  }

  Future<void> updateLanguage(String languageCode) async {
    await _handleOperation(() => _updateLanguage(languageCode));
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _handleOperation(() => _toggleNotifications(enabled));
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await _handleOperation(() => _toggleDarkMode(enabled));
  }

  Future<void> updateTextScaleFactor(double scaleFactor) async {
    await _handleOperation(() => _updateTextScaleFactor(scaleFactor));
  }

  Future<void> toggleSystemTheme(bool useSystemTheme) async {
    await _handleOperation(() => _toggleSystemTheme(useSystemTheme));
  }

  Future<void> resetToDefault() async {
    await _handleOperation(() => _resetToDefault());
  }

  // Helper method to get the current theme mode
  ThemeMode getThemeMode() {
    return state.when(
      data: (settings) => settings.themeMode,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );
  }

  // Helper method to get the current locale
  Locale? getLocale() {
    return state.when<Locale?>(
      data: (settings) => Locale(settings.languageCode),
      loading: () => null,
      error: (_, __) => null,
    );
  }

  // Helper method to check if dark mode is enabled
  bool isDarkModeEnabled() {
    return state.when(
      data: (settings) => settings.darkModeEnabled,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  // Helper method to check if notifications are enabled
  bool areNotificationsEnabled() {
    return state.when(
      data: (settings) => settings.notificationsEnabled,
      loading: () => true,
      error: (_, __) => true,
    );
  }

  // Helper method to get the current text scale factor
  double getTextScaleFactor() {
    return state.when(
      data: (settings) => settings.textScaleFactor,
      loading: () => 1.0,
      error: (_, __) => 1.0,
    );
  }

  // Helper method to check if system theme is being used
  bool isSystemThemeUsed() {
    return state.when(
      data: (settings) => settings.useSystemTheme,
      loading: () => true,
      error: (_, __) => true,
    );
  }
}
