import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateTextScaleFactor {
  final SettingsRepository repository;

  UpdateTextScaleFactor(this.repository);

  Future<Either<Failure, void>> call(double scaleFactor) async {
    return await repository.updateTextScaleFactor(scaleFactor);
  }
}
