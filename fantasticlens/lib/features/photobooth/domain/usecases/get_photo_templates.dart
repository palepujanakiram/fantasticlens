import '../../../../core/usecases/usecase.dart';
import '../entities/photo_template.dart';
import '../repositories/photo_template_repository.dart';

class GetPhotoTemplatesUseCase
    implements UseCase<List<PhotoTemplate>, NoParams> {
  GetPhotoTemplatesUseCase(this._repository);

  final PhotoTemplateRepository _repository;

  @override
  Future<List<PhotoTemplate>> call(NoParams params) {
    return _repository.fetchTemplates();
  }
}

