import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A toggle component for switching between grid and list view
class ViewToggle extends StatelessWidget {
  final int productCount;
  final bool isGridView;
  final ValueChanged<bool> onViewChanged;

  const ViewToggle({
    super.key,
    required this.productCount,
    required this.isGridView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Products ($productCount)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => onViewChanged(true),
              icon: Icon(
                Icons.grid_view,
                color:
                    isGridView
                        ? Theme.of(context).primaryColor
                        : Colors.grey[500],
                size: 20.w,
              ),
            ),
            IconButton(
              onPressed: () => onViewChanged(false),
              icon: Icon(
                Icons.list,
                color:
                    !isGridView
                        ? Theme.of(context).primaryColor
                        : Colors.grey[500],
                size: 20.w,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
