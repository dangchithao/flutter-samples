import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateLanguage {
  final SettingsRepository repository;

  UpdateLanguage(this.repository);

  Future<Either<Failure, void>> call(String languageCode) async {
    return await repository.updateLanguage(languageCode);
  }
}
