import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings/features/settings/domain/entities/settings.dart';
import 'package:settings/features/settings/presentation/providers/settings_notifier.dart';
import 'package:settings/features/settings/domain/usecases/get_settings.dart';
import 'package:settings/features/settings/domain/usecases/save_settings.dart';
import 'package:settings/features/settings/domain/usecases/update_theme_mode.dart';
import 'package:settings/features/settings/domain/usecases/update_language.dart';
import 'package:settings/features/settings/domain/usecases/toggle_notifications.dart';
import 'package:settings/features/settings/domain/usecases/toggle_dark_mode.dart';
import 'package:settings/features/settings/domain/usecases/update_text_scale_factor.dart';
import 'package:settings/features/settings/domain/usecases/toggle_system_theme.dart';
import 'package:settings/features/settings/domain/usecases/reset_to_default.dart';
import 'package:settings/features/settings/domain/repositories/settings_repository.dart';

// Providers for use cases
final getSettingsProvider = Provider<GetSettings>((ref) => GetSettings(ref.read(settingsRepositoryProvider)));
final saveSettingsProvider = Provider<SaveSettings>((ref) => SaveSettings(ref.read(settingsRepositoryProvider)));
final updateThemeModeProvider = Provider<UpdateThemeMode>((ref) => UpdateThemeMode(ref.read(settingsRepositoryProvider)));
final updateLanguageProvider = Provider<UpdateLanguage>((ref) => UpdateLanguage(ref.read(settingsRepositoryProvider)));
final toggleNotificationsProvider = Provider<ToggleNotifications>((ref) => ToggleNotifications(ref.read(settingsRepositoryProvider)));
final toggleDarkModeProvider = Provider<ToggleDarkMode>((ref) => ToggleDarkMode(ref.read(settingsRepositoryProvider)));
final updateTextScaleFactorProvider = Provider<UpdateTextScaleFactor>((ref) => UpdateTextScaleFactor(ref.read(settingsRepositoryProvider)));
final toggleSystemThemeProvider = Provider<ToggleSystemTheme>((ref) => ToggleSystemTheme(ref.read(settingsRepositoryProvider)));
final resetToDefaultProvider = Provider<ResetToDefault>((ref) => ResetToDefault(ref.read(settingsRepositoryProvider)));

// Provider for SettingsRepository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => throw UnimplementedError('Override this provider in main.dart'));

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<Settings>>(
  (ref) {
    return SettingsNotifier(
      getSettings: ref.read(getSettingsProvider),
      saveSettings: ref.read(saveSettingsProvider),
      updateThemeMode: ref.read(updateThemeModeProvider),
      updateLanguage: ref.read(updateLanguageProvider),
      toggleNotifications: ref.read(toggleNotificationsProvider),
      toggleDarkMode: ref.read(toggleDarkModeProvider),
      updateTextScaleFactor: ref.read(updateTextScaleFactorProvider),
      toggleSystemTheme: ref.read(toggleSystemThemeProvider),
      resetToDefault: ref.read(resetToDefaultProvider),
    );
  },
);

// Provider for the current settings
final currentSettingsProvider = Provider<AsyncValue<Settings>>((ref) {
  return ref.watch(settingsNotifierProvider);
});
