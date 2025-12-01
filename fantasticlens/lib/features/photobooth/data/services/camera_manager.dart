import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/camera_device.dart';

class CameraManager extends ChangeNotifier {
  CameraManager();

  List<CameraDescription> _availableDescriptions = [];
  CameraDescription? _selectedDescription;
  CameraController? _controller;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  List<CameraDevice> get availableDevices =>
      _availableDescriptions.map(_mapToDevice).toList(growable: false);

  CameraDevice? get selectedDevice =>
      _selectedDescription != null ? _mapToDevice(_selectedDescription!) : null;

  CameraController? get controller => _controller;

  bool get isLoading => _isLoading;

  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized && _isInitialized;

  bool get hasError => _errorMessage != null;

  String? get errorMessage => _errorMessage;

  Future<List<CameraDevice>> loadAvailableCameras() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final permissionGranted = await _ensurePermissionGranted();
      if (!permissionGranted) {
        await disposeCamera();
        _availableDescriptions = [];
        notifyListeners();
        return availableDevices;
      }
      _availableDescriptions = await availableCameras();
      if (_availableDescriptions.isEmpty) {
        // Some devices (notably Samsung Galaxy on Android 14/15+) need a short
        // delay after permission is granted before the hardware is exposed.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        _availableDescriptions = await availableCameras();
      }
      _availableDescriptions.sort(
        (a, b) => _lensPriority(
          a.lensDirection,
        ).compareTo(_lensPriority(b.lensDirection)),
      );
      if (_availableDescriptions.isEmpty) {
        _errorMessage =
            'No cameras detected. Ensure camera access is enabled '
            'in quick settings and that no other app is using the camera.';
      }
      if (_availableDescriptions.isEmpty) {
        _selectedDescription = null;
      } else if (_selectedDescription == null) {
        _selectedDescription = _availableDescriptions.firstWhere(
          (description) =>
              description.lensDirection == CameraLensDirection.front,
          orElse: () => _availableDescriptions.first,
        );
      }
      notifyListeners();
      return availableDevices;
    } on CameraException catch (error) {
      _errorMessage = _mapCameraException(error);
      return availableDevices;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectCamera(CameraDevice device) async {
    if (_selectedDescription?.name == device.id) {
      return;
    }
    final description = _availableDescriptions.firstWhere(
      (element) => element.name == device.id,
      orElse: () => _availableDescriptions.isNotEmpty
          ? _availableDescriptions.first
          : throw StateError('No cameras initialized to select from.'),
    );
    _selectedDescription = description;
    await _initializeSelectedCamera();
    notifyListeners();
  }

  Future<void> ensureCameraInitialized() async {
    final permissionGranted = await _ensurePermissionGranted();
    if (!permissionGranted) {
      throw StateError(
        'Camera permission not granted. Enable access in settings.',
      );
    }
    if (_selectedDescription == null) {
      await loadAvailableCameras();
    }
    if (_selectedDescription == null) {
      throw StateError('No camera selected.');
    }
    if (!isInitialized) {
      await _initializeSelectedCamera();
    }
  }

  Future<Uint8List> capturePhotoBytes() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw StateError('Camera is not ready.');
    }
    final XFile file = await controller.takePicture();
    final bytes = await file.readAsBytes();
    return bytes;
  }

  Future<void> disposeCamera() async {
    _isInitialized = false;
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
    notifyListeners();
  }

  Future<void> _initializeSelectedCamera() async {
    final description = _selectedDescription;
    if (description == null) {
      throw StateError('No camera selected.');
    }
    await _controller?.dispose();
    final CameraController controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      _controller = controller;
      _isInitialized = true;
    } on CameraException catch (error) {
      _errorMessage = _mapCameraException(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  CameraDevice _mapToDevice(CameraDescription description) {
    return CameraDevice(
      id: description.name,
      name: _formatCameraName(description),
      lensFacing: _mapLensDirection(description.lensDirection),
      isExternal: description.lensDirection == CameraLensDirection.external,
    );
  }

  int _lensPriority(CameraLensDirection direction) => switch (direction) {
    CameraLensDirection.front => 0,
    CameraLensDirection.back => 1,
    CameraLensDirection.external => 2,
  };

  CameraLensFacing _mapLensDirection(CameraLensDirection direction) =>
      switch (direction) {
        CameraLensDirection.back => CameraLensFacing.back,
        CameraLensDirection.front => CameraLensFacing.front,
        CameraLensDirection.external => CameraLensFacing.external,
      };

  String _formatCameraName(CameraDescription description) {
    final String lensLabel = switch (description.lensDirection) {
      CameraLensDirection.back => 'Back camera',
      CameraLensDirection.front => 'Front camera',
      CameraLensDirection.external => 'External camera',
    };

    if (description.name.isEmpty) {
      return lensLabel;
    }

    return '${description.name} • $lensLabel';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> _ensurePermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      if (_isGrantedStatus(status)) {
        return true;
      }
      if (status.isPermanentlyDenied) {
        _errorMessage =
            'Camera access is permanently denied. Enable it in Settings.';
        await openAppSettings();
        return false;
      }
      final result = await Permission.camera.request();
      if (_isGrantedStatus(result)) {
        return true;
      }
      if (result.isPermanentlyDenied) {
        _errorMessage =
            'Camera access is permanently denied. Enable it in Settings.';
        await openAppSettings();
      } else {
        _errorMessage = 'Camera permission is required to capture photos.';
      }
      return false;
    } on PlatformException {
      // During tests or unsupported platforms, treat as granted.
      return true;
    }
  }

  bool _isGrantedStatus(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }

  String _mapCameraException(CameraException error) {
    final message = error.description ?? error.code;
    if (error.code.toLowerCase().contains('cameraaccessexception')) {
      return 'Camera access is currently blocked by the system. Make sure the '
          '“Camera access” quick setting is enabled and that no other app is '
          'using the camera.';
    }
    if (message.toLowerCase().contains('disabled')) {
      return 'The device camera is disabled. Enable it in system settings and '
          'try again.';
    }
    return message;
  }

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }
}
