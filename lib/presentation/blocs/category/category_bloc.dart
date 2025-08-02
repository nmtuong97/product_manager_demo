import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/usecases/add_category.dart';
import '../../../domain/usecases/delete_category.dart';
import '../../../domain/usecases/get_categories.dart';
import '../../../domain/usecases/get_category.dart';
import '../../../domain/usecases/update_category.dart';
import 'category_event.dart';
import 'category_state.dart';

/// BLoC for managing category-related state and business logic
///
/// This BLoC handles all category operations including CRUD operations,
/// loading states, and error handling following Clean Architecture principles.
@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories _getCategories;
  final GetCategory _getCategory;
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  CategoryBloc({
    required GetCategories getCategories,
    required GetCategory getCategory,
    required AddCategory addCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
  }) : _getCategories = getCategories,
       _getCategory = getCategory,
       _addCategory = addCategory,
       _updateCategory = updateCategory,
       _deleteCategory = deleteCategory,
       super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadCategoryById>(_onLoadCategoryById);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  /// Handles loading categories with optional force refresh and sorting by updateTime (newest first)
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      final categories = await _getCategories(event.forceRefresh);
      // Sort categories by updatedAt descending (newest first)
      final sortedCategories = List<Category>.from(categories)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      emit(CategoryLoaded(sortedCategories));
    } catch (e) {
      emit(CategoryError('Unable to load category list: ${e.toString()}'));
    }
  }

  /// Handles loading a specific category by ID
  Future<void> _onLoadCategoryById(
    LoadCategoryById event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      final category = await _getCategory(event.categoryId);
      emit(CategoryDetailLoaded(category));
    } catch (e) {
      emit(
        CategoryError('Unable to load category information: ${e.toString()}'),
      );
    }
  }

  /// Handles adding a new category with optimistic UI updates
  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      // Optimistic UI update
      final currentState = state;
      if (currentState is CategoryLoaded) {
        final updatedCategories =
            List<Category>.from(currentState.categories)
              ..add(event.category)
              ..sort(
                (a, b) => b.updatedAt.compareTo(a.updatedAt),
              ); // Sort by updatedAt descending
        emit(CategoryLoaded(updatedCategories));
      }

      await _addCategory(event.category);
      emit(const CategoryOperationSuccess('Category added successfully'));
    } catch (e) {
      emit(CategoryError('Unable to add category: ${e.toString()}'));
      // Revert UI on failure
      add(const LoadCategories(forceRefresh: true));
    }
  }

  /// Handles updating an existing category with optimistic UI updates
  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      // Optimistic UI update
      final currentState = state;
      if (currentState is CategoryLoaded) {
        final updatedCategories =
            currentState.categories.map((c) {
                return c.id == event.category.id ? event.category : c;
              }).toList()
              ..sort(
                (a, b) => b.updatedAt.compareTo(a.updatedAt),
              ); // Sort by updatedAt descending
        emit(CategoryLoaded(updatedCategories));
      }

      await _updateCategory(event.category);
      emit(const CategoryOperationSuccess('Category updated successfully'));
    } catch (e) {
      emit(CategoryError('Unable to update category: ${e.toString()}'));
      // Revert UI on failure
      add(const LoadCategories(forceRefresh: true));
    }
  }

  /// Handles deleting a category with optimistic UI updates and loading states
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
        await _deleteCategory(event.categoryId);

        // Remove the deleted category from the list directly
        final updatedCategories =
            List<Category>.from(currentState.categories)
              ..removeWhere((category) => category.id == event.categoryId)
              ..sort(
                (a, b) => b.updatedAt.compareTo(a.updatedAt),
              ); // Sort by updatedAt descending

        final updatedDeletingIds = Set<String>.from(
          currentState.deletingCategoryIds,
        )..remove(event.categoryId.toString());

        emit(
          currentState.copyWith(
            categories: updatedCategories,
            deletingCategoryIds: updatedDeletingIds,
          ),
        );
      } catch (e) {
        emit(CategoryError('Unable to delete category: ${e.toString()}'));
        // Revert the loading state on failure
        final revertedIds = Set<String>.from(currentState.deletingCategoryIds);
        revertedIds.remove(event.categoryId.toString());
        emit(currentState.copyWith(deletingCategoryIds: revertedIds));
      }
    }
  }
}
