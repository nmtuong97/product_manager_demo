import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';

/// Base abstract class for all category-related states
///
/// This class defines the contract for all possible states
/// in the category management feature.
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the CategoryBloc is first created
class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// Loading state when any category operation is in progress
class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// State when categories are successfully loaded
class CategoryLoaded extends CategoryState {
  /// List of loaded categories
  final List<Category> categories;

  /// Set of category IDs that are currently being deleted
  final Set<String> deletingCategoryIds;

  const CategoryLoaded(this.categories, {this.deletingCategoryIds = const {}});

  /// Creates a copy of this state with updated values
  CategoryLoaded copyWith({
    List<Category>? categories,
    Set<String>? deletingCategoryIds,
  }) {
    return CategoryLoaded(
      categories ?? this.categories,
      deletingCategoryIds: deletingCategoryIds ?? this.deletingCategoryIds,
    );
  }

  @override
  List<Object?> get props => [categories, deletingCategoryIds];
}

/// State when a specific category detail is loaded
class CategoryDetailLoaded extends CategoryState {
  /// The loaded category
  final Category category;

  const CategoryDetailLoaded(this.category);

  @override
  List<Object?> get props => [category];
}

/// State when a category operation completes successfully
class CategoryOperationSuccess extends CategoryState {
  /// Success message to display to user
  final String message;

  const CategoryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when a category operation fails
class CategoryError extends CategoryState {
  /// Error message to display to user
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
