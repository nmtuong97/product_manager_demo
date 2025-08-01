import 'package:injectable/injectable.dart';

import '../repositories/product_repository.dart';

@injectable
class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<void> call(int id) {
    return repository.deleteProduct(id);
  }
}
