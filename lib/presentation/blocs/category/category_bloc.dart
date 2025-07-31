import 'package:flutter_bloc/flutter_bloc.dart';
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
      final categories = await getCategories();
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
    try {
      emit(CategoryLoading());
      await addCategory(event.category);
      emit(CategoryOperationSuccess('Thêm danh mục thành công'));
      // Reload categories after adding
      final categories = await getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Không thể thêm danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      await updateCategory(event.category);
      emit(CategoryOperationSuccess('Cập nhật danh mục thành công'));
      // Reload categories after updating
      final categories = await getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Không thể cập nhật danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      await deleteCategory(event.categoryId);
      emit(CategoryOperationSuccess('Xóa danh mục thành công'));
      // Reload categories after deleting
      final categories = await getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Không thể xóa danh mục: ${e.toString()}'));
    }
  }
}
