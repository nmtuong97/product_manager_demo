import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'product_card.dart';

/// Grid view component for displaying products
class ProductGridView extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>) onProductTap;
  final Future<void> Function()? onRefresh;

  const ProductGridView({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive aspect ratio based on screen size
    final screenWidth = 1.sw;
    final aspectRatio = screenWidth > 600 ? 0.8 : 0.75;

    final gridView = GridView.builder(
      padding: EdgeInsets.only(bottom: 80.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: aspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onTap: () => onProductTap(products[index]),
          isGridView: true,
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: gridView);
    }

    return gridView;
  }
}

/// List view component for displaying products
class ProductListView extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>) onProductTap;
  final Future<void> Function()? onRefresh;

  const ProductListView({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final listView = ListView.builder(
      padding: EdgeInsets.only(bottom: 80.h),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onTap: () => onProductTap(products[index]),
          isGridView: false,
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: listView);
    }

    return listView;
  }
}
