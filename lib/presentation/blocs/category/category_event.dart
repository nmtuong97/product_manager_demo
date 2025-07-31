import '../../../domain/entities/category.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {
  final bool forceRefresh;

  LoadCategories({this.forceRefresh = false});
}

class AddCategoryEvent extends CategoryEvent {
  final Category category;

  AddCategoryEvent(this.category);
}

class UpdateCategoryEvent extends CategoryEvent {
  final Category category;

  UpdateCategoryEvent(this.category);
}

class DeleteCategoryEvent extends CategoryEvent {
  final int categoryId;

  DeleteCategoryEvent(this.categoryId);
}

class LoadCategoryById extends CategoryEvent {
  final int categoryId;

  LoadCategoryById(this.categoryId);
}
