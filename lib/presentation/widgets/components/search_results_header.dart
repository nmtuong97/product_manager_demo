import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Header component showing search results information
class SearchResultsHeader extends StatelessWidget {
  final String searchQuery;
  final int resultCount;
  final String selectedCategory;
  final VoidCallback? onClearSearch;

  const SearchResultsHeader({
    super.key,
    required this.searchQuery,
    required this.resultCount,
    required this.selectedCategory,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16.w, color: Theme.of(context).primaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                children: [
                  const TextSpan(text: 'Tìm thấy '),
                  TextSpan(
                    text: '$resultCount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const TextSpan(text: ' sản phẩm cho "'),
                  TextSpan(
                    text: searchQuery,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const TextSpan(text: '"'),
                  if (selectedCategory != 'Tất cả') ...[
                    const TextSpan(text: ' trong danh mục "'),
                    TextSpan(
                      text: selectedCategory,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const TextSpan(text: '"'),
                  ],
                ],
              ),
            ),
          ),
          if (onClearSearch != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onClearSearch,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(Icons.close, size: 14.w, color: Colors.grey[600]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
