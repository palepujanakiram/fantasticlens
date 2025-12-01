import 'package:equatable/equatable.dart';

enum CameraLensFacing {
  front,
  back,
  external,
  unknown,
}

class CameraDevice extends Equatable {
  const CameraDevice({
    required this.id,
    required this.name,
    required this.lensFacing,
    required this.isExternal,
  });

  final String id;
  final String name;
  final CameraLensFacing lensFacing;
  final bool isExternal;

  CameraDevice copyWith({
    String? id,
    String? name,
    CameraLensFacing? lensFacing,
    bool? isExternal,
  }) {
    return CameraDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      lensFacing: lensFacing ?? this.lensFacing,
      isExternal: isExternal ?? this.isExternal,
    );
  }

  @override
  List<Object?> get props => [id, name, lensFacing, isExternal];
}

