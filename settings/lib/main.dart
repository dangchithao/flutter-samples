import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:settings/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/dependency_injection/injection_container.dart' as di;
import 'core/network/network_info.dart';
import 'features/settings/data/datasources/settings_local_data_source.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/presentation/providers/settings_notifier_provider.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await di.init();

  final settingsRepository = di.sl<SettingsRepository>();

  final settings = await settingsRepository.getSettings();

  print('settingsRepository: $settings');

  runApp(
    ProviderScope(
      overrides: [
        // Override the settingsRepositoryProvider with our implementation
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return settingsAsync.when(
      data: (settingsData) {
        return MaterialApp(
          title: 'Settings Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settingsData.themeMode,
          locale: Locale(settingsData.languageCode),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
