import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            onPressed: () => _navigateToProductManagement(context),
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            tooltip: 'Quản lý sản phẩm',
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
}
