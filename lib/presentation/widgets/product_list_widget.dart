import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import 'components/category_filter.dart';
import 'components/product_search_bar.dart';
import 'components/product_states.dart';
import 'components/product_views.dart';
import 'components/view_toggle.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import 'package:product_manager_demo/presentation/pages/product/product_detail_page.dart';

class ProductListWidget extends StatefulWidget {
  const ProductListWidget({super.key});

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  final TextEditingController _searchController = TextEditingController();

  List<String> _categories = ['Tất cả'];
  List<Category> _categoryEntities = [];
  String _selectedCategory = 'Tất cả';
  bool _isGridView = true;
  List<Product> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductLoaded) {
              setState(() {
                _allProducts = state.products;
                _applyFilters();
              });
            } else if (state is ProductOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryLoaded) {
              _updateCategoriesFromState(state.categories);
            }
          },
        ),
      ],
      child: Expanded(
        child: Column(
          children: [
            // Search bar
            ProductSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _onSearchCleared,
              hintText: 'Tìm kiếm sản phẩm...',
            ),
            SizedBox(height: 16.h),

            // Category filter
            CategoryFilter(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            SizedBox(height: 16.h),

            // View toggle
            ViewToggle(
              productCount: _filteredProducts.length,
              isGridView: _isGridView,
              onViewChanged: _onViewChanged,
            ),
            SizedBox(height: 16.h),

            // Product content
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  return _buildProductContent(state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Business logic methods
  void _loadProducts() {
    context.read<ProductBloc>().add(LoadProducts());
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  void _applyFilters() {
    var filteredProducts = _allProducts;

    // Filter by category
    if (_selectedCategory != 'Tất cả') {
      filteredProducts =
          filteredProducts.where((product) {
            final categoryName = _getCategoryName(product.categoryId);
            return categoryName == _selectedCategory;
          }).toList();
    }

    // Filter by search query
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filteredProducts =
          filteredProducts.where((product) {
            return product.name.toLowerCase().contains(searchQuery);
          }).toList();
    }

    // Convert to Map format for UI compatibility
    _filteredProducts =
        filteredProducts
            .map((product) => _convertProductToMap(product))
            .toList();
  }

  /// Get category name by ID
  String _getCategoryName(int categoryId) {
    final category = _categoryEntities.firstWhere(
      (cat) => cat.id == categoryId,
      orElse:
          () => Category(
            id: null,
            name: 'Khác',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );
    return category.name;
  }

  /// Update categories list from CategoryBloc state
  void _updateCategoriesFromState(List<Category> categories) {
    setState(() {
      _categoryEntities = categories;
      _categories = ['Tất cả', ...categories.map((cat) => cat.name).toList()];

      // Reset selected category if it no longer exists
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = 'Tất cả';
        _applyFilters();
      }
    });
  }

  /// Convert Product entity to Map for UI compatibility
  Map<String, dynamic> _convertProductToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.quantity,
      'category': _getCategoryName(product.categoryId),
      'image': product.thumbnail, // Use thumbnail (first image)
      'images': product.limitedImages, // Full image list (max 5)
      'createdAt': product.createdAt,
      'updatedAt': product.updatedAt,
    };
  }

  // Event handlers
  void _onSearchChanged(String value) {
    setState(() {
      _applyFilters();
    });
  }

  void _onSearchCleared() {
    setState(() {
      _applyFilters();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _onViewChanged(bool isGridView) {
    setState(() {
      _isGridView = isGridView;
    });
  }

  // Navigation methods
  void _onProductTap(Map<String, dynamic> product) {
    // Find the actual Product entity from the product map
    final productEntity = _allProducts.firstWhere(
      (p) => p.id == product['id'],
      orElse: () => throw Exception('Product not found'),
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: productEntity),
          ),
        )
        .then((result) {
          if (result == true) {
            // Product was updated or deleted, refresh the list
            _loadProducts();
          }
        });
  }

  Widget _buildProductContent(ProductState state) {
    if (state is ProductLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'Có lỗi xảy ra khi tải dữ liệu',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              state.message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const ProductEmptyState();
    }

    return _isGridView
        ? ProductGridView(
          products: _filteredProducts,
          onProductTap: _onProductTap,
        )
        : ProductListView(
          products: _filteredProducts,
          onProductTap: _onProductTap,
        );
  }
}
