import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/product_template_generator.dart';
import '../../domain/entities/product.dart';
import '../blocs/product/index.dart';
import '../../domain/services/image_url_generator.dart';
import '../widgets/index.dart';
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
          // Show creating products notification
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
                  Text('Creating 10 random products...'),
                ],
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is ProductOperationSuccess && _isGeneratingProducts) {
          setState(() {
            _isGeneratingProducts = false;
          });
          // Show success notification
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 16),
                  Text('Successfully created 10 random products!'),
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
          // Show error notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Error creating products: ${state.message}'),
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
            'Product List',
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
              icon: const Icon(Icons.category, color: Colors.white),
              tooltip: 'Manage Categories',
            ),
            IconButton(
              onPressed:
                  _isGeneratingProducts
                      ? null
                      : () => _generateRandomProducts(context),
              icon:
                  _isGeneratingProducts
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.shuffle, color: Colors.white),
              tooltip:
                  _isGeneratingProducts
                      ? 'Creating products...'
                      : 'Generate 10 random products',
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[50],
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: const Column(children: [ProductListWidget()]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToProductManagement(context),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Add Product',
        ),
      ),
    );
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CategoryListPage()));
  }

  void _navigateToProductManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProductManagementPage()),
    );
  }

  void _generateRandomProducts(BuildContext context) {
    // Check if products are being created, don't allow creating more
    if (_isGeneratingProducts) return;

    setState(() {
      _isGeneratingProducts = true;
    });

    final random = Random();
    final now = DateTime.now();

    // Create list of 10 random products using ProductTemplateGenerator
    final List<Product> newProducts = [];

    for (int i = 0; i < 10; i++) {
      final categoryIds = ProductTemplateGenerator.availableCategoryIds;
      final randomCategoryId = categoryIds[random.nextInt(categoryIds.length)];
      final templates = ProductTemplateGenerator.getTemplatesForCategory(
        randomCategoryId,
      );
      final template = templates[random.nextInt(templates.length)];

      final productName = '${template['name']} ${random.nextInt(1000) + 1}';
      final product = Product(
        name: productName,
        description: template['desc']!,
        price: (random.nextInt(10000) + 100) * 1000.0, // 100k - 10M
        quantity: random.nextInt(100) + 1, // 1-100
        categoryId: randomCategoryId,
        images: ImageUrlGenerator.generateImageListForProduct(
          productName,
          count: random.nextInt(3) + 1,
        ),
        createdAt: now,
        updatedAt: now,
      );

      newProducts.add(product);
    }

    // Add all products at once using batch operation
    context.read<ProductBloc>().add(AddMultipleProductsEvent(newProducts));
  }
}
