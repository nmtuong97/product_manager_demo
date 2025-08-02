/// Utility class for generating product templates
///
/// This class provides predefined product templates organized by category
/// to support random product generation functionality.
class ProductTemplateGenerator {
  /// Private constructor to prevent instantiation
  ProductTemplateGenerator._();

  /// Product templates organized by category ID
  static const Map<int, List<Map<String, String>>> _productTemplates = {
    1: [ // Điện tử
      {'name': 'Smartphone', 'desc': 'Điện thoại thông minh cao cấp'},
      {'name': 'Laptop', 'desc': 'Máy tính xách tay hiệu năng cao'},
      {'name': 'Tai nghe', 'desc': 'Tai nghe không dây chất lượng'},
      {'name': 'Máy tính bảng', 'desc': 'Tablet đa năng cho công việc'},
      {'name': 'Smartwatch', 'desc': 'Đồng hồ thông minh đa tính năng'},
      {'name': 'Camera', 'desc': 'Máy ảnh kỹ thuật số chuyên nghiệp'},
      {'name': 'Loa Bluetooth', 'desc': 'Loa không dây âm thanh sống động'},
      {'name': 'Ổ cứng SSD', 'desc': 'Ổ cứng thể rắn tốc độ cao'},
    ],
    2: [ // Sách
      {'name': 'Sách lập trình', 'desc': 'Hướng dẫn lập trình từ cơ bản đến nâng cao'},
      {'name': 'Tiểu thuyết', 'desc': 'Tác phẩm văn học hay nhất'},
      {'name': 'Sách kinh doanh', 'desc': 'Chiến lược kinh doanh hiệu quả'},
      {'name': 'Sách thiếu nhi', 'desc': 'Truyện tranh và sách giáo dục cho trẻ'},
      {'name': 'Sách tự học', 'desc': 'Kỹ năng phát triển bản thân'},
      {'name': 'Sách nấu ăn', 'desc': 'Công thức món ngon dễ làm'},
      {'name': 'Sách lịch sử', 'desc': 'Khám phá những câu chuyện lịch sử'},
      {'name': 'Sách khoa học', 'desc': 'Kiến thức khoa học phổ thông'},
    ],
    3: [ // Thời trang
      {'name': 'Áo thun', 'desc': 'Áo thun cotton cao cấp'},
      {'name': 'Quần jeans', 'desc': 'Quần jeans thời trang'},
      {'name': 'Giày sneaker', 'desc': 'Giày thể thao phong cách'},
      {'name': 'Túi xách', 'desc': 'Túi xách thời trang nữ'},
      {'name': 'Áo khoác', 'desc': 'Áo khoác phong cách trẻ trung'},
      {'name': 'Đầm dự tiệc', 'desc': 'Váy đầm sang trọng cho buổi tiệc'},
      {'name': 'Phụ kiện thời trang', 'desc': 'Trang sức và phụ kiện đẹp'},
      {'name': 'Giày cao gót', 'desc': 'Giày cao gót thanh lịch'},
    ],
    4: [ // Gia dụng
      {'name': 'Nồi cơm điện', 'desc': 'Nồi cơm điện thông minh'},
      {'name': 'Máy xay sinh tố', 'desc': 'Máy xay đa năng cho gia đình'},
      {'name': 'Bộ chén đĩa', 'desc': 'Bộ chén đĩa sứ cao cấp'},
      {'name': 'Máy hút bụi', 'desc': 'Máy hút bụi không dây tiện lợi'},
      {'name': 'Lò vi sóng', 'desc': 'Lò vi sóng đa chức năng'},
      {'name': 'Máy giặt mini', 'desc': 'Máy giặt nhỏ gọn tiết kiệm'},
      {'name': 'Bàn ủi hơi nước', 'desc': 'Bàn ủi công nghệ hơi nước'},
      {'name': 'Tủ lạnh mini', 'desc': 'Tủ lạnh mini cho văn phòng'},
    ],
  };

  /// Get all available category IDs
  static List<int> get availableCategoryIds => _productTemplates.keys.toList();

  /// Get product templates for a specific category
  ///
  /// [categoryId] The category ID to get templates for
  /// Returns a list of product templates or empty list if category not found
  static List<Map<String, String>> getTemplatesForCategory(int categoryId) {
    return _productTemplates[categoryId] ?? [];
  }

  /// Get all product templates
  static Map<int, List<Map<String, String>>> get allTemplates => _productTemplates;

  /// Check if a category has templates
  ///
  /// [categoryId] The category ID to check
  /// Returns true if the category has templates, false otherwise
  static bool hasCategoryTemplates(int categoryId) {
    return _productTemplates.containsKey(categoryId) && 
           _productTemplates[categoryId]!.isNotEmpty;
  }

  /// Get total number of templates across all categories
  static int get totalTemplateCount {
    return _productTemplates.values
        .map((templates) => templates.length)
        .fold(0, (sum, count) => sum + count);
  }
}