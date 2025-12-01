import 'package:equatable/equatable.dart';

import '../../domain/entities/camera_device.dart';
import '../../domain/entities/captured_photo.dart';
import '../../domain/entities/photo_template.dart';
import '../../domain/entities/processed_photo.dart';

enum PhotoBoothStatus {
  idle,
  readyToCapture,
  capturing,
  readyToProcess,
  processing,
  completed,
  failure,
}

class PhotoBoothState extends Equatable {
  const PhotoBoothState({
    this.status = PhotoBoothStatus.idle,
    this.selectedTemplate,
    this.capturedPhotos = const [],
    this.processedPhoto,
    this.errorMessage,
    this.isCaptureInProgress = false,
    this.availableCameras = const [],
    this.activeCamera,
    this.isCameraLoading = false,
    this.isCameraReady = false,
    this.cameraError,
  });

  final PhotoBoothStatus status;
  final PhotoTemplate? selectedTemplate;
  final List<CapturedPhoto> capturedPhotos;
  final ProcessedPhoto? processedPhoto;
  final String? errorMessage;
  final bool isCaptureInProgress;
  final List<CameraDevice> availableCameras;
  final CameraDevice? activeCamera;
  final bool isCameraLoading;
  final bool isCameraReady;
  final String? cameraError;

  bool get hasTemplate => selectedTemplate != null;

  bool get canCapture {
    final template = selectedTemplate;
    if (template == null) {
      return false;
    }
    return capturedPhotos.length < template.photoCount && !isCaptureInProgress;
  }

  bool get canProcess {
    final template = selectedTemplate;
    if (template == null) {
      return false;
    }
    return capturedPhotos.length == template.photoCount &&
        !isCaptureInProgress &&
        status != PhotoBoothStatus.processing;
  }

  bool get hasCameraSelected => activeCamera != null;

  PhotoBoothState copyWith({
    PhotoBoothStatus? status,
    PhotoTemplate? selectedTemplate,
    List<CapturedPhoto>? capturedPhotos,
    ProcessedPhoto? processedPhoto,
    String? errorMessage,
    bool? isCaptureInProgress,
    bool clearProcessedPhoto = false,
    bool clearError = false,
    List<CameraDevice>? availableCameras,
    CameraDevice? activeCamera,
    bool? isCameraLoading,
    bool? isCameraReady,
    String? cameraError,
    bool clearCameraError = false,
    bool clearActiveCamera = false,
  }) {
    return PhotoBoothState(
      status: status ?? this.status,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      capturedPhotos: capturedPhotos ?? this.capturedPhotos,
      processedPhoto:
          clearProcessedPhoto ? null : processedPhoto ?? this.processedPhoto,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isCaptureInProgress:
          isCaptureInProgress ?? this.isCaptureInProgress,
      availableCameras: availableCameras ?? this.availableCameras,
      activeCamera:
          clearActiveCamera ? null : activeCamera ?? this.activeCamera,
      isCameraLoading: isCameraLoading ?? this.isCameraLoading,
      isCameraReady: isCameraReady ?? this.isCameraReady,
      cameraError: clearCameraError ? null : cameraError ?? this.cameraError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTemplate,
        capturedPhotos,
        processedPhoto,
        errorMessage,
        isCaptureInProgress,
        availableCameras,
        activeCamera,
        isCameraLoading,
        isCameraReady,
        cameraError,
      ];
}

