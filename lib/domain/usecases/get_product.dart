import 'package:injectable/injectable.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProduct {
  final ProductRepository repository;

  GetProduct(this.repository);

  Future<Product> call(int id) {
    return repository.getProduct(id);
  }
}
