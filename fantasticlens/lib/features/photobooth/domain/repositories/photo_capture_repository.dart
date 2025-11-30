import '../entities/captured_photo.dart';
import '../entities/photo_template.dart';

abstract class PhotoCaptureRepository {
  Future<CapturedPhoto> capturePhoto({
    required PhotoTemplate template,
    required int index,
  });
}

