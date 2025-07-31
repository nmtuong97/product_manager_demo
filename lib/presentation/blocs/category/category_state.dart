import '../../../domain/entities/category.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final Set<String> deletingCategoryIds;

  CategoryLoaded(this.categories, {this.deletingCategoryIds = const {}});

  CategoryLoaded copyWith({
    List<Category>? categories,
    Set<String>? deletingCategoryIds,
  }) {
    return CategoryLoaded(
      categories ?? this.categories,
      deletingCategoryIds: deletingCategoryIds ?? this.deletingCategoryIds,
    );
  }
}

class CategoryDetailLoaded extends CategoryState {
  final Category category;

  CategoryDetailLoaded(this.category);
}

class CategoryOperationSuccess extends CategoryState {
  final String message;

  CategoryOperationSuccess(this.message);
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}
