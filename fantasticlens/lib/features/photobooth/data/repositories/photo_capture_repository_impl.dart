import 'dart:async';

import '../../domain/entities/captured_photo.dart';
import '../../domain/entities/photo_template.dart';
import '../../domain/repositories/photo_capture_repository.dart';

class PhotoCaptureRepositoryImpl implements PhotoCaptureRepository {
  PhotoCaptureRepositoryImpl({
    this.simulatedCaptureDelay = const Duration(milliseconds: 700),
  });

  final Duration simulatedCaptureDelay;

  @override
  Future<CapturedPhoto> capturePhoto({
    required PhotoTemplate template,
    required int index,
  }) async {
    await Future<void>.delayed(simulatedCaptureDelay);

    final int color = _colorForIndex(template, index);

    return CapturedPhoto(
      id: '${template.id}_$index',
      index: index,
      capturedAt: DateTime.now(),
      placeholderColor: color,
    );
  }

  int _colorForIndex(PhotoTemplate template, int index) {
    final gradient = template.theme.backgroundGradient;
    if (gradient.isNotEmpty) {
      return gradient[index % gradient.length];
    }
    final accent = template.theme.accentColor;
    return _tintColor(accent, index);
  }

  int _tintColor(int color, int step) {
    final int alpha = (color >> 24) & 0xFF;
    final int red = (color >> 16) & 0xFF;
    final int green = (color >> 8) & 0xFF;
    final int blue = color & 0xFF;

    final double factor = 1 - ((step % 3) * 0.1);

    int apply(int channel) => (channel * factor).clamp(0, 255).toInt();

    return (alpha << 24) |
        (apply(red) << 16) |
        (apply(green) << 8) |
        apply(blue);
  }
}

