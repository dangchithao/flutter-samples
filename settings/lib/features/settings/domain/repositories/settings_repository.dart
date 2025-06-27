import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../entities/settings.dart';

abstract class SettingsRepository {
  // Get current settings
  Future<Either<Failure, Settings>> getSettings();

  // Save settings
  Future<Either<Failure, void>> saveSettings(Settings settings);

  // Update theme mode
  Future<Either<Failure, void>> updateThemeMode(ThemeMode themeMode);

  // Update language
  Future<Either<Failure, void>> updateLanguage(String languageCode);

  // Toggle notifications
  Future<Either<Failure, void>> toggleNotifications(bool enabled);

  // Toggle dark mode
  Future<Either<Failure, void>> toggleDarkMode(bool enabled);

  // Update text scale factor
  Future<Either<Failure, void>> updateTextScaleFactor(double scaleFactor);

  // Toggle system theme
  Future<Either<Failure, void>> toggleSystemTheme(bool useSystemTheme);

  // Reset to default settings
  Future<Either<Failure, void>> resetToDefault();
}
