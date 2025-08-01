import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import 'components/category_filter.dart';
import 'components/product_search_bar.dart';
import 'components/product_states.dart';
import 'components/product_views.dart';
import 'components/view_toggle.dart';
import '../../domain/entities/product.dart';

class ProductListWidget extends StatefulWidget {
  const ProductListWidget({super.key});

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Tất cả',
    'Điện tử',
    'Thời trang',
    'Gia dụng',
    'Sách',
  ];
  String _selectedCategory = 'Tất cả';
  bool _isGridView = true;
  List<Product> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductLoaded) {
          setState(() {
            _allProducts = state.products;
            _applyFilters();
          });
        }
      },
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
    switch (categoryId) {
      case 1:
        return 'Điện tử';
      case 2:
        return 'Thời trang';
      case 3:
        return 'Gia dụng';
      case 4:
        return 'Sách';
      default:
        return 'Khác';
    }
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
      'image': product.images,
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
    // TODO: Navigate to product detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xem chi tiết: ${product['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
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
