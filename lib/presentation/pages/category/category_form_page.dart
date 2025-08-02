import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/category.dart';
import '../../blocs/category/category_barrel.dart';

/// Form page for adding or editing categories
///
/// This page provides a form interface for creating new categories
/// or editing existing ones. It handles validation, submission,
/// and provides feedback to the user.
class CategoryFormPage extends StatefulWidget {
  /// The category to edit, null if creating a new category
  final Category? category;

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  /// Whether this form is in edit mode (true) or create mode (false)
  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    // Pre-populate form fields if editing an existing category
    if (_isEditing) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        setState(() {
          _isLoading = state is CategoryLoading;
        });

        if (state is CategoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: () => _submitForm(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isEditing ? 'Chỉnh sửa danh mục' : 'Thêm danh mục',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              if (_isEditing)
                IconButton(
                  icon:
                      _isLoading
                          ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                          : const Icon(Icons.delete),
                  onPressed: _isLoading ? null : () => _showDeleteDialog(),
                  tooltip: 'Xóa danh mục',
                ),
            ],
          ),
          body: _buildForm(context),
        );
      },
    );
  }

  /// Shows a confirmation dialog before deleting a category
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
              SizedBox(width: 8.w),
              const Text('Xác nhận xóa'),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa danh mục "${widget.category!.name}"? Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CategoryBloc>().add(
                  DeleteCategoryEvent(widget.category!.id!),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  /// Builds the main form widget
  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Thông tin danh mục',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildNameField(),
                          if (_isEditing) ...[
                            SizedBox(height: 16.h),
                            _buildInfoSection(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          child: _buildActionButtons(context),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Tên danh mục *',
        hintText: 'Nhập tên danh mục',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tên danh mục';
        }
        if (value.trim().length < 2) {
          return 'Tên danh mục phải có ít nhất 2 ký tự';
        }
        if (value.trim().length > 50) {
          return 'Tên danh mục không được quá 50 ký tự';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
    );
  }

  /// Builds the information section for editing mode
  Widget _buildInfoSection() {
    final category = widget.category!;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Thông tin bổ sung',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow('ID', category.id?.toString() ?? 'Chưa có'),
          _buildInfoRow('Ngày tạo', _formatDateTime(category.createdAt)),
          _buildInfoRow('Ngày cập nhật', _formatDateTime(category.updatedAt)),
        ],
      ),
    );
  }

  /// Builds a row for displaying category information
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action buttons (Cancel and Submit)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Hủy',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _submitForm(),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child:
                _isLoading
                    ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                    : Text(
                      _isEditing ? 'Cập nhật' : 'Thêm',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  /// Submits the form after validation
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final now = DateTime.now();

    final category = Category(
      id: _isEditing ? widget.category!.id : null,
      name: name,
      createdAt: _isEditing ? widget.category!.createdAt : now,
      updatedAt: now,
    );

    if (_isEditing) {
      context.read<CategoryBloc>().add(UpdateCategoryEvent(category));
    } else {
      context.read<CategoryBloc>().add(AddCategoryEvent(category));
    }
  }

  /// Formats a datetime for display
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Chưa có';
    }

    try {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Chưa có';
    }
  }
}
