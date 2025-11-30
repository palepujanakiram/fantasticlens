import 'dart:async';

import '../../domain/entities/captured_photo.dart';
import '../../domain/entities/photo_template.dart';
import '../../domain/entities/processed_photo.dart';
import '../../domain/repositories/photo_processing_repository.dart';

class PhotoProcessingRepositoryImpl implements PhotoProcessingRepository {
  PhotoProcessingRepositoryImpl({
    this.simulatedProcessingDelay = const Duration(seconds: 2),
  });

  final Duration simulatedProcessingDelay;

  @override
  Future<ProcessedPhoto> processSession({
    required PhotoTemplate template,
    required List<CapturedPhoto> capturedPhotos,
  }) async {
    if (capturedPhotos.isEmpty) {
      throw StateError('No photos captured for processing.');
    }

    await Future<void>.delayed(simulatedProcessingDelay);

    final int blendedColor = _blendColors(
      capturedPhotos.map((photo) => photo.placeholderColor).toList(),
    );

    return ProcessedPhoto(
      sessionId:
          '${template.id}_${capturedPhotos.first.capturedAt.millisecondsSinceEpoch}',
      placeholderColor: blendedColor,
      processedAt: DateTime.now(),
    );
  }

  int _blendColors(List<int> colors) {
    if (colors.isEmpty) {
      return 0xFFFFFFFF;
    }

    int totalAlpha = 0;
    int totalRed = 0;
    int totalGreen = 0;
    int totalBlue = 0;

    for (final color in colors) {
      totalAlpha += (color >> 24) & 0xFF;
      totalRed += (color >> 16) & 0xFF;
      totalGreen += (color >> 8) & 0xFF;
      totalBlue += color & 0xFF;
    }

    final int count = colors.length;

    int average(int total) => (total / count).round().clamp(0, 255);

    return (average(totalAlpha) << 24) |
        (average(totalRed) << 16) |
        (average(totalGreen) << 8) |
        average(totalBlue);
  }
}

