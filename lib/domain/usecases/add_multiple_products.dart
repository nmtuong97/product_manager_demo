import 'package:injectable/injectable.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class AddMultipleProducts {
  final ProductRepository repository;

  AddMultipleProducts(this.repository);

  Future<void> call(List<Product> products) {
    return repository.addMultipleProducts(products);
  }
}
