// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    SettingsModel(
      themeModeIndex: (json['themeMode'] as num).toInt(),
      languageCode: json['languageCode'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      darkModeEnabled: json['darkModeEnabled'] as bool,
      textScaleFactor: (json['textScaleFactor'] as num).toDouble(),
      useSystemTheme: json['useSystemTheme'] as bool,
    );

Map<String, dynamic> _$SettingsModelToJson(SettingsModel instance) =>
    <String, dynamic>{
      'themeMode': instance.themeModeIndex,
      'languageCode': instance.languageCode,
      'notificationsEnabled': instance.notificationsEnabled,
      'darkModeEnabled': instance.darkModeEnabled,
      'textScaleFactor': instance.textScaleFactor,
      'useSystemTheme': instance.useSystemTheme,
    };
