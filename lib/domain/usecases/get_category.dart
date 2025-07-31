import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

@injectable
class GetCategory {
  final CategoryRepository repository;

  GetCategory(this.repository);

  Future<Category> call(int id) {
    return repository.getCategory(id);
  }
}
