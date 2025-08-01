import 'package:injectable/injectable.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call({bool forceRefresh = false}) {
    return repository.getProducts(forceRefresh);
  }
}
