import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ToggleDarkMode {
  final SettingsRepository repository;

  ToggleDarkMode(this.repository);

  Future<Either<Failure, void>> call(bool enabled) async {
    return await repository.toggleDarkMode(enabled);
  }
}
