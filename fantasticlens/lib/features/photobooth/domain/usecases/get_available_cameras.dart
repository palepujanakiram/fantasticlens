import '../../../../core/usecases/usecase.dart';
import '../entities/camera_device.dart';
import '../repositories/photo_capture_repository.dart';

class GetAvailableCamerasUseCase
    implements UseCase<List<CameraDevice>, NoParams> {
  GetAvailableCamerasUseCase(this._repository);

  final PhotoCaptureRepository _repository;

  @override
  Future<List<CameraDevice>> call(NoParams params) {
    return _repository.loadAvailableCameras();
  }
}

