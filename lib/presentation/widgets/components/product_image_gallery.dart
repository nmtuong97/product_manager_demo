import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/image_cache_manager.dart';

class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final String heroTag;
  final int initialIndex;

  const ProductImageGallery({
    super.key,
    required this.images,
    required this.heroTag,
    this.initialIndex = 0,
  });

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        _buildImagePageView(),
        if (widget.images.length > 1) _buildIndicator(),
        _buildImageCounter(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.h),
            Text(
              'No images',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePageView() {
    return GestureDetector(
      onTap: () => _openFullScreenGallery(),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Hero(
            tag: '${widget.heroTag}_$index',
            child: _buildImageItem(widget.images[index], index),
          );
        },
      ),
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: CachedProductImage(
        imageUrl: imageUrl,
        // Don't set heroTag here because there's already a Hero widget outside
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildIndicator() {
    return Positioned(
      bottom: 16.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCounter() {
    if (widget.images.length <= 1) return const SizedBox.shrink();

    return Positioned(
      top: 16.h,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          '${_currentIndex + 1}/${widget.images.length}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _openFullScreenGallery() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenImageGallery(
            images: widget.images,
            initialIndex: _currentIndex,
            heroTag: widget.heroTag,
            onPageChanged: (index) {
              // Sync the position with the main gallery
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroTag;
  final Function(int)? onPageChanged;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.heroTag,
    this.onPageChanged,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late TransformationController _transformationController;
  int _currentIndex = 0;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformationController = TransformationController();

    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final newIsZoomed = scale > 1.0;
    if (newIsZoomed != _isZoomed) {
      setState(() {
        _isZoomed = newIsZoomed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildImageViewer(),
          _buildTopBar(),
          if (widget.images.length > 1) _buildBottomIndicator(),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
        widget.onPageChanged?.call(index);

        // Reset zoom when changing pages
        _transformationController.value = Matrix4.identity();
      },
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0,
          maxScale: 4.0,
          child: Center(
            child: CachedProductImage(
              imageUrl: widget.images[index],
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              heroTag: '${widget.heroTag}_$index',
              placeholder: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              errorWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64.w, color: Colors.white54),
                    SizedBox(height: 16.h),
                    Text(
                      'Cannot load image',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close, color: Colors.white, size: 24.w),
            ),
            const Spacer(),
            Text(
              '${_currentIndex + 1} / ${widget.images.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
          top: 16.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isZoomed)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'Pinch to zoom out',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.images.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentIndex == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
