import '../entities/camera_device.dart';
import '../entities/captured_photo.dart';
import '../entities/photo_template.dart';

abstract class PhotoCaptureRepository {
  Future<List<CameraDevice>> loadAvailableCameras();

  Future<CameraDevice?> getSelectedCamera();

  Future<void> selectCamera(CameraDevice device);

  Future<void> prepareSelectedCamera();

  bool get isCameraReady;

  Future<CapturedPhoto> capturePhoto({
    required PhotoTemplate template,
    required int index,
  });

  Future<void> dispose();
}

