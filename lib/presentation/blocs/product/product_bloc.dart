import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/add_product.dart';
import '../../../domain/usecases/add_multiple_products.dart';
import '../../../domain/usecases/delete_product.dart';
import '../../../domain/usecases/get_product.dart';
import '../../../domain/usecases/get_products.dart';
import '../../../domain/usecases/search_products.dart';
import '../../../domain/usecases/update_product.dart';
import 'product_event.dart';
import 'product_state.dart';

/// BLoC for managing product-related state and business logic
///
/// This BLoC handles all product operations including CRUD operations,
/// loading states, and error handling following Clean Architecture principles.
@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  final GetProduct _getProduct;
  final AddProduct _addProduct;
  final AddMultipleProducts _addMultipleProducts;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final SearchProducts _searchProducts;

  ProductBloc({
    required GetProducts getProducts,
    required GetProduct getProduct,
    required AddProduct addProduct,
    required AddMultipleProducts addMultipleProducts,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required SearchProducts searchProducts,
  }) : _getProducts = getProducts,
       _getProduct = getProduct,
       _addProduct = addProduct,
       _addMultipleProducts = addMultipleProducts,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct,
       _searchProducts = searchProducts,
       super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductById>(_onLoadProductById);
    on<AddProductEvent>(_onAddProduct);
    on<AddMultipleProductsEvent>(_onAddMultipleProducts);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<ResetProductState>(_onResetProductState);
    on<SearchProductsEvent>(_onSearchProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
  }

  /// Handles loading products with optional force refresh and sorting by updateTime (newest first)
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());
      final products = await _getProducts(forceRefresh: event.forceRefresh);
      // Sort products by updatedAt descending (newest first)
      final sortedProducts = List<Product>.from(products)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      emit(ProductLoaded(sortedProducts));
    } catch (e) {
      emit(ProductError('Không thể tải danh sách sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles loading a specific product by ID
  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());
      final product = await _getProduct(event.productId);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError('Không thể tải thông tin sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles adding a new product with loading state
  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductAdding());
    try {
      final createdProduct = await _addProduct(event.product);
      emit(
        ProductOperationSuccess(
          'Thêm sản phẩm thành công',
          productId: createdProduct.id,
        ),
      );

      // Reload products after successful addition with force refresh
      add(const LoadProducts(forceRefresh: true));
    } catch (e) {
      emit(ProductError('Không thể thêm sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles adding multiple products with loading state
  Future<void> _onAddMultipleProducts(
    AddMultipleProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductAdding());
    try {
      await _addMultipleProducts(event.products);
      emit(
        ProductOperationSuccess(
          'Thêm ${event.products.length} sản phẩm thành công',
        ),
      );

      // Reload products after successful addition with force refresh
      add(const LoadProducts(forceRefresh: true));
    } catch (e) {
      emit(ProductError('Không thể thêm nhiều sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles updating an existing product with loading state
  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductUpdating());
    try {
      await _updateProduct(event.product);
      emit(const ProductOperationSuccess('Cập nhật sản phẩm thành công'));
    } catch (e) {
      emit(ProductError('Không thể cập nhật sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles deleting a product with loading state
  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductDeleting());
    try {
      await _deleteProduct(event.productId);
      emit(const ProductOperationSuccess('Xóa sản phẩm thành công'));
    } catch (e) {
      emit(ProductError('Không thể xóa sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles resetting product state
  void _onResetProductState(
    ResetProductState event,
    Emitter<ProductState> emit,
  ) {
    emit(const ProductInitial());
  }

  /// Handles searching products with loading state and sorting by updateTime (newest first)
  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const ProductInitial());
      return;
    }

    emit(ProductSearching(event.query));
    try {
      final searchResults = await _searchProducts(
        event.query,
        categoryId: event.categoryId,
      );
      // Sort search results by updatedAt descending (newest first)
      final sortedResults = List<Product>.from(searchResults)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      emit(
        ProductSearchLoaded(
          searchResults: sortedResults,
          query: event.query,
          categoryId: event.categoryId,
        ),
      );
    } catch (e) {
      emit(ProductError('Không thể tìm kiếm sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles loading products by category with sorting by updateTime (newest first)
  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await _getProducts();
      final filteredProducts = products
          .where((product) => product.categoryId == event.categoryId)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Sort by updatedAt descending (newest first)
      emit(ProductLoaded(filteredProducts));
    } catch (e) {
      emit(
        ProductError('Không thể tải sản phẩm theo danh mục: ${e.toString()}'),
      );
    }
  }
}
