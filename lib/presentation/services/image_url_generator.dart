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

  /// Generate list of image URLs for product (max 5 images)
  static List<String> generateImageListForProduct(
    String productName, {
    int count = 1,
  }) {
    final hash = productName.hashCode.abs();
    final List<String> imageList = [];
    final maxCount = count > 5 ? 5 : count; // Limit to maximum 5 images

    // Ensure we generate unique URLs by adding timestamp for uniqueness
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < maxCount; i++) {
      final index = (hash + i + timestamp) % _sampleImageUrls.length;
      final uniqueUrl = '${_sampleImageUrls[index]}&t=${timestamp + i}';
      imageList.add(uniqueUrl);
    }

    return imageList;
  }
}
