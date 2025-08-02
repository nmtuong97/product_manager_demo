# Image Cache Manager Guide

## Tổng quan

Dự án đã được tích hợp `flutter_cache_manager` để tối ưu hóa việc cache hình ảnh sản phẩm. Thay vì sử dụng `CachedNetworkImage` trực tiếp, chúng ta sử dụng `CachedProductImage` - một wrapper tùy chỉnh với cache manager riêng.

## Kiến trúc Cache

### ProductImageCacheManager

Class `ProductImageCacheManager` cung cấp:

- **Cache Duration**: 7 ngày
- **Max Objects**: 200 hình ảnh
- **Database**: SQLite local storage
- **Auto Cleanup**: Tự động xóa cache cũ

### CachedProductImage Widget

Widget tái sử dụng với các tính năng:

- Tự động sử dụng cache manager
- Placeholder và error widget nhất quán
- Hỗ trợ Hero animation
- Responsive design với ScreenUtil

## Cách sử dụng

### 1. Sử dụng CachedProductImage

```dart
CachedProductImage(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
  width: 200.w,
  height: 200.h,
  borderRadius: BorderRadius.circular(12.r),
  heroTag: 'product_123',
)
```

### 2. Sử dụng Extension Method

```dart
'https://example.com/image.jpg'.toCachedProductImage(
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(8.r),
)
```

### 3. Quản lý Cache

```dart
// Xóa toàn bộ cache
await ProductImageCacheManager.clearCache();

// Lấy kích thước cache
final size = await ProductImageCacheManager.getCacheSize();
final formattedSize = ProductImageCacheManager.formatCacheSize(size);
print('Cache size: $formattedSize');
```

## Tích hợp trong Components

### ProductCard

- Sử dụng `CachedProductImage` thay vì `CachedNetworkImage`
- Tự động cache thumbnail sản phẩm
- Hero animation cho chi tiết sản phẩm

### ProductImageGallery

- Cache tất cả hình ảnh trong gallery
- Hỗ trợ full-screen view với zoom
- Sync cache giữa thumbnail và full-screen

## Lợi ích

### Performance

- **Faster Loading**: Hình ảnh được cache local
- **Reduced Network**: Giảm bandwidth sử dụng
- **Better UX**: Không cần tải lại hình ảnh đã xem

### Memory Management

- **Auto Cleanup**: Tự động xóa cache cũ
- **Size Limit**: Giới hạn số lượng hình ảnh cache
- **Efficient Storage**: Sử dụng SQLite để quản lý metadata

### Developer Experience

- **Consistent API**: Interface thống nhất cho tất cả hình ảnh
- **Easy Integration**: Thay thế đơn giản cho CachedNetworkImage
- **Debugging**: Có thể monitor cache size và clear cache

## Best Practices

### 1. Sử dụng Hero Tags

```dart
// Trong ProductCard
heroTag: 'product_${product['id']}_0'

// Trong ProductImageGallery
heroTag: 'product_${product['id']}_$index'
```

### 2. Responsive Sizing

```dart
// Luôn sử dụng ScreenUtil
width: 100.w,
height: 100.h,
borderRadius: BorderRadius.circular(8.r),
```

### 3. Error Handling

```dart
// Cung cấp fallback cho hình ảnh lỗi
errorWidget: Container(
  color: Colors.grey[200],
  child: Icon(Icons.broken_image),
),
```

### 4. Cache Management

```dart
// Trong settings hoặc debug menu
TextButton(
  onPressed: () async {
    await ProductImageCacheManager.clearCache();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cache đã được xóa')),
    );
  },
  child: Text('Xóa Cache Hình Ảnh'),
)
```

## Troubleshooting

### Cache không hoạt động

1. Kiểm tra network connectivity
2. Verify image URLs are valid
3. Check cache permissions

### Memory issues

1. Reduce maxNrOfCacheObjects
2. Decrease stalePeriod
3. Call clearCache() periodically

### Performance issues

1. Use appropriate image sizes
2. Implement lazy loading
3. Monitor cache hit rate

## Migration từ CachedNetworkImage

### Before

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### After

```dart
CachedProductImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  // placeholder và errorWidget được handle tự động
)
```

## Configuration

Có thể tùy chỉnh cache settings trong `ProductImageCacheManager`:

```dart
static final CacheManager _cacheManager = CacheManager(
  Config(
    _cacheKey,
    stalePeriod: const Duration(days: 7), // Thay đổi thời gian cache
    maxNrOfCacheObjects: 200, // Thay đổi số lượng tối đa
    repo: JsonCacheInfoRepository(databaseName: _cacheKey),
    fileService: HttpFileService(),
  ),
);
```