import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';

/// Base abstract class for all category-related events
///
/// This class defines the contract for all possible events
/// that can be dispatched to the CategoryBloc.
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all categories
class LoadCategories extends CategoryEvent {
  /// Whether to force refresh from remote data source
  final bool forceRefresh;

  const LoadCategories({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Event to add a new category
class AddCategoryEvent extends CategoryEvent {
  /// The category to be added
  final Category category;

  const AddCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to update an existing category
class UpdateCategoryEvent extends CategoryEvent {
  /// The category with updated information
  final Category category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to delete a category
class DeleteCategoryEvent extends CategoryEvent {
  /// The ID of the category to be deleted
  final int categoryId;

  const DeleteCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Event to load a specific category by ID
class LoadCategoryById extends CategoryEvent {
  /// The ID of the category to load
  final int categoryId;

  const LoadCategoryById(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
