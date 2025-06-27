import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Settings extends Equatable {
  final ThemeMode themeMode;
  final String languageCode;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final double textScaleFactor;
  final bool useSystemTheme;

  const Settings({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.textScaleFactor = 1.0,
    this.useSystemTheme = true,
  });

  @override
  List<Object?> get props => [
        themeMode,
        languageCode,
        notificationsEnabled,
        darkModeEnabled,
        textScaleFactor,
        useSystemTheme,
      ];

  Settings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    double? textScaleFactor,
    bool? useSystemTheme,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'languageCode': languageCode,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'textScaleFactor': textScaleFactor,
      'useSystemTheme': useSystemTheme,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: ThemeMode.values[json['themeMode'] as int],
      languageCode: json['languageCode'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      darkModeEnabled: json['darkModeEnabled'] as bool,
      textScaleFactor: (json['textScaleFactor'] as num).toDouble(),
      useSystemTheme: json['useSystemTheme'] as bool,
    );
  }
}
