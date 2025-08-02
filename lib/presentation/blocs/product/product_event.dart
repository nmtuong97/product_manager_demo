import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

/// Base abstract class for all product-related events
///
/// This class defines the contract for all possible events
/// that can be dispatched to the ProductBloc.
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all products
class LoadProducts extends ProductEvent {
  /// Whether to force refresh from remote data source
  final bool forceRefresh;

  const LoadProducts({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Event to load a specific product by ID
class LoadProductById extends ProductEvent {
  /// The ID of the product to load
  final int productId;

  const LoadProductById(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event to add a new product
class AddProductEvent extends ProductEvent {
  /// The product to be added
  final Product product;

  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event to update an existing product
class UpdateProductEvent extends ProductEvent {
  /// The product with updated information
  final Product product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event to delete a product
class DeleteProductEvent extends ProductEvent {
  /// The ID of the product to be deleted
  final int productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event to reset product state
class ResetProductState extends ProductEvent {
  const ResetProductState();
}
