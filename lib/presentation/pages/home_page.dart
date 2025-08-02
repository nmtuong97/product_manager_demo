import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/product_template_generator.dart';
import '../../domain/entities/product.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../services/image_url_generator.dart';
import '../widgets/product_list_widget.dart';
import 'category/category_list_page.dart';
import 'product/product_management_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGeneratingProducts = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductAdding && _isGeneratingProducts) {
          // Hiển thị thông báo đang tạo sản phẩm
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Đang tạo 10 sản phẩm ngẫu nhiên...'),
                ],
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is ProductOperationSuccess && _isGeneratingProducts) {
          setState(() {
            _isGeneratingProducts = false;
          });
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 16),
                  Text('Đã tạo thành công 10 sản phẩm ngẫu nhiên!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is ProductError && _isGeneratingProducts) {
          setState(() {
            _isGeneratingProducts = false;
          });
          // Hiển thị thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Lỗi khi tạo sản phẩm: ${state.message}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Danh sách sản phẩm',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _navigateToCategories(context),
              icon: const Icon(
                Icons.category,
                color: Colors.white,
              ),
              tooltip: 'Quản lý danh mục',
            ),
            IconButton(
              onPressed: _isGeneratingProducts ? null : () => _generateRandomProducts(context),
              icon: _isGeneratingProducts
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.shuffle,
                      color: Colors.white,
                    ),
              tooltip: _isGeneratingProducts 
                  ? 'Đang tạo sản phẩm...' 
                  : 'Tạo 10 sản phẩm ngẫu nhiên',
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[50],
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: const Column(
              children: [
                ProductListWidget(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToProductManagement(context),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          tooltip: 'Thêm sản phẩm',
        ),
      ),
    );
  }



  void _navigateToCategories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategoryListPage(),
      ),
    );
  }

  void _navigateToProductManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductManagementPage(),
      ),
    );
  }

  void _generateRandomProducts(BuildContext context) {
    // Kiểm tra nếu đang tạo sản phẩm thì không cho phép tạo thêm
    if (_isGeneratingProducts) return;
    
    setState(() {
      _isGeneratingProducts = true;
    });
    
    final random = Random();
    final now = DateTime.now().toIso8601String();
    
    // Tạo danh sách 10 sản phẩm ngẫu nhiên sử dụng ProductTemplateGenerator
    final List<Product> newProducts = [];
    
    for (int i = 0; i < 10; i++) {
      final categoryIds = ProductTemplateGenerator.availableCategoryIds;
      final randomCategoryId = categoryIds[random.nextInt(categoryIds.length)];
      final templates = ProductTemplateGenerator.getTemplatesForCategory(randomCategoryId);
      final template = templates[random.nextInt(templates.length)];
      
      final productName = '${template['name']} ${random.nextInt(1000) + 1}';
      final product = Product(
        id: null,
        name: productName,
        description: template['desc']!,
        price: (random.nextInt(10000) + 100) * 1000.0, // 100k - 10M
        quantity: random.nextInt(100) + 1, // 1-100
        categoryId: randomCategoryId,
        images: ImageUrlGenerator.generateImageListForProduct(productName, count: random.nextInt(3) + 1),
        createdAt: now,
        updatedAt: now,
      );
      
      newProducts.add(product);
    }
    
    // Thêm tất cả sản phẩm cùng lúc bằng batch operation
    context.read<ProductBloc>().add(AddMultipleProductsEvent(newProducts));
  }
}
