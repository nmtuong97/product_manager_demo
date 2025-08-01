import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable product card component that can display in grid or list format
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final bool isGridView;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridCard(context) : _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildProductImage(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: _buildProductInfo(context, isCompact: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              SizedBox(
                width: 60.w,
                height: 60.w,
                child: _buildProductImage(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildProductInfo(context, isCompact: false),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage({required BorderRadius borderRadius}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: product['image'] != null
          ? ClipRRect(
              borderRadius: borderRadius,
              child: Image.network(
                product['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              ),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildProductInfo(BuildContext context, {required bool isCompact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['name'] ?? 'Tên sản phẩm',
          style: TextStyle(
            fontSize: isCompact ? 14.sp : 16.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          '${_formatPrice(product['price'] ?? 0)}đ',
          style: TextStyle(
            fontSize: isCompact ? 16.sp : 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Tồn kho: ${product['stock'] ?? 0}',
          style: TextStyle(
            fontSize: isCompact ? 12.sp : 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey[400],
        size: 24.w,
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}