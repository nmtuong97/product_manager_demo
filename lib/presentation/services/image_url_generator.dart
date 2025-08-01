/// Service for generating sample image URLs for products
class ImageUrlGenerator {
  static const List<String> _sampleImageUrls = [
    'https://picsum.photos/400/300?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/400/300?random=3',
    'https://picsum.photos/400/300?random=4',
    'https://picsum.photos/400/300?random=5',
    'https://picsum.photos/400/300?random=6',
    'https://picsum.photos/400/300?random=7',
    'https://picsum.photos/400/300?random=8',
    'https://picsum.photos/400/300?random=9',
    'https://picsum.photos/400/300?random=10',
  ];

  /// Generate a random sample image URL
  static String generateSampleImageUrl() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _sampleImageUrls.length;
    return _sampleImageUrls[random];
  }

  /// Generate multiple sample image URLs
  static List<String> generateMultipleSampleImageUrls(int count) {
    final List<String> urls = [];
    for (int i = 0; i < count; i++) {
      final random =
          (DateTime.now().millisecondsSinceEpoch + i) % _sampleImageUrls.length;
      urls.add(_sampleImageUrls[random]);
    }
    return urls;
  }

  /// Generate image URL based on product name for consistency
  static String generateImageUrlForProduct(String productName) {
    final hash = productName.hashCode.abs();
    final index = hash % _sampleImageUrls.length;
    return _sampleImageUrls[index];
  }
}
