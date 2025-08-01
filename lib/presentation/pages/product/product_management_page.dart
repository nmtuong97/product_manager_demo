import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../../injection.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../../services/image_upload_service.dart';
import '../../services/image_url_generator.dart';

class ProductManagementPage extends StatefulWidget {
  final Product? product; // null for add, non-null for edit

  const ProductManagementPage({super.key, this.product});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  // Focus nodes for better UX
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();

  Category? _selectedCategory;
  List<Category> _categories = [];
  bool _isLoading = false;

  // Validation states for real-time feedback
  String? _nameError;
  String? _descriptionError;
  String? _priceError;
  String? _quantityError;
  String? _categoryError;

  // Image management
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isUploadingImages = false;
  final ImageUploadService _imageUploadService = getIt<ImageUploadService>();

  bool get _isEditMode => widget.product != null;

  bool get _isFormValid =>
      _nameError == null &&
      _descriptionError == null &&
      _priceError == null &&
      _quantityError == null &&
      _categoryError == null &&
      _nameController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _priceController.text.trim().isNotEmpty &&
      _quantityController.text.trim().isNotEmpty &&
      _selectedCategory != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeForm();
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  void _initializeForm() {
    if (_isEditMode && widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      // Format price with currency formatter
      final formatter = NumberFormat('#,###', 'en_US');
      _priceController.text = formatter.format(product.price.toInt());
      _quantityController.text = product.quantity.toString();
      // Initialize uploaded image URLs for edit mode
      _uploadedImageUrls = List.from(product.images);
    }
  }

  // Image selection methods
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Chọn nhiều ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickMultipleImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final File? image = await _imageUploadService.pickImageFromCamera();
      if (image != null && _selectedImages.length < 5) {
        setState(() {
          _selectedImages.add(image);
        });
      } else if (_selectedImages.length >= 5) {
        _showSnackBar('Chỉ có thể chọn tối đa 5 ảnh', isError: true);
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chụp ảnh: $e', isError: true);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final File? image = await _imageUploadService.pickImageFromGallery();
      if (image != null && _selectedImages.length < 5) {
        setState(() {
          _selectedImages.add(image);
        });
      } else if (_selectedImages.length >= 5) {
        _showSnackBar('Chỉ có thể chọn tối đa 5 ảnh', isError: true);
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chọn ảnh: $e', isError: true);
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<File> images = await _imageUploadService.pickMultipleImages();
      final int availableSlots = 5 - _selectedImages.length;
      
      if (images.isNotEmpty) {
        final List<File> imagesToAdd = images.take(availableSlots).toList();
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });
        
        if (images.length > availableSlots) {
          _showSnackBar('Chỉ thêm được ${imagesToAdd.length} ảnh. Tối đa 5 ảnh.', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chọn ảnh: $e', isError: true);
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeUploadedImage(int index) {
    setState(() {
      _uploadedImageUrls.removeAt(index);
    });
  }

  Future<void> _uploadImages(int productId) async {
    if (_selectedImages.isEmpty) return;
    
    setState(() {
      _isUploadingImages = true;
    });
    
    try {
      final List<String> uploadedUrls = await _imageUploadService.uploadProductImages(
        productId,
        _selectedImages,
      );
      
      setState(() {
        _uploadedImageUrls.addAll(uploadedUrls);
        _selectedImages.clear();
        _isUploadingImages = false;
      });
      
      _showSnackBar('Upload ảnh thành công!');
    } catch (e) {
      setState(() {
        _isUploadingImages = false;
      });
      _showSnackBar('Lỗi khi upload ảnh: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<void> _handlePostProductSuccess(ProductOperationSuccess state) async {
    // Upload images if there are selected images and we have a product ID
    if (_selectedImages.isNotEmpty && state.productId != null) {
      await _uploadImages(state.productId!);
    }
    
    // Show success message
    _showSnackBar(state.message, isError: false);
    
    // Navigate back with success result
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: Icon(
                Icons.auto_fix_high_rounded,
                color: colorScheme.primary,
              ),
              tooltip: 'Tạo dữ liệu mẫu',
              onPressed: _generateRandomProduct,
            ),
          SizedBox(width: 8.w),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: _buildActionButtons(),
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (state is CategoryLoaded) {
                setState(() {
                  _categories = state.categories;
                  if (_isEditMode && widget.product != null) {
                    _selectedCategory = _categories.firstWhere(
                      (cat) => cat.id == widget.product!.categoryId,
                      orElse:
                          () =>
                              _categories.isNotEmpty
                                  ? _categories.first
                                  : Category(
                                    id: 1,
                                    name: 'Mặc định',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                    );
                  }
                });
              } else if (state is CategoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductAdding || state is ProductUpdating) {
                setState(() {
                  _isLoading = true;
                });
              } else {
                setState(() {
                  _isLoading = false;
                });

                if (state is ProductOperationSuccess) {
                  // Handle image upload after successful product creation/update
                  _handlePostProductSuccess(state);
                } else if (state is ProductError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        if (categoryState is CategoryLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                SizedBox(height: 16.h),
                Text(
                  'Đang tải danh mục...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 100.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNameField(),
                SizedBox(height: 24.h),
                _buildDescriptionField(),
                SizedBox(height: 24.h),
                _buildPriceField(),
                SizedBox(height: 24.h),
                _buildQuantityField(),
                SizedBox(height: 24.h),
                _buildCategoryDropdown(),
                SizedBox(height: 24.h),
                _buildImageSection(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameField() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tên sản phẩm *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          decoration: InputDecoration(
            hintText: 'Nhập tên sản phẩm',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    _nameError != null
                        ? colorScheme.error
                        : colorScheme.outline.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    _nameError != null
                        ? colorScheme.error
                        : colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            prefixIcon: Icon(
              Icons.inventory_2_outlined,
              color:
                  _nameError != null
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
            errorText: _nameError,
            errorStyle: TextStyle(fontSize: 12.sp, color: colorScheme.error),
            counterText: '${_nameController.text.length}/100',
            counterStyle: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          maxLength: 100,
          textInputAction: TextInputAction.next,
          onChanged: _validateName,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_descriptionFocusNode);
          },
          style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  void _validateName(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _nameError = 'Tên sản phẩm là bắt buộc';
      } else if (value.trim().length > 100) {
        _nameError = 'Tên sản phẩm không được vượt quá 100 ký tự';
      } else {
        _nameError = null;
      }
    });
  }

  Widget _buildDescriptionField() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả sản phẩm *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          decoration: InputDecoration(
            hintText: 'Nhập mô tả chi tiết về sản phẩm',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    _descriptionError != null
                        ? colorScheme.error
                        : colorScheme.outline.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    _descriptionError != null
                        ? colorScheme.error
                        : colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Icon(
                Icons.description_outlined,
                color:
                    _descriptionError != null
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                size: 20.w,
              ),
            ),
            errorText: _descriptionError,
            errorStyle: TextStyle(fontSize: 12.sp, color: colorScheme.error),
            counterText: '${_descriptionController.text.length}/500',
            counterStyle: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          maxLines: 4,
          maxLength: 500,
          textInputAction: TextInputAction.next,
          onChanged: _validateDescription,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_priceFocusNode);
          },
          style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  void _validateDescription(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _descriptionError = 'Mô tả sản phẩm là bắt buộc';
      } else if (value.trim().length > 500) {
        _descriptionError = 'Mô tả không được vượt quá 500 ký tự';
      } else {
        _descriptionError = null;
      }
    });
  }

  Widget _buildPriceField() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giá bán *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _priceController,
          focusNode: _priceFocusNode,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    _priceError != null
                        ? colorScheme.error
                        : colorScheme.outline.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    _priceError != null
                        ? colorScheme.error
                        : colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            prefixIcon: Icon(
              Icons.attach_money_rounded,
              color:
                  _priceError != null
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
            suffixText: 'VNĐ',
            suffixStyle: TextStyle(
              fontSize: 14.sp,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            errorText: _priceError,
            errorStyle: TextStyle(fontSize: 12.sp, color: colorScheme.error),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CurrencyInputFormatter(),
          ],
          textInputAction: TextInputAction.next,
          onChanged: _validatePrice,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_quantityFocusNode);
          },
          style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  void _validatePrice(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _priceError = 'Giá sản phẩm là bắt buộc';
      } else {
        // Remove formatting to get raw number
        final String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
        final price = double.tryParse(digitsOnly);
        if (price == null || price <= 0) {
          _priceError = 'Giá phải là số dương';
        } else if (price % 1000 != 0) {
          _priceError = 'Giá phải là bội số của 1000';
        } else {
          _priceError = null;
        }
      }
    });
  }

  Widget _buildQuantityField() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tồn kho *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                focusNode: _quantityFocusNode,
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color:
                          _quantityError != null
                              ? colorScheme.error
                              : colorScheme.outline.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color:
                          _quantityError != null
                              ? colorScheme.error
                              : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  prefixIcon: Icon(
                    Icons.inventory_outlined,
                    color:
                        _quantityError != null
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                    size: 20.w,
                  ),
                  suffixText: 'cái',
                  suffixStyle: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  errorText: _quantityError,
                  errorStyle: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.error,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                onChanged: _validateQuantity,
                style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _validateQuantity(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _quantityError = 'Số lượng tồn kho là bắt buộc';
      } else {
        final quantity = int.tryParse(value);
        if (quantity == null || quantity < 0) {
          _quantityError = 'Tồn kho phải là số không âm';
        } else if (quantity > 10000) {
          _quantityError = 'Tồn kho không được vượt quá 10000';
        } else {
          _quantityError = null;
        }
      }
    });
  }

  Widget _buildCategoryDropdown() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục sản phẩm *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<Category>(
          value: _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Chọn danh mục',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    _categoryError != null
                        ? colorScheme.error
                        : colorScheme.outline.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    _categoryError != null
                        ? colorScheme.error
                        : colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            prefixIcon: Icon(
              Icons.category_outlined,
              color:
                  _categoryError != null
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
            errorText: _categoryError,
            errorStyle: TextStyle(fontSize: 12.sp, color: colorScheme.error),
          ),
          items:
              _categories.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (Category? value) {
            setState(() {
              _selectedCategory = value;
              _categoryError = value == null ? 'Vui lòng chọn danh mục' : null;
            });
          },
          style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
          dropdownColor: colorScheme.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hình ảnh sản phẩm',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        
        // Add image button
        if (_selectedImages.length + _uploadedImageUrls.length < 5)
          Container(
            width: double.infinity,
            height: 120.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.5),
                width: 1.5,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12.r),
              color: colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showImageSourceDialog,
                borderRadius: BorderRadius.circular(12.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32.w,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Thêm ảnh',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Tối đa 5 ảnh',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Selected images preview
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Text(
            'Ảnh đã chọn (${_selectedImages.length})',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 12.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100.w,
                          height: 100.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => _removeSelectedImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.w,
                              color: colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        
        // Uploaded images preview
        if (_uploadedImageUrls.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Text(
            'Ảnh đã upload (${_uploadedImageUrls.length})',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _uploadedImageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 12.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          _uploadedImageUrls[index],
                          width: 100.w,
                          height: 100.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100.w,
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.broken_image,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => _removeUploadedImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.w,
                              color: colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        
        // Upload progress
        if (_isUploadingImages) ...[
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Đang upload ảnh...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                side: BorderSide(color: colorScheme.outline, width: 1.5),
                foregroundColor: colorScheme.onSurface,
              ),
              child: Text(
                'Hủy',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (_isLoading || !_isFormValid) ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isFormValid
                        ? colorScheme.primary
                        : colorScheme.surfaceVariant,
                foregroundColor:
                    _isFormValid
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: _isFormValid ? 2 : 0,
                shadowColor: colorScheme.shadow.withOpacity(0.3),
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEditMode
                                ? Icons.update_rounded
                                : Icons.add_rounded,
                            size: 20.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _isEditMode ? 'Cập nhật' : 'Thêm mới',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
    );
  }

  void _generateRandomProduct() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final productNames = [
      'iPhone 15 Pro Max',
      'Samsung Galaxy S24',
      'MacBook Air M3',
      'iPad Pro 12.9',
      'AirPods Pro 2',
      'Apple Watch Series 9',
      'Dell XPS 13',
      'Sony WH-1000XM5',
      'Nintendo Switch OLED',
      'PlayStation 5',
      'Áo thun cotton',
      'Quần jeans slim fit',
      'Giày sneaker Nike',
      'Túi xách da thật',
      'Đồng hồ thông minh',
      'Máy ảnh Canon EOS',
      'Tai nghe gaming',
      'Bàn phím cơ RGB',
      'Chuột gaming wireless',
      'Màn hình 4K 27 inch',
    ];

    final descriptions = [
      'Sản phẩm chất lượng cao với thiết kế hiện đại và tính năng vượt trội',
      'Được làm từ chất liệu cao cấp, bền bỉ và thân thiện với môi trường',
      'Phù hợp cho mọi lứa tuổi với nhiều tính năng tiện ích',
      'Thiết kế sang trọng, phong cách và đầy tính thẩm mỹ',
      'Công nghệ tiên tiến mang lại trải nghiệm tuyệt vời cho người dùng',
      'Sản phẩm được ưa chuộng với độ bền cao và giá cả hợp lý',
      'Tính năng đa dạng, dễ sử dụng và phù hợp với xu hướng hiện đại',
      'Chất lượng đảm bảo với dịch vụ hậu mãi tốt',
    ];

    final nameIndex = random % productNames.length;
    final descIndex = random % descriptions.length;
    final price = ((random % 50) + 1) * 100000; // 100k - 5M
    final quantity = (random % 100) + 1; // 1-100

    _nameController.text = productNames[nameIndex];
    _descriptionController.text = descriptions[descIndex];
    _priceController.text = price.toString();
    _quantityController.text = quantity.toString();

    // Chọn category ngẫu nhiên nếu có
    if (_categories.isNotEmpty) {
      final categoryIndex = random % _categories.length;
      setState(() {
        _selectedCategory = _categories[categoryIndex];
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã tạo dữ liệu mẫu thành công!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSubmit() {
    // Validate all fields one more time
    _validateName(_nameController.text);
    _validateDescription(_descriptionController.text);
    _validatePrice(_priceController.text);
    _validateQuantity(_quantityController.text);

    if (_selectedCategory == null) {
      setState(() {
        _categoryError = 'Vui lòng chọn danh mục';
      });
    }

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng kiểm tra lại thông tin đã nhập'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();
    
    // Use uploaded images or generate default ones
    List<String> finalImages = [];
    if (_uploadedImageUrls.isNotEmpty) {
      finalImages = List.from(_uploadedImageUrls);
    } else if (_isEditMode && widget.product != null) {
      finalImages = List.from(widget.product!.images);
    } else {
      // Generate default images for new products without uploaded images
      finalImages = ImageUrlGenerator.generateImageListForProduct(
        _nameController.text.trim(),
        count: 3,
      );
    }

    // Parse price from formatted string
    final String priceDigitsOnly = _priceController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final product = Product(
      id: _isEditMode ? widget.product!.id : null,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(priceDigitsOnly),
      quantity: int.parse(_quantityController.text),
      categoryId: _selectedCategory!.id!,
      images: finalImages,
      createdAt:
          _isEditMode ? widget.product!.createdAt : now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );

    if (_isEditMode) {
      context.read<ProductBloc>().add(UpdateProductEvent(product));
    } else {
      context.read<ProductBloc>().add(AddProductEvent(product));
    }
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Parse the number and format it
    final int value = int.parse(digitsOnly);
    final String formatted = _formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
