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
  final String? searchQuery;
  final String? selectedCategory;
  final VoidCallback? onClearSearch;

  const ProductEmptyState({
    super.key,
    this.onAddProduct,
    this.onRefresh,
    this.searchQuery,
    this.selectedCategory,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildEmptyIcon(),
              SizedBox(height: 16.h),
              Text(
                _getEmptyTitle(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                _getEmptySubtitle(),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: null,
              ),
              SizedBox(height: 24.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildEmptyIcon() {
    if (_isSearchResult()) {
      return Icon(
        Icons.search_off,
        size: 80.w,
        color: Colors.grey[400],
      );
    }
    return Icon(
      Icons.inventory_2_outlined,
      size: 80.w,
      color: Colors.grey[400],
    );
  }

  String _getEmptyTitle() {
    if (_isSearchResult()) {
      return 'Không tìm thấy sản phẩm';
    }
    return 'Chưa có sản phẩm nào';
  }

  String _getEmptySubtitle() {
    if (_isSearchResult()) {
      if (searchQuery?.isNotEmpty == true && selectedCategory != 'Tất cả') {
        return 'Không có sản phẩm nào phù hợp với "${searchQuery}" trong danh mục "${selectedCategory}"';
      } else if (searchQuery?.isNotEmpty == true) {
        return 'Không có sản phẩm nào phù hợp với "${searchQuery}"';
      } else if (selectedCategory != 'Tất cả') {
        return 'Không có sản phẩm nào trong danh mục "${selectedCategory}"';
      }
      return 'Thử tìm kiếm với từ khóa khác';
    }
    return 'Hãy thêm sản phẩm đầu tiên của bạn';
  }

  bool _isSearchResult() {
    return (searchQuery?.isNotEmpty == true) || (selectedCategory != null && selectedCategory != 'Tất cả');
  }

  Widget _buildActionButtons() {
    if (_isSearchResult()) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Xóa bộ lọc'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          if (onAddProduct != null) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddProduct,
                icon: const Icon(Icons.add),
                label: const Text('Thêm sản phẩm mới'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    if (onAddProduct != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onAddProduct,
          icon: const Icon(Icons.add),
          label: const Text('Thêm sản phẩm'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}