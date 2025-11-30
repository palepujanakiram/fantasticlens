import '../../../../core/usecases/usecase.dart';
import '../entities/captured_photo.dart';
import '../entities/photo_template.dart';
import '../repositories/photo_capture_repository.dart';

class CapturePhotoUseCase
    implements UseCase<CapturedPhoto, CapturePhotoParams> {
  CapturePhotoUseCase(this._repository);

  final PhotoCaptureRepository _repository;

  @override
  Future<CapturedPhoto> call(CapturePhotoParams params) {
    return _repository.capturePhoto(
      template: params.template,
      index: params.index,
    );
  }
}

class CapturePhotoParams {
  const CapturePhotoParams({
    required this.template,
    required this.index,
  });

  final PhotoTemplate template;
  final int index;
}

