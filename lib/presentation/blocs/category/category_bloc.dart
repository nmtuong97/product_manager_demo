import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_categories.dart';
import '../../../domain/usecases/get_category.dart';
import '../../../domain/usecases/add_category.dart';
import '../../../domain/usecases/update_category.dart';
import '../../../domain/usecases/delete_category.dart';

import 'category_barrel.dart';

@lazySingleton
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final GetCategory getCategory;
  final AddCategory addCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  CategoryBloc(
    this.getCategories,
    this.getCategory,
    this.addCategory,
    this.updateCategory,
    this.deleteCategory,
  ) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadCategoryById>(_onLoadCategoryById);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      final categories = await getCategories(event.forceRefresh);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Không thể tải danh sách danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCategoryById(
    LoadCategoryById event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      final category = await getCategory(event.categoryId);
      emit(CategoryDetailLoaded(category));
    } catch (e) {
      emit(CategoryError('Không thể tải thông tin danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      // Optimistic UI update
      final currentState = state;
      if (currentState is CategoryLoaded) {
        final updatedCategories = List<Category>.from(currentState.categories)
          ..add(event.category);
        emit(CategoryLoaded(updatedCategories));
      }

      await addCategory(event.category);
      emit(CategoryOperationSuccess('Thêm danh mục thành công'));
    } catch (e) {
      emit(CategoryError('Không thể thêm danh mục: ${e.toString()}'));
      // Revert UI on failure
      add(LoadCategories(forceRefresh: true));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      // Optimistic UI update
      final currentState = state;
      if (currentState is CategoryLoaded) {
        final updatedCategories = currentState.categories.map((c) {
          return c.id == event.category.id ? event.category : c;
        }).toList();
        emit(CategoryLoaded(updatedCategories));
      }

      await updateCategory(event.category);
      emit(CategoryOperationSuccess('Cập nhật danh mục thành công'));
    } catch (e) {
      emit(CategoryError('Không thể cập nhật danh mục: ${e.toString()}'));
      // Revert UI on failure
      add(LoadCategories(forceRefresh: true));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      final deletingIds = Set<String>.from(currentState.deletingCategoryIds);
      deletingIds.add(event.categoryId.toString());
      emit(currentState.copyWith(deletingCategoryIds: deletingIds));

      try {
        await deleteCategory(event.categoryId);

        // Remove the deleted category from the list directly
        final updatedCategories = List<Category>.from(currentState.categories)
          ..removeWhere((category) => category.id == event.categoryId);
        
        final updatedDeletingIds = Set<String>.from(currentState.deletingCategoryIds)
          ..remove(event.categoryId.toString());

        emit(currentState.copyWith(
          categories: updatedCategories,
          deletingCategoryIds: updatedDeletingIds,
        ));
      } catch (e) {
        emit(CategoryError('Không thể xóa danh mục: ${e.toString()}'));
        // Revert the loading state on failure
        final revertedIds = Set<String>.from(currentState.deletingCategoryIds);
        revertedIds.remove(event.categoryId.toString());
        emit(currentState.copyWith(deletingCategoryIds: revertedIds));
      }
    }
  }
}
