import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../services/image_url_generator.dart';
import '../widgets/product_list_widget.dart';
import 'category/category_list_page.dart';
import 'product/product_management_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () => _generateRandomProducts(context),
            icon: const Icon(
              Icons.shuffle,
              color: Colors.white,
            ),
            tooltip: 'Tạo 10 sản phẩm ngẫu nhiên',
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
    final random = Random();
    final now = DateTime.now().toIso8601String();
    
    // Danh sách mẫu sản phẩm theo từng category
    final productTemplates = {
      1: [ // Điện tử
        {'name': 'Smartphone', 'desc': 'Điện thoại thông minh cao cấp'},
        {'name': 'Laptop', 'desc': 'Máy tính xách tay hiệu năng cao'},
        {'name': 'Tai nghe', 'desc': 'Tai nghe không dây chất lượng'},
        {'name': 'Máy tính bảng', 'desc': 'Tablet đa năng cho công việc'},
      ],
      2: [ // Sách
        {'name': 'Sách lập trình', 'desc': 'Hướng dẫn lập trình từ cơ bản đến nâng cao'},
        {'name': 'Tiểu thuyết', 'desc': 'Tác phẩm văn học hay nhất'},
        {'name': 'Sách kinh doanh', 'desc': 'Chiến lược kinh doanh hiệu quả'},
        {'name': 'Sách thiếu nhi', 'desc': 'Truyện tranh và sách giáo dục cho trẻ'},
      ],
      3: [ // Thời trang
        {'name': 'Áo thun', 'desc': 'Áo thun cotton cao cấp'},
        {'name': 'Quần jeans', 'desc': 'Quần jeans thời trang'},
        {'name': 'Giày sneaker', 'desc': 'Giày thể thao phong cách'},
        {'name': 'Túi xách', 'desc': 'Túi xách thời trang nữ'},
      ],
      4: [ // Gia dụng
        {'name': 'Nồi cơm điện', 'desc': 'Nồi cơm điện thông minh'},
        {'name': 'Máy xay sinh tố', 'desc': 'Máy xay đa năng cho gia đình'},
        {'name': 'Bộ chén đĩa', 'desc': 'Bộ chén đĩa sứ cao cấp'},
        {'name': 'Máy hút bụi', 'desc': 'Máy hút bụi không dây tiện lợi'},
      ],
    };
    
    // Tạo 10 sản phẩm ngẫu nhiên
    for (int i = 0; i < 10; i++) {
      final categoryIds = productTemplates.keys.toList();
      final randomCategoryId = categoryIds[random.nextInt(categoryIds.length)];
      final templates = productTemplates[randomCategoryId]!;
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
      
      context.read<ProductBloc>().add(AddProductEvent(product));
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã tạo 10 sản phẩm ngẫu nhiên!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
