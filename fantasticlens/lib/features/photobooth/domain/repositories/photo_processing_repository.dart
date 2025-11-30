import '../entities/captured_photo.dart';
import '../entities/photo_template.dart';
import '../entities/processed_photo.dart';

abstract class PhotoProcessingRepository {
  Future<ProcessedPhoto> processSession({
    required PhotoTemplate template,
    required List<CapturedPhoto> capturedPhotos,
  });
}

