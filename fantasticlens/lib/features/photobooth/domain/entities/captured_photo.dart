import 'dart:typed_data';

class CapturedPhoto {
  const CapturedPhoto({
    required this.id,
    required this.index,
    required this.capturedAt,
    required this.placeholderColor,
    this.imageBytes,
  });

  final String id;
  final int index;
  final DateTime capturedAt;
  final int placeholderColor;
  final Uint8List? imageBytes;
}

