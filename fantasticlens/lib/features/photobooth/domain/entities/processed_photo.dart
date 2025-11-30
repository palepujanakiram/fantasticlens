import 'dart:typed_data';

class ProcessedPhoto {
  const ProcessedPhoto({
    required this.sessionId,
    required this.placeholderColor,
    required this.processedAt,
    this.imageBytes,
  });

  final String sessionId;
  final int placeholderColor;
  final DateTime processedAt;
  final Uint8List? imageBytes;
}

