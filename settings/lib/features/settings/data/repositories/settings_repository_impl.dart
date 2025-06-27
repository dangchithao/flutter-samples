import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/cache_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings.toEntity());
    } on CacheException {
      return const Left(CacheFailure('Failed to load settings from cache'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(Settings settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      await localDataSource.cacheSettings(settingsModel);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to save settings'));
    }
  }

  @override
  Future<Either<Failure, void>> updateThemeMode(ThemeMode themeMode) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        themeModeIndex: themeMode.index,
      );
      await localDataSource.cacheSettings(updatedSettings);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to update theme mode'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String languageCode) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        languageCode: languageCode,
      );
      await localDataSource.cacheSettings(updatedSettings);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to update language'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleNotifications(bool enabled) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        notificationsEnabled: enabled,
      );
      await localDataSource.cacheSettings(updatedSettings);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to toggle notifications'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleDarkMode(bool enabled) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        darkModeEnabled: enabled,
      );
      await localDataSource.cacheSettings(updatedSettings);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to toggle dark mode'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTextScaleFactor(double scaleFactor) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        textScaleFactor: scaleFactor,
      );
      await localDataSource.cacheSettings(updatedSettings);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to update text scale factor'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSystemTheme(bool useSystemTheme) async {
    try {
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        useSystemTheme: useSystemTheme,
      );
      await localDataSource.cacheSettings(updatedSettings);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to toggle system theme'));
    }
  }

  @override
  Future<Either<Failure, void>> resetToDefault() async {
    try {
      await localDataSource.clearCache();
      // Get default settings by getting settings after clearing cache
      final defaultSettings = await localDataSource.getSettings();
      await localDataSource.cacheSettings(defaultSettings);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to reset settings'));
    }
  }

  // Helper method to create a copy of settings with updated fields
  SettingsModel _updateSettings({
    required SettingsModel current,
    int? themeModeIndex,
    String? languageCode,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    double? textScaleFactor,
    bool? useSystemTheme,
  }) {
    return SettingsModel(
      themeModeIndex: themeModeIndex ?? current.themeModeIndex,
      languageCode: languageCode ?? current.languageCode,
      notificationsEnabled: notificationsEnabled ?? current.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? current.darkModeEnabled,
      textScaleFactor: textScaleFactor ?? current.textScaleFactor,
      useSystemTheme: useSystemTheme ?? current.useSystemTheme,
    );
  }
}
