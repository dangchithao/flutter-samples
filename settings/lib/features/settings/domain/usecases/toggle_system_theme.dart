import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ToggleSystemTheme {
  final SettingsRepository repository;

  ToggleSystemTheme(this.repository);

  Future<Either<Failure, void>> call(bool useSystemTheme) async {
    return await repository.toggleSystemTheme(useSystemTheme);
  }
}
