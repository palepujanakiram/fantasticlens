import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/local_template_data_source.dart';
import '../../data/repositories/photo_capture_repository_impl.dart';
import '../../data/repositories/photo_processing_repository_impl.dart';
import '../../data/repositories/photo_template_repository_impl.dart';
import '../../domain/repositories/photo_capture_repository.dart';
import '../../domain/repositories/photo_processing_repository.dart';
import '../../domain/repositories/photo_template_repository.dart';
import '../../domain/usecases/capture_photo.dart';
import '../../domain/usecases/get_photo_templates.dart';
import '../../domain/usecases/process_photos.dart';
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

final photoCaptureRepositoryProvider =
    Provider<PhotoCaptureRepository>((ref) {
  return PhotoCaptureRepositoryImpl();
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
  final processPhotos = ref.watch(processPhotosUseCaseProvider);
  return PhotoBoothController(
    capturePhoto: capturePhoto,
    processPhotos: processPhotos,
  );
});

