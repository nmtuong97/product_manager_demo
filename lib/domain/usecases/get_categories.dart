import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

@injectable
class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call([bool forceRefresh = false]) {
    return repository.getCategories(forceRefresh);
  }
}
