import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../pages/product/product_management_page.dart';
import '../services/product_list_service.dart';
import 'components/category_filter.dart';
import 'components/product_search_bar.dart';
import 'components/product_states.dart';
import 'components/product_views.dart';
import 'components/view_toggle.dart';

class ProductListWidget extends StatefulWidget {
  const ProductListWidget({super.key});

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ProductListService _productListService = ProductListService();
  
  late List<String> _categories;
  String _selectedCategory = 'Tất cả';
  bool _isLoading = false;
  bool _isGridView = true;
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _categories = _productListService.getCategories();
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
    return Expanded(
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
            child: _buildProductContent(),
          ),
        ],
      ),
    );
  }

  // Business logic methods
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      _allProducts = await _productListService.loadProducts();
      _applyFilters();
    } catch (e) {
      // Handle error
      debugPrint('Error loading products: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _applyFilters() {
    _filteredProducts = _productListService.applyFilters(
      _allProducts,
      _searchController.text,
      _selectedCategory,
    );
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

  void _onProductTap(Map<String, dynamic> product) {
    // TODO: Navigate to product detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xem chi tiết: ${product['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  Future<void> _onRefresh() async {
    await _loadProducts();
  }
  
  void _navigateToProductManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductManagementPage(),
      ),
    );
  }

  Widget _buildProductContent() {
    if (_isLoading) {
      return const ProductLoadingState();
    }
    
    if (_filteredProducts.isEmpty) {
      return ProductEmptyState(
        onAddProduct: _navigateToProductManagement,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _isGridView 
          ? ProductGridView(
              products: _filteredProducts,
              onProductTap: _onProductTap,
            )
          : ProductListView(
              products: _filteredProducts,
              onProductTap: _onProductTap,
            ),
    );
  }




}