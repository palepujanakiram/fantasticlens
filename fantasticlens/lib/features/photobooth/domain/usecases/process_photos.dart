import '../../../../core/usecases/usecase.dart';
import '../entities/captured_photo.dart';
import '../entities/photo_template.dart';
import '../entities/processed_photo.dart';
import '../repositories/photo_processing_repository.dart';

class ProcessPhotosUseCase
    implements UseCase<ProcessedPhoto, ProcessPhotosParams> {
  ProcessPhotosUseCase(this._repository);

  final PhotoProcessingRepository _repository;

  @override
  Future<ProcessedPhoto> call(ProcessPhotosParams params) {
    return _repository.processSession(
      template: params.template,
      capturedPhotos: params.capturedPhotos,
    );
  }
}

class ProcessPhotosParams {
  const ProcessPhotosParams({
    required this.template,
    required this.capturedPhotos,
  });

  final PhotoTemplate template;
  final List<CapturedPhoto> capturedPhotos;
}

