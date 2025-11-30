import 'package:equatable/equatable.dart';

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
  });

  final PhotoBoothStatus status;
  final PhotoTemplate? selectedTemplate;
  final List<CapturedPhoto> capturedPhotos;
  final ProcessedPhoto? processedPhoto;
  final String? errorMessage;
  final bool isCaptureInProgress;

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

  PhotoBoothState copyWith({
    PhotoBoothStatus? status,
    PhotoTemplate? selectedTemplate,
    List<CapturedPhoto>? capturedPhotos,
    ProcessedPhoto? processedPhoto,
    String? errorMessage,
    bool? isCaptureInProgress,
    bool clearProcessedPhoto = false,
    bool clearError = false,
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
      ];
}

