import 'package:injectable/injectable.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  Future<Product> call(Product product) {
    return repository.addProduct(product);
  }
}
