import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ToggleNotifications {
  final SettingsRepository repository;

  ToggleNotifications(this.repository);

  Future<Either<Failure, void>> call(bool enabled) async {
    return await repository.toggleNotifications(enabled);
  }
}
