import '../../domain/entities/photo_template.dart';
import '../../domain/repositories/photo_template_repository.dart';
import '../datasources/local_template_data_source.dart';

class PhotoTemplateRepositoryImpl implements PhotoTemplateRepository {
  PhotoTemplateRepositoryImpl(this._dataSource);

  final LocalTemplateDataSource _dataSource;

  @override
  Future<List<PhotoTemplate>> fetchTemplates() {
    return _dataSource.loadTemplates();
  }
}

