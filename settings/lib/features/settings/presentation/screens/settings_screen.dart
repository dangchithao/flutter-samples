import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/entities/settings.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_notifier_provider.dart';
import '../widgets/section_header.dart';
import '../widgets/setting_tile.dart';

import 'package:flutter/material.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Settings> settingsAsync = ref.watch(settingsNotifierProvider);
    final l10n = AppLocalizations.of(context);
    
    if (l10n == null) {
      return const Scaffold(
        body: Center(
          child: Text('Localization not available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsList(settings, context, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSettingsList(Settings settings, BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Appearance Section
        SectionHeader(title: l10n.appearanceSectionTitle),
        SettingTile(
          title: l10n.themeSetting,
          subtitle: _getThemeModeName(settings.themeMode, l10n),
          icon: Icons.palette,
          onTap: () => _showThemeModeDialog(context, notifier, settings.themeMode),
        ),
        SettingTile(
          title: l10n.darkModeSetting,
          subtitle: settings.darkModeEnabled ? l10n.enabled : l10n.disabled,
          icon: Icons.dark_mode,
          trailing: Switch(
            value: settings.darkModeEnabled,
            onChanged: (value) => notifier.toggleDarkMode(value),
          ),
        ),
        SettingTile(
          title: l10n.useSystemThemeSetting,
          subtitle: settings.useSystemTheme ? l10n.enabled : l10n.disabled,
          icon: Icons.settings_suggest,
          trailing: Switch(
            value: settings.useSystemTheme,
            onChanged: (value) => notifier.toggleSystemTheme(value),
          ),
        ),
        
        // Language Section
        const SizedBox(height: 16),
        SectionHeader(title: l10n.languageSectionTitle),
        SettingTile(
          title: l10n.languageSetting,
          subtitle: _getLanguageName(settings.languageCode, l10n),
          icon: Icons.language,
          onTap: () => _showLanguageDialog(context, notifier, settings.languageCode),
        ),
        
        // Notifications Section
        const SizedBox(height: 16),
        SectionHeader(title: l10n.notificationsSectionTitle),
        SettingTile(
          title: l10n.notificationsSetting,
          subtitle: settings.notificationsEnabled ? l10n.enabled : l10n.disabled,
          icon: Icons.notifications,
          trailing: Switch(
            value: settings.notificationsEnabled,
            onChanged: (value) => notifier.toggleNotifications(value),
          ),
        ),
        
        // Text Size Section
        const SizedBox(height: 16),
        SectionHeader(title: l10n.textSizeSectionTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.textSizeSetting(settings.textScaleFactor.toStringAsFixed(1)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Slider(
                value: settings.textScaleFactor,
                min: 0.8,
                max: 2.0,
                divisions: 12,
                label: settings.textScaleFactor.toStringAsFixed(1),
                onChanged: (value) {
                  notifier.updateTextScaleFactor(value);
                },
              ),
            ],
          ),
        ),
        
        // Reset Section
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => _showResetConfirmationDialog(context, notifier),
            icon: const Icon(Icons.restore, size: 18),
            label: Text(l10n.resetToDefault),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  String _getThemeModeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.systemTheme;
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
    }
  }

  String _getLanguageName(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'en':
        return l10n.englishLanguage;
      case 'vi':
        return l10n.vietnameseLanguage;
      default:
        return languageCode;
    }
  }

  Future<void> _showThemeModeDialog(
    BuildContext context,
    SettingsNotifier notifier,
    ThemeMode currentMode,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.chooseTheme),
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.systemTheme),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                notifier.updateThemeMode(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.lightTheme),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                notifier.updateThemeMode(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.darkTheme),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                notifier.updateThemeMode(value);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    SettingsNotifier notifier,
    String currentLanguage,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.chooseLanguage),
        children: [
          RadioListTile<String>(
            title: Text(l10n.englishLanguage),
            value: 'en',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                notifier.updateLanguage(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: Text(l10n.vietnameseLanguage),
            value: 'vi',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                notifier.updateLanguage(value);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmationDialog(
    BuildContext context,
    SettingsNotifier notifier,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettingsTitle),
        content: Text(l10n.resetSettingsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.reset,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.resetToDefault();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsResetSuccess)),
        );
      }
    }
  }
}
