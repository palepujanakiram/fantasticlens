import '../../domain/entities/photo_template.dart';
import '../../domain/entities/template_theme_data.dart';

class LocalTemplateDataSource {
  const LocalTemplateDataSource();

  Future<List<PhotoTemplate>> loadTemplates() async {
    return const [
      PhotoTemplate(
        id: 'classic_strip',
        name: 'Classic Strip',
        description: 'Four quick shots with a retro strip-style finish.',
        photoCount: 4,
        captureInterval: Duration(seconds: 2),
        theme: TemplateThemeData(
          primaryColor: 0xFF1B4B66,
          accentColor: 0xFFEBE0D0,
          backgroundGradient: [0xFF0E1A2A, 0xFF1B4B66],
        ),
      ),
      PhotoTemplate(
        id: 'modern_square',
        name: 'Modern Square',
        description: 'Three square frames with bold color blocking.',
        photoCount: 3,
        captureInterval: Duration(seconds: 3),
        theme: TemplateThemeData(
          primaryColor: 0xFF9B5DE5,
          accentColor: 0xFFF15BB5,
          backgroundGradient: [0xFF10002B, 0xFF240046, 0xFF3C096C],
        ),
      ),
      PhotoTemplate(
        id: 'celebration_postcard',
        name: 'Celebration Postcard',
        description: 'Two wide shots with space for event branding.',
        photoCount: 2,
        captureInterval: Duration(seconds: 4),
        theme: TemplateThemeData(
          primaryColor: 0xFF00B4D8,
          accentColor: 0xFF48CAE4,
          backgroundGradient: [0xFF03045E, 0xFF0077B6, 0xFF00B4D8],
        ),
      ),
    ];
  }
}

