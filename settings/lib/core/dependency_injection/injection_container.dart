import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/save_settings.dart';
import '../../features/settings/domain/usecases/update_theme_mode.dart';
import '../../features/settings/domain/usecases/update_language.dart';
import '../../features/settings/domain/usecases/toggle_notifications.dart';
import '../../features/settings/domain/usecases/toggle_dark_mode.dart';
import '../../features/settings/domain/usecases/update_text_scale_factor.dart';
import '../../features/settings/domain/usecases/toggle_system_theme.dart';
import '../../features/settings/domain/usecases/reset_to_default.dart';
import '../../features/settings/presentation/providers/settings_notifier.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Settings
  // Bloc/Notifier
  sl.registerFactory(
    () => SettingsNotifier(
      getSettings: sl(),
      saveSettings: sl(),
      updateThemeMode: sl(),
      updateLanguage: sl(),
      toggleNotifications: sl(),
      toggleDarkMode: sl(),
      updateTextScaleFactor: sl(),
      toggleSystemTheme: sl(),
      resetToDefault: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => SaveSettings(sl()));
  sl.registerLazySingleton(() {
    print('objectdasdsdasdasdadsa');
    return UpdateThemeMode(sl());
  });
  sl.registerLazySingleton(() => UpdateLanguage(sl()));
  sl.registerLazySingleton(() => ToggleNotifications(sl()));
  sl.registerLazySingleton(() => ToggleDarkMode(sl()));
  sl.registerLazySingleton(() => UpdateTextScaleFactor(sl()));
  sl.registerLazySingleton(() => ToggleSystemTheme(sl()));
  sl.registerLazySingleton(() => ResetToDefault(sl()));

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}
