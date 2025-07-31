import 'package:injectable/injectable.dart';

import '../repositories/category_repository.dart';

@injectable
class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  Future<void> call(int id) {
    return repository.deleteCategory(id);
  }
}
