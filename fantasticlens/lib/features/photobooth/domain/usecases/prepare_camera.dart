import '../repositories/photo_capture_repository.dart';

class PrepareCameraUseCase {
  PrepareCameraUseCase(this._repository);

  final PhotoCaptureRepository _repository;

  Future<void> call() {
    return _repository.prepareSelectedCamera();
  }

  bool get isReady => _repository.isCameraReady;
}

