import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/product.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../../widgets/components/product_image_gallery.dart';
import 'product_management_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _currentProduct;
  String? _categoryName;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _loadCategoryName();
  }

  void _loadCategoryName() {
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      final category =
          categoryState.categories
              .where((cat) => cat.id == _currentProduct.categoryId)
              .firstOrNull;
      if (category != null) {
        setState(() {
          _categoryName = category.name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductOperationSuccess && _isDeleting) {
          // Only handle ProductOperationSuccess when deleting
          // Update operations are handled by ProductManagementPage
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is ProductDetailLoaded) {
          // Update current product when detail is reloaded
          setState(() {
            _currentProduct = state.product;
          });
          _loadCategoryName();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sản phẩm đã được cập nhật'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProductError) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildProductContent()),
          ],
        ),
        bottomNavigationBar: _buildBottomActionBar(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 20.w),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      flexibleSpace: FlexibleSpaceBar(background: _buildImageGallery()),
    );
  }

  Widget _buildImageGallery() {
    if (_currentProduct.images.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64.w,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return ProductImageGallery(
      images: _currentProduct.images,
      heroTag: 'product_${_currentProduct.id}',
    );
  }

  Widget _buildProductContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(),
            SizedBox(height: 24.h),
            _buildProductInfo(),
            SizedBox(height: 24.h),
            _buildProductDescription(),
            SizedBox(height: 100.h),
            // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          _currentProduct.name,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        SizedBox(height: 8.h),

        // Category badge
        if (_categoryName != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _categoryName!,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

        SizedBox(height: 16.h),

        // Price
        Text(
          NumberFormat.currency(
            locale: 'vi_VN',
            symbol: '₫',
          ).format(_currentProduct.price),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.inventory_2_outlined,
            label: 'Tồn kho',
            value: '${_currentProduct.quantity} sản phẩm',
            valueColor:
                _currentProduct.quantity > 0
                    ? Colors.green[600]
                    : Colors.red[600],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Cập nhật',
            value: _formatDate(_currentProduct.updatedAt),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.photo_library_outlined,
            label: 'Hình ảnh',
            value: '${_currentProduct.images.length} ảnh',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20.w, color: Colors.grey[600]),
        SizedBox(width: 12.w),
        Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả sản phẩm',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            _currentProduct.description,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDeleting ? null : _editProduct,
                    icon: Icon(Icons.edit_outlined, size: 18.w),
                    label: Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _deleteProduct,
                    icon:
                        _isDeleting
                            ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(Icons.delete_outline, size: 18.w),
                    label: Text(
                      _isDeleting ? 'Đang xóa...' : 'Xóa',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => ProductManagementPage(product: _currentProduct),
          ),
        )
        .then((result) {
          if (result == true) {
            // Product was updated, reload the current product data
            if (_currentProduct.id != null) {
              context.read<ProductBloc>().add(
                LoadProductById(_currentProduct.id!),
              );
            }
          }
        });
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa sản phẩm "${_currentProduct.name}"?\n\nHành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _performDelete() {
    if (_currentProduct.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa sản phẩm: ID không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    context.read<ProductBloc>().add(DeleteProductEvent(_currentProduct.id!));
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }
}
