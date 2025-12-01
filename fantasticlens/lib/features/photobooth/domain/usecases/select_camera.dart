import '../entities/camera_device.dart';
import '../repositories/photo_capture_repository.dart';

class SelectCameraUseCase {
  SelectCameraUseCase(this._repository);

  final PhotoCaptureRepository _repository;

  Future<void> call(CameraDevice device) {
    return _repository.selectCamera(device);
  }
}

