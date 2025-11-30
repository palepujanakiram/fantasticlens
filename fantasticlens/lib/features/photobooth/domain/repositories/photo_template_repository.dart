import '../entities/photo_template.dart';

abstract class PhotoTemplateRepository {
  Future<List<PhotoTemplate>> fetchTemplates();
}

