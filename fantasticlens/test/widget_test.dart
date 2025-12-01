// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fantasticlens/app/app.dart';
import 'package:fantasticlens/features/photobooth/domain/entities/camera_device.dart';
import 'package:fantasticlens/features/photobooth/domain/entities/captured_photo.dart';
import 'package:fantasticlens/features/photobooth/domain/entities/photo_template.dart';
import 'package:fantasticlens/features/photobooth/domain/repositories/photo_capture_repository.dart';
import 'package:fantasticlens/features/photobooth/presentation/providers/photo_booth_providers.dart';

void main() {
  testWidgets('Template selection screen renders', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          photoCaptureRepositoryProvider.overrideWithValue(
            _FakePhotoCaptureRepository(),
          ),
        ],
        child: const FantasticLensApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Choose your photo experience'), findsOneWidget);
    expect(find.text('Start session'), findsWidgets);
  });
}

class _FakePhotoCaptureRepository implements PhotoCaptureRepository {
  CameraDevice? _selectedDevice;
  bool _isReady = true;

  @override
  Future<CapturedPhoto> capturePhoto({
    required PhotoTemplate template,
    required int index,
  }) async {
    return CapturedPhoto(
      id: '${template.id}_$index',
      index: index,
      capturedAt: DateTime.now(),
      placeholderColor: 0xFF123456,
      imageBytes: Uint8List(0),
    );
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<CameraDevice?> getSelectedCamera() async {
    return _selectedDevice;
  }

  @override
  bool get isCameraReady => _isReady;

  @override
  Future<List<CameraDevice>> loadAvailableCameras() async {
    return const [
      CameraDevice(
        id: 'fake_camera',
        name: 'Test Cam • Back camera',
        lensFacing: CameraLensFacing.back,
        isExternal: false,
      ),
    ];
  }

  @override
  Future<void> prepareSelectedCamera() async {
    _isReady = true;
  }

  @override
  Future<void> selectCamera(CameraDevice device) async {
    _selectedDevice = device;
    _isReady = false;
  }
}
