import 'template_theme_data.dart';

class PhotoTemplate {
  const PhotoTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.photoCount,
    required this.captureInterval,
    required this.theme,
  });

  final String id;
  final String name;
  final String description;
  final int photoCount;
  final Duration captureInterval;
  final TemplateThemeData theme;
}

