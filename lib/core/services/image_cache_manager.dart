import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom cache manager for product images with optimized settings
class ProductImageCacheManager {
  static const String _cacheKey = 'product_images';

  static final CacheManager _cacheManager = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 7), // Cache for 7 days
      maxNrOfCacheObjects: 200, // Maximum 200 cached images
      repo: JsonCacheInfoRepository(databaseName: _cacheKey),
      fileService: HttpFileService(),
    ),
  );

  /// Get the cache manager instance
  static CacheManager get instance => _cacheManager;

  /// Clear all cached images
  static Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  /// Get cache size in bytes
  static Future<int> getCacheSize() async {
    try {
      // For simplicity, return 0 as cache size calculation requires more complex implementation
      // In production, you might want to implement a more sophisticated cache size calculation
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Format cache size to human readable string
  static String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Reusable cached network image widget with consistent styling
class CachedProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? heroTag;

  const CachedProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: ProductImageCacheManager.instance,
      fit: fit,
      width: width,
      height: height,
      placeholder:
          placeholder != null
              ? (context, url) => placeholder!
              : (context, url) => _buildDefaultPlaceholder(context, url),
      errorWidget:
          (context, url, error) => errorWidget ?? _buildDefaultErrorWidget(),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    if (heroTag != null) {
      imageWidget = Hero(tag: heroTag!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder(BuildContext context, String url) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48.w, color: Colors.grey[400]),
            SizedBox(height: 8.h),
            Text(
              'Image loading error',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for easy access to cached product image
extension CachedProductImageExtension on String {
  /// Create a cached product image widget from image URL
  Widget toCachedProductImage({
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    String? heroTag,
  }) {
    return CachedProductImage(
      imageUrl: this,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      heroTag: heroTag,
    );
  }
}
