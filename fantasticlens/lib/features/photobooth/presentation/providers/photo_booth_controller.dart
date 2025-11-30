import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/photo_template.dart';
import '../../domain/usecases/capture_photo.dart';
import '../../domain/usecases/process_photos.dart';
import '../state/photo_booth_state.dart';

class PhotoBoothController extends StateNotifier<PhotoBoothState> {
  PhotoBoothController({
    required CapturePhotoUseCase capturePhoto,
    required ProcessPhotosUseCase processPhotos,
  })  : _capturePhoto = capturePhoto,
        _processPhotos = processPhotos,
        super(const PhotoBoothState());

  final CapturePhotoUseCase _capturePhoto;
  final ProcessPhotosUseCase _processPhotos;

  void startSession(PhotoTemplate template) {
    state = PhotoBoothState(
      status: PhotoBoothStatus.readyToCapture,
      selectedTemplate: template,
      capturedPhotos: const [],
      processedPhoto: null,
      isCaptureInProgress: false,
    );
  }

  Future<void> captureNextPhoto() async {
    final template = state.selectedTemplate;
    if (template == null || !state.canCapture) {
      return;
    }
    final existingPhotos = List.of(state.capturedPhotos);

    state = state.copyWith(
      status: PhotoBoothStatus.capturing,
      isCaptureInProgress: true,
      clearError: true,
      clearProcessedPhoto: true,
    );

    try {
      final capturedPhoto = await _capturePhoto(
        CapturePhotoParams(
          template: template,
          index: existingPhotos.length,
        ),
      );
      existingPhotos.add(capturedPhoto);

      final PhotoBoothStatus nextStatus =
          existingPhotos.length == template.photoCount
              ? PhotoBoothStatus.readyToProcess
              : PhotoBoothStatus.readyToCapture;

      state = state.copyWith(
        status: nextStatus,
        capturedPhotos: existingPhotos,
        isCaptureInProgress: false,
      );
    } catch (error) {
      state = state.copyWith(
        status: PhotoBoothStatus.failure,
        isCaptureInProgress: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> processSession() async {
    final template = state.selectedTemplate;
    final photos = state.capturedPhotos;

    if (template == null || photos.isEmpty || !state.canProcess) {
      return;
    }

    state = state.copyWith(
      status: PhotoBoothStatus.processing,
      isCaptureInProgress: true,
      clearError: true,
    );

    try {
      final processedPhoto = await _processPhotos(
        ProcessPhotosParams(
          template: template,
          capturedPhotos: photos,
        ),
      );

      state = state.copyWith(
        status: PhotoBoothStatus.completed,
        processedPhoto: processedPhoto,
        isCaptureInProgress: false,
      );
    } catch (error) {
      state = state.copyWith(
        status: PhotoBoothStatus.failure,
        isCaptureInProgress: false,
        errorMessage: error.toString(),
      );
    }
  }

  void resetSession() {
    state = const PhotoBoothState();
  }
}

