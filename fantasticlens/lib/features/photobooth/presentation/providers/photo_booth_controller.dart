import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/camera_device.dart';
import '../../domain/entities/photo_template.dart';
import '../../domain/usecases/capture_photo.dart';
import '../../domain/usecases/get_available_cameras.dart';
import '../../domain/usecases/get_selected_camera.dart';
import '../../domain/usecases/prepare_camera.dart';
import '../../domain/usecases/process_photos.dart';
import '../../domain/usecases/select_camera.dart';
import '../state/photo_booth_state.dart';

class PhotoBoothController extends StateNotifier<PhotoBoothState> {
  PhotoBoothController({
    required CapturePhotoUseCase capturePhoto,
    required GetAvailableCamerasUseCase getAvailableCameras,
    required GetSelectedCameraUseCase getSelectedCamera,
    required SelectCameraUseCase selectCamera,
    required PrepareCameraUseCase prepareCamera,
    required ProcessPhotosUseCase processPhotos,
  }) : _capturePhoto = capturePhoto,
       _getAvailableCameras = getAvailableCameras,
       _getSelectedCamera = getSelectedCamera,
       _selectCamera = selectCamera,
       _prepareCamera = prepareCamera,
       _processPhotos = processPhotos,
       super(const PhotoBoothState());

  final CapturePhotoUseCase _capturePhoto;
  final GetAvailableCamerasUseCase _getAvailableCameras;
  final GetSelectedCameraUseCase _getSelectedCamera;
  final SelectCameraUseCase _selectCamera;
  final PrepareCameraUseCase _prepareCamera;
  final ProcessPhotosUseCase _processPhotos;
  bool _disposed = false;

  void startSession(PhotoTemplate template) {
    _updateState(
      (current) => current.copyWith(
        status: PhotoBoothStatus.readyToCapture,
        selectedTemplate: template,
        capturedPhotos: const [],
        isCaptureInProgress: false,
        clearProcessedPhoto: true,
        clearError: true,
      ),
    );
  }

  Future<void> captureNextPhoto() async {
    if (!mounted) {
      return;
    }
    final template = state.selectedTemplate;
    if (template == null) {
      return;
    }

    if (state.availableCameras.isEmpty || state.activeCamera == null) {
      await _loadDefaultCamera();
    }

    if (state.availableCameras.isEmpty || state.activeCamera == null) {
      return;
    }

    if (!state.isCameraReady) {
      await prepareCameraForSession();
      if (!mounted || !state.isCameraReady) {
        return;
      }
    }

    final existingPhotos = List.of(state.capturedPhotos);

    _updateState(
      (current) => current.copyWith(
        status: PhotoBoothStatus.capturing,
        isCaptureInProgress: true,
        clearError: true,
        clearProcessedPhoto: true,
      ),
    );

    try {
      final capturedPhoto = await _capturePhoto(
        CapturePhotoParams(template: template, index: existingPhotos.length),
      );
      if (!mounted) {
        return;
      }
      existingPhotos.add(capturedPhoto);

      final PhotoBoothStatus nextStatus =
          existingPhotos.length == template.photoCount
          ? PhotoBoothStatus.readyToProcess
          : PhotoBoothStatus.readyToCapture;

      _updateState(
        (current) => current.copyWith(
          status: nextStatus,
          capturedPhotos: existingPhotos,
          isCaptureInProgress: false,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(
        (current) => current.copyWith(
          status: PhotoBoothStatus.failure,
          isCaptureInProgress: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> processSession() async {
    if (!mounted) {
      return;
    }
    final template = state.selectedTemplate;
    final photos = state.capturedPhotos;

    if (template == null || photos.isEmpty || !state.canProcess) {
      return;
    }

    _updateState(
      (current) => current.copyWith(
        status: PhotoBoothStatus.processing,
        isCaptureInProgress: true,
        clearError: true,
      ),
    );

    try {
      final processedPhoto = await _processPhotos(
        ProcessPhotosParams(template: template, capturedPhotos: photos),
      );

      if (!mounted) {
        return;
      }
      _updateState(
        (current) => current.copyWith(
          status: PhotoBoothStatus.completed,
          processedPhoto: processedPhoto,
          isCaptureInProgress: false,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(
        (current) => current.copyWith(
          status: PhotoBoothStatus.failure,
          isCaptureInProgress: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> loadAvailableCameras() async {
    if (state.isCameraLoading) {
      return;
    }
    _updateState(
      (current) =>
          current.copyWith(isCameraLoading: true, clearCameraError: true),
    );

    try {
      final cameras = await _getAvailableCameras(const NoParams());
      if (!mounted) {
        return;
      }
      CameraDevice? selected = state.activeCamera;
      if (selected == null) {
        selected = await _getSelectedCamera();
        if (!mounted) {
          return;
        }
      }
      if ((selected == null || !cameras.contains(selected)) &&
          cameras.isNotEmpty) {
        selected = cameras.first;
        await _selectCamera(selected);
        if (!mounted) {
          return;
        }
      }
      _updateState(
        (current) => current.copyWith(
          availableCameras: cameras,
          activeCamera: selected,
          isCameraLoading: false,
          isCameraReady: _prepareCamera.isReady,
          clearCameraError: true,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(
        (current) => current.copyWith(
          isCameraLoading: false,
          cameraError: error.toString(),
        ),
      );
    }
  }

  Future<void> selectCamera(CameraDevice device) async {
    _updateState(
      (current) =>
          current.copyWith(isCameraLoading: true, clearCameraError: true),
    );
    try {
      await _selectCamera(device);
      if (!mounted) {
        return;
      }
      _updateState(
        (current) => current.copyWith(
          activeCamera: device,
          isCameraLoading: false,
          isCameraReady: false,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(
        (current) => current.copyWith(
          isCameraLoading: false,
          cameraError: error.toString(),
        ),
      );
    }
  }

  Future<void> prepareCameraForSession() async {
    if (!mounted) {
      return;
    }
    if (state.isCameraReady && state.activeCamera != null) {
      return;
    }
    if (state.activeCamera == null) {
      await _loadDefaultCamera();
      if (!mounted) {
        return;
      }
      if (state.activeCamera == null) {
        _updateState(
          (current) => current.copyWith(
            cameraError: 'Select a camera before starting the session.',
          ),
        );
        return;
      }
    }
    _updateState(
      (current) =>
          current.copyWith(isCameraLoading: true, clearCameraError: true),
    );
    try {
      await _prepareCamera();
      if (!mounted) {
        return;
      }
      _updateState(
        (current) => current.copyWith(
          isCameraLoading: false,
          isCameraReady: _prepareCamera.isReady,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(
        (current) => current.copyWith(
          isCameraLoading: false,
          isCameraReady: false,
          cameraError: error.toString(),
        ),
      );
    }
  }

  void resetSession({bool preserveCamera = true}) {
    _updateState(
      (current) => PhotoBoothState(
        availableCameras: preserveCamera ? current.availableCameras : const [],
        activeCamera: preserveCamera ? current.activeCamera : null,
        isCameraReady: preserveCamera ? current.isCameraReady : false,
      ),
    );
  }

  void _updateState(
    PhotoBoothState Function(PhotoBoothState current) transform,
  ) {
    if (_disposed || !mounted) {
      return;
    }
    state = transform(state);
  }

  Future<void> _loadDefaultCamera() async {
    await loadAvailableCameras();
  }

  Future<bool> ensureCameraAvailable() async {
    if (_disposed || !mounted) {
      return false;
    }
    await _loadDefaultCamera();
    if (_disposed || !mounted) {
      return false;
    }
    if (state.availableCameras.isEmpty) {
      _updateState(
        (current) => current.copyWith(
          cameraError:
              current.cameraError ??
              'No cameras detected. Ensure camera access is enabled.',
        ),
      );
      return false;
    }
    if (state.activeCamera == null) {
      await selectCamera(state.availableCameras.first);
      if (_disposed || !mounted) {
        return false;
      }
    }
    await prepareCameraForSession();
    if (_disposed || !mounted) {
      return false;
    }
    final ready =
        state.availableCameras.isNotEmpty &&
        state.activeCamera != null &&
        state.isCameraReady;
    if (ready) {
      _updateState((current) => current.copyWith(clearCameraError: true));
    }
    return ready;
  }

  Future<void> initializeCamera() async {
    await ensureCameraAvailable();
  }

  Future<void> openCameraSettings() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
