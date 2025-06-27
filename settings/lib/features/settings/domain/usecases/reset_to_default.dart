import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ResetToDefault {
  final SettingsRepository repository;

  ResetToDefault(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.resetToDefault();
  }
}
