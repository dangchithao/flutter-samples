import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateThemeMode {
  final SettingsRepository repository;

  UpdateThemeMode(this.repository);

  Future<Either<Failure, void>> call(ThemeMode themeMode) async {
    return await repository.updateThemeMode(themeMode);
  }
}
