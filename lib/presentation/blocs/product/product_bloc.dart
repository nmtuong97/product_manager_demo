import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/add_product.dart';
import '../../../domain/usecases/delete_product.dart';
import '../../../domain/usecases/get_product.dart';
import '../../../domain/usecases/get_products.dart';
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
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;

  ProductBloc({
    required GetProducts getProducts,
    required GetProduct getProduct,
    required AddProduct addProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
  }) : _getProducts = getProducts,
       _getProduct = getProduct,
       _addProduct = addProduct,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct,
       super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductById>(_onLoadProductById);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<ResetProductState>(_onResetProductState);
  }

  /// Handles loading products with optional force refresh
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final products = await _getProducts(forceRefresh: event.forceRefresh);
      emit(ProductLoaded(products));
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
      emit(ProductLoading());
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
    emit(ProductAdding());
    try {
      final createdProduct = await _addProduct(event.product);
      emit(
        ProductOperationSuccess(
          'Thêm sản phẩm thành công',
          productId: createdProduct.id,
        ),
      );

      // Reload products after successful addition with force refresh
      add(LoadProducts(forceRefresh: true));
    } catch (e) {
      emit(ProductError('Không thể thêm sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles updating an existing product with loading state
  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductUpdating());
    try {
      await _updateProduct(event.product);
      emit(ProductOperationSuccess('Cập nhật sản phẩm thành công'));
    } catch (e) {
      emit(ProductError('Không thể cập nhật sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles deleting a product with loading state
  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductDeleting());
    try {
      await _deleteProduct(event.productId);
      emit(ProductOperationSuccess('Xóa sản phẩm thành công'));
    } catch (e) {
      emit(ProductError('Không thể xóa sản phẩm: ${e.toString()}'));
    }
  }

  /// Handles resetting product state
  void _onResetProductState(
    ResetProductState event,
    Emitter<ProductState> emit,
  ) {
    emit(ProductInitial());
  }
}
