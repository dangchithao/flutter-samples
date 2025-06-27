import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/settings.dart';

part 'settings_model.g.dart';

@JsonSerializable()
class SettingsModel extends Equatable {
  @JsonKey(name: 'themeMode')
  final int themeModeIndex;
  final String languageCode;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final double textScaleFactor;
  final bool useSystemTheme;

  const SettingsModel({
    required this.themeModeIndex,
    required this.languageCode,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.textScaleFactor,
    required this.useSystemTheme,
  });

  // Convert to entity
  Settings toEntity() {
    return Settings(
      themeMode: ThemeMode.values[themeModeIndex],
      languageCode: languageCode,
      notificationsEnabled: notificationsEnabled,
      darkModeEnabled: darkModeEnabled,
      textScaleFactor: textScaleFactor,
      useSystemTheme: useSystemTheme,
    );
  }

  // Create from entity
  factory SettingsModel.fromEntity(Settings settings) {
    return SettingsModel(
      themeModeIndex: settings.themeMode.index,
      languageCode: settings.languageCode,
      notificationsEnabled: settings.notificationsEnabled,
      darkModeEnabled: settings.darkModeEnabled,
      textScaleFactor: settings.textScaleFactor,
      useSystemTheme: settings.useSystemTheme,
    );
  }

  // Copy with method
  SettingsModel copyWith({
    int? themeModeIndex,
    String? languageCode,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    double? textScaleFactor,
    bool? useSystemTheme,
  }) {
    return SettingsModel(
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }

  // JSON serialization
  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);

  @override
  List<Object?> get props => [
        themeModeIndex,
        languageCode,
        notificationsEnabled,
        darkModeEnabled,
        textScaleFactor,
        useSystemTheme,
      ];
}
