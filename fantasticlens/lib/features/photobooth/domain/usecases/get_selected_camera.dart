import '../entities/camera_device.dart';
import '../repositories/photo_capture_repository.dart';

class GetSelectedCameraUseCase {
  GetSelectedCameraUseCase(this._repository);

  final PhotoCaptureRepository _repository;

  Future<CameraDevice?> call() {
    return _repository.getSelectedCamera();
  }
}

