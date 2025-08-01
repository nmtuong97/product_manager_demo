import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

/// Base abstract class for all product-related states
///
/// This class defines the contract for all possible states
/// in the product management feature.
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the ProductBloc is first created
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Loading state when any product operation is in progress
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// State when products are successfully loaded
class ProductLoaded extends ProductState {
  /// List of loaded products
  final List<Product> products;

  /// Set of product IDs that are currently being deleted
  final Set<String> deletingProductIds;

  const ProductLoaded(this.products, {this.deletingProductIds = const {}});

  /// Creates a copy of this state with updated values
  ProductLoaded copyWith({
    List<Product>? products,
    Set<String>? deletingProductIds,
  }) {
    return ProductLoaded(
      products ?? this.products,
      deletingProductIds: deletingProductIds ?? this.deletingProductIds,
    );
  }

  @override
  List<Object?> get props => [products, deletingProductIds];
}

/// State when a specific product detail is loaded
class ProductDetailLoaded extends ProductState {
  /// The loaded product
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

/// State when a product operation is successful
class ProductOperationSuccess extends ProductState {
  /// Success message to display
  final String message;
  
  /// Optional product ID for operations that create/update products
  final int? productId;

  const ProductOperationSuccess(this.message, {this.productId});

  @override
  List<Object?> get props => [message, productId];
}

/// Error state when any product operation fails
class ProductError extends ProductState {
  /// Error message to display
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when adding a product is in progress
class ProductAdding extends ProductState {
  const ProductAdding();
}

/// State when updating a product is in progress
class ProductUpdating extends ProductState {
  const ProductUpdating();
}