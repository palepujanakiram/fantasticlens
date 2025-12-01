import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/local_template_data_source.dart';
import '../../data/repositories/photo_capture_repository_impl.dart';
import '../../data/repositories/photo_processing_repository_impl.dart';
import '../../data/repositories/photo_template_repository_impl.dart';
import '../../data/services/camera_manager.dart';
import '../../domain/repositories/photo_capture_repository.dart';
import '../../domain/repositories/photo_processing_repository.dart';
import '../../domain/repositories/photo_template_repository.dart';
import '../../domain/usecases/capture_photo.dart';
import '../../domain/usecases/get_available_cameras.dart';
import '../../domain/usecases/get_photo_templates.dart';
import '../../domain/usecases/get_selected_camera.dart';
import '../../domain/usecases/prepare_camera.dart';
import '../../domain/usecases/process_photos.dart';
import '../../domain/usecases/select_camera.dart';
import '../state/photo_booth_state.dart';
import 'photo_booth_controller.dart';

final localTemplateDataSourceProvider =
    Provider<LocalTemplateDataSource>((ref) {
  return const LocalTemplateDataSource();
});

final photoTemplateRepositoryProvider =
    Provider<PhotoTemplateRepository>((ref) {
  final dataSource = ref.watch(localTemplateDataSourceProvider);
  return PhotoTemplateRepositoryImpl(dataSource);
});

final cameraManagerProvider =
    ChangeNotifierProvider<CameraManager>((ref) {
  return CameraManager();
});

final photoCaptureRepositoryProvider =
    Provider<PhotoCaptureRepository>((ref) {
  final manager = ref.watch(cameraManagerProvider);
  final repository = PhotoCaptureRepositoryImpl(
    cameraManager: manager,
  );
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
});

final photoProcessingRepositoryProvider =
    Provider<PhotoProcessingRepository>((ref) {
  return PhotoProcessingRepositoryImpl();
});

final getPhotoTemplatesUseCaseProvider =
    Provider<GetPhotoTemplatesUseCase>((ref) {
  final repository = ref.watch(photoTemplateRepositoryProvider);
  return GetPhotoTemplatesUseCase(repository);
});

final capturePhotoUseCaseProvider = Provider<CapturePhotoUseCase>((ref) {
  final repository = ref.watch(photoCaptureRepositoryProvider);
  return CapturePhotoUseCase(repository);
});

final getAvailableCamerasUseCaseProvider =
    Provider<GetAvailableCamerasUseCase>((ref) {
  final repository = ref.watch(photoCaptureRepositoryProvider);
  return GetAvailableCamerasUseCase(repository);
});

final getSelectedCameraUseCaseProvider =
    Provider<GetSelectedCameraUseCase>((ref) {
  final repository = ref.watch(photoCaptureRepositoryProvider);
  return GetSelectedCameraUseCase(repository);
});

final selectCameraUseCaseProvider = Provider<SelectCameraUseCase>((ref) {
  final repository = ref.watch(photoCaptureRepositoryProvider);
  return SelectCameraUseCase(repository);
});

final prepareCameraUseCaseProvider = Provider<PrepareCameraUseCase>((ref) {
  final repository = ref.watch(photoCaptureRepositoryProvider);
  return PrepareCameraUseCase(repository);
});

final processPhotosUseCaseProvider = Provider<ProcessPhotosUseCase>((ref) {
  final repository = ref.watch(photoProcessingRepositoryProvider);
  return ProcessPhotosUseCase(repository);
});

final photoTemplatesProvider =
    FutureProvider.autoDispose((ref) async => ref.watch(
          getPhotoTemplatesUseCaseProvider,
        )(const NoParams()));

final photoBoothControllerProvider =
    StateNotifierProvider<PhotoBoothController, PhotoBoothState>((ref) {
  final capturePhoto = ref.watch(capturePhotoUseCaseProvider);
  final getCameras = ref.watch(getAvailableCamerasUseCaseProvider);
  final getSelectedCamera = ref.watch(getSelectedCameraUseCaseProvider);
  final selectCamera = ref.watch(selectCameraUseCaseProvider);
  final prepareCamera = ref.watch(prepareCameraUseCaseProvider);
  final processPhotos = ref.watch(processPhotosUseCaseProvider);
  final controller = PhotoBoothController(
    capturePhoto: capturePhoto,
    getAvailableCameras: getCameras,
    getSelectedCamera: getSelectedCamera,
    selectCamera: selectCamera,
    prepareCamera: prepareCamera,
    processPhotos: processPhotos,
  );
  Future.microtask(controller.initializeCamera);
  return controller;
});

