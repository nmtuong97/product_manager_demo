import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable product card component that can display in grid or list format
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isGridView;
  final bool isDeleting;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onDelete,
    this.isGridView = true,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridCard(context) : _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Stack(
        children: [
          InkWell(
            onTap: isDeleting ? null : onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildProductImage(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
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
          // Delete button
          if (onDelete != null)
            Positioned(
              top: 8.w,
              right: 8.w,
              child: _buildDeleteButton(context),
            ),
          // Loading overlay
          if (isDeleting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Stack(
        children: [
          InkWell(
            onTap: isDeleting ? null : onTap,
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
                  Expanded(child: _buildProductInfo(context, isCompact: false)),
                  if (onDelete != null) ...[
                    _buildDeleteButton(context),
                    SizedBox(width: 8.w),
                  ],
                  if (!isDeleting)
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 20.w),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (isDeleting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
      child:
          product['image'] != null
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            product['name'] ?? 'Tên sản phẩm',
            style: TextStyle(
              fontSize: isCompact ? 14.sp : 16.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${_formatPrice(product['price'] ?? 0)}đ',
          style: TextStyle(
            fontSize: isCompact ? 16.sp : 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          'Tồn kho: ${product['stock'] ?? 0}',
          style: TextStyle(
            fontSize: isCompact ? 12.sp : 14.sp,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 24.w),
    );
  }

  String _formatPrice(num price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Builds the delete button with proper styling
  Widget _buildDeleteButton(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDeleting ? null : onDelete,
          borderRadius: BorderRadius.circular(16.r),
          child: Icon(
            Icons.delete_outline,
            size: 16.w,
            color: isDeleting
                ? Theme.of(context).colorScheme.error.withOpacity(0.5)
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
