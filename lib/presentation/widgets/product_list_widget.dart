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
import 'components/search_results_header.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import 'package:product_manager_demo/presentation/pages/product/product_detail_page.dart';
import '../../core/utils/text_utils.dart';

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
  List<Map<String, dynamic>> _products = [];
  bool _isSearching = false;
  String _currentSearchQuery = '';
  int _currentResultCount = 0;
  bool _isNavigating = false;

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
                _products = state.products.map((product) => _convertProductToMap(product)).toList();
                _currentResultCount = state.products.length;
                // Apply current filters to the loaded products
                _applyCurrentFilters();
              });
            } else if (state is ProductSearchLoaded) {
              setState(() {
                _currentResultCount = state.searchResults.length;
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
        child: GestureDetector(
          onTap: () {
            // Clear focus when tapping outside search bar
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
            // Search bar
            ProductSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _onSearchCleared,
              hintText: 'Tìm kiếm sản phẩm...',
              isLoading: _isSearching,
              debounceDuration: const Duration(milliseconds: 300),
            ),
            SizedBox(height: 16.h),

            // Category filter
            CategoryFilter(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            SizedBox(height: 16.h),

            // Search results header
            SearchResultsHeader(
              searchQuery: _currentSearchQuery,
              resultCount: _currentResultCount,
              selectedCategory: _selectedCategory,
              onClearSearch: () {
                _searchController.clear();
                _onSearchCleared();
              },
            ),
            if (_currentSearchQuery.isNotEmpty) SizedBox(height: 12.h),

            // View toggle
            ViewToggle(
              productCount: _currentResultCount,
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

  void _performSearch() {
    final query = _currentSearchQuery.trim();
    
    if (query.isEmpty && _selectedCategory == 'Tất cả') {
      // Load all products when no search query and no category filter
      context.read<ProductBloc>().add(LoadProducts());
      return;
    }
    
    if (query.isNotEmpty) {
      // Get category ID for search
      int? categoryId;
      if (_selectedCategory != 'Tất cả') {
        categoryId = _getCategoryId(_selectedCategory);
      }
      
      // Perform API search
      context.read<ProductBloc>().add(SearchProductsEvent(query, categoryId: categoryId));
    } else if (_selectedCategory != 'Tất cả') {
      // Load products by category only
      final categoryId = _getCategoryId(_selectedCategory);
      if (categoryId != null) {
        context.read<ProductBloc>().add(LoadProductsByCategory(categoryId));
      }
    }
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

  /// Get category ID by name
  int? _getCategoryId(String categoryName) {
    if (categoryName == 'Tất cả') return null;
    
    try {
      final category = _categoryEntities.firstWhere(
        (cat) => cat.name == categoryName,
      );
      return category.id;
    } catch (e) {
      return null;
    }
  }

  /// Update categories list from CategoryBloc state
  void _updateCategoriesFromState(List<Category> categories) {
    setState(() {
      _categoryEntities = categories;
      _categories = ['Tất cả', ...categories.map((cat) => cat.name).toList()];

      // Reset selected category if it no longer exists
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = 'Tất cả';
        _performSearch();
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

  /// Apply current search and category filters to loaded products without dispatching events
  void _applyCurrentFilters() {
    final query = _currentSearchQuery.trim();
    
    List<Map<String, dynamic>> filtered = _products;
    
    // Apply search filter with Vietnamese diacritic support
    if (query.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = product['name']?.toString() ?? '';
        final description = product['description']?.toString() ?? '';
        return TextUtils.matchesSearch(name, query) || 
               TextUtils.matchesSearch(description, query);
      }).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != 'Tất cả') {
      filtered = filtered.where((product) {
        return product['category'] == _selectedCategory;
      }).toList();
    }
    
    _filteredProducts = filtered;
    _currentResultCount = filtered.length;
  }

  // Event handlers
  void _onSearchChanged(String value) {
    setState(() {
      _currentSearchQuery = value;
    });
    _performSearch();
  }

  void _onSearchCleared() {
    setState(() {
      _currentSearchQuery = '';
    });
    _performSearch();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _performSearch();
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

    setState(() {
      _isNavigating = true;
    });

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: productEntity),
          ),
        )
        .then((result) {
          setState(() {
            _isNavigating = false;
          });
          
          // Clear focus when returning from detail page to prevent keyboard from showing
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              FocusScope.of(context).unfocus();
            }
          });
          
          if (result == true) {
            // Product was updated or deleted, refresh the list
            _loadProducts();
          }
        });
  }

  Widget _buildProductContent(ProductState state) {
    if (state is ProductLoading || state is ProductSearching) {
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

    // Xử lý trạng thái tìm kiếm
    if (state is ProductSearchLoaded) {
      final displayProducts = state.searchResults
          .map((product) => _convertProductToMap(product))
          .toList();
      
      if (displayProducts.isEmpty) {
        return ProductEmptyState(
          searchQuery: state.query,
          selectedCategory: _selectedCategory != 'Tất cả' ? _selectedCategory : null,
          onClearSearch: () {
            _searchController.clear();
            _onSearchCleared();
            if (_selectedCategory != 'Tất cả') {
              setState(() {
                _selectedCategory = 'Tất cả';
              });
              _performSearch();
            }
          },
        );
      }
      
      return _isGridView
          ? ProductGridView(
            products: displayProducts,
            onProductTap: _onProductTap,
          )
          : ProductListView(
            products: displayProducts,
            onProductTap: _onProductTap,
          );
    }

    // Hiển thị danh sách sản phẩm thông thường
    if (state is ProductLoaded) {
      _allProducts = state.products; // Update local cache
      final displayProducts = state.products
          .map((product) => _convertProductToMap(product))
          .toList();
      
      if (displayProducts.isEmpty) {
        return ProductEmptyState(
          searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
          selectedCategory: _selectedCategory != 'Tất cả' ? _selectedCategory : null,
          onClearSearch: () {
            _searchController.clear();
            _onSearchCleared();
            if (_selectedCategory != 'Tất cả') {
              setState(() {
                _selectedCategory = 'Tất cả';
              });
              _performSearch();
            }
          },
        );
      }
      
      return _isGridView
          ? ProductGridView(
            products: displayProducts,
            onProductTap: _onProductTap,
          )
          : ProductListView(
            products: displayProducts,
            onProductTap: _onProductTap,
          );
    }

    // Fallback cho các trạng thái khác
     final displayProducts = _filteredProducts.isEmpty ? _products : _filteredProducts;
     
     if (displayProducts.isEmpty) {
       return ProductEmptyState(
         searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
         selectedCategory: _selectedCategory != 'Tất cả' ? _selectedCategory : null,
         onClearSearch: () {
           _searchController.clear();
           _onSearchCleared();
           if (_selectedCategory != 'Tất cả') {
             setState(() {
               _selectedCategory = 'Tất cả';
             });
             _performSearch();
           }
         },
       );
     }

     return _isGridView
         ? ProductGridView(
           products: displayProducts,
           onProductTap: _onProductTap,
         )
         : ProductListView(
           products: displayProducts,
           onProductTap: _onProductTap,
         );
    }
}
