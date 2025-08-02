import 'package:injectable/injectable.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../../core/utils/text_utils.dart';

/// Implementation of ProductRepository following Clean Architecture principles
///
/// This repository coordinates between local and remote data sources,
/// implementing caching strategies and offline-first approach.
@Injectable(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _localDataSource;
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({
    required ProductLocalDataSource localDataSource,
    required ProductRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<List<Product>> getProducts([bool forceRefresh = false]) async {
    try {
      // Try to get from remote first if force refresh or no local data
      if (forceRefresh) {
        try {
          final remoteProducts = await _remoteDataSource.getProducts();
          // Clear local cache and insert fresh data
          await _localDataSource.clearProducts();
          await _localDataSource.insertProducts(remoteProducts);
          return remoteProducts;
        } catch (e) {
          // If remote fails, fall back to local data
          return await _localDataSource.getProducts();
        }
      }

      // Get from local first (offline-first approach)
      final localProducts = await _localDataSource.getProducts();
      if (localProducts.isNotEmpty) {
        return localProducts;
      }

      // If no local data, try remote
      try {
        final remoteProducts = await _remoteDataSource.getProducts();
        await _localDataSource.insertProducts(remoteProducts);
        return remoteProducts;
      } catch (e) {
        // Return empty list if both local and remote fail
        return [];
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách sản phẩm: $e');
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      // Try local first
      try {
        return await _localDataSource.getProduct(id);
      } catch (e) {
        // If not found locally, try remote
        try {
          final remoteProduct = await _remoteDataSource.getProduct(id);
          await _localDataSource.insertProduct(remoteProduct);
          return remoteProduct;
        } catch (e) {
          throw Exception('Không tìm thấy sản phẩm với ID: $id');
        }
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy sản phẩm: $e');
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    try {
      // Add to local first
      await _localDataSource.insertProduct(product);

      // Try to sync with remote
      try {
        final createdProduct = await _remoteDataSource.createProduct(product);
        return createdProduct;
      } catch (e) {
        // Log error but don't fail the operation
        // The product is saved locally and will sync later

        return product;
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm sản phẩm: $e');
    }
  }

  @override
  Future<void> addMultipleProducts(List<Product> products) async {
    try {
      // Add to local first using batch operation
      await _localDataSource.insertProducts(products);

      // Try to sync with remote (for now, we'll add them one by one)
      // In a real app, you might want to implement a batch API endpoint
      try {
        for (final product in products) {
          await _remoteDataSource.createProduct(product);
        }
      } catch (e) {
        // Log error but don't fail the operation
        // The products are saved locally and will sync later
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm nhiều sản phẩm: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      // Update local first
      await _localDataSource.updateProduct(product);

      // Try to sync with remote
      try {
        await _remoteDataSource.updateProduct(product);
      } catch (e) {
        // Log error but don't fail the operation
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật sản phẩm: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      // Delete from local first
      await _localDataSource.deleteProduct(id);

      // Try to sync with remote
      try {
        await _remoteDataSource.deleteProduct(id);
      } catch (e) {
        // Log error but don't fail the operation
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa sản phẩm: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query, {int? categoryId}) async {
    try {
      // Always search from remote API for real-time results
      return await _remoteDataSource.searchProducts(
        query,
        categoryId: categoryId,
      );
    } catch (e) {
      // Fallback to local search if remote fails with Vietnamese diacritic support
      try {
        final localProducts = await _localDataSource.getProducts();
        return localProducts.where((product) {
          final matchesQuery =
              TextUtils.matchesSearch(product.name, query) ||
              TextUtils.matchesSearch(product.description, query);

          if (categoryId != null) {
            return matchesQuery && product.categoryId == categoryId;
          }
          return matchesQuery;
        }).toList();
      } catch (localError) {
        throw Exception('Lỗi khi tìm kiếm sản phẩm: $e');
      }
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      // Try remote first
      return await _remoteDataSource.getProductsByCategory(categoryId);
    } catch (e) {
      // Fallback to local data
      try {
        final localProducts = await _localDataSource.getProducts();
        return localProducts
            .where((product) => product.categoryId == categoryId)
            .toList();
      } catch (localError) {
        throw Exception('Lỗi khi lấy sản phẩm theo danh mục: $e');
      }
    }
  }
}
