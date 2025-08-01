import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Loading state component for product list
class ProductLoadingState extends StatelessWidget {
  const ProductLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state component for product list
class ProductEmptyState extends StatelessWidget {
  final VoidCallback? onAddProduct;
  final Future<void> Function()? onRefresh;

  const ProductEmptyState({
    super.key,
    this.onAddProduct,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Chưa có sản phẩm nào',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Hãy thêm sản phẩm đầu tiên của bạn',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[500],
              ),
            ),
            if (onAddProduct != null) ...[
              SizedBox(height: 24.h),
              _buildAddProductButton(),
            ],
          ],
        ),
      ),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildAddProductButton() {
    return ElevatedButton.icon(
      onPressed: onAddProduct,
      icon: const Icon(Icons.add),
      label: const Text('Thêm sản phẩm'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}