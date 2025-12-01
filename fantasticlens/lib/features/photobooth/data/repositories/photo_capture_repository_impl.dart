import 'dart:typed_data';

import '../../domain/entities/camera_device.dart';
import '../../domain/entities/captured_photo.dart';
import '../../domain/entities/photo_template.dart';
import '../../domain/repositories/photo_capture_repository.dart';
import '../services/camera_manager.dart';

class PhotoCaptureRepositoryImpl implements PhotoCaptureRepository {
  PhotoCaptureRepositoryImpl({
    required CameraManager cameraManager,
  }) : _cameraManager = cameraManager;

  final CameraManager _cameraManager;

  @override
  Future<List<CameraDevice>> loadAvailableCameras() async {
    return _cameraManager.loadAvailableCameras();
  }

  @override
  Future<CameraDevice?> getSelectedCamera() async {
    if (_cameraManager.selectedDevice != null) {
      return _cameraManager.selectedDevice;
    }
    final devices = await loadAvailableCameras();
    if (devices.isEmpty) {
      return null;
    }
    await selectCamera(devices.first);
    return devices.first;
  }

  @override
  Future<void> selectCamera(CameraDevice device) async {
    await _cameraManager.selectCamera(device);
  }

  @override
  Future<void> prepareSelectedCamera() {
    return _cameraManager.ensureCameraInitialized();
  }

  @override
  bool get isCameraReady => _cameraManager.isInitialized;

  @override
  Future<CapturedPhoto> capturePhoto({
    required PhotoTemplate template,
    required int index,
  }) async {
    await prepareSelectedCamera();
    final Uint8List bytes = await _cameraManager.capturePhotoBytes();

    final int placeholderColor = _dominantColorFromBytes(
      bytes,
      fallback: _colorForIndex(template, index),
    );

    return CapturedPhoto(
      id: '${template.id}_$index',
      index: index,
      capturedAt: DateTime.now(),
      placeholderColor: placeholderColor,
      imageBytes: bytes,
    );
  }

  @override
  Future<void> dispose() {
    return _cameraManager.disposeCamera();
  }

  int _dominantColorFromBytes(
    Uint8List bytes, {
    required int fallback,
  }) {
    if (bytes.isEmpty) {
      return fallback;
    }
    final List<int> sample = bytes.length > 5000
        ? bytes.sublist(0, 5000)
        : bytes;
    int red = 0;
    int green = 0;
    int blue = 0;
    for (int i = 0; i < sample.length - 3; i += 4) {
      red += sample[i];
      green += sample[i + 1];
      blue += sample[i + 2];
    }
    final int count = (sample.length / 4).floor().clamp(1, sample.length);
    final int avgRed = (red / count).clamp(0, 255).toInt();
    final int avgGreen = (green / count).clamp(0, 255).toInt();
    final int avgBlue = (blue / count).clamp(0, 255).toInt();
    return (0xFF << 24) | (avgRed << 16) | (avgGreen << 8) | avgBlue;
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
