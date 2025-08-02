/// Utility class for generating product templates
///
/// This class provides predefined product templates organized by category
/// to support random product generation functionality.
class ProductTemplateGenerator {
  /// Private constructor to prevent instantiation
  ProductTemplateGenerator._();

  /// Product templates organized by category ID
  static const Map<int, List<Map<String, String>>> _productTemplates = {
    1: [
      // Electronics
      {'name': 'Smartphone', 'desc': 'Premium smart phone'},
      {'name': 'Laptop', 'desc': 'High-performance laptop'},
      {'name': 'Headphones', 'desc': 'Quality wireless headphones'},
      {'name': 'Tablet', 'desc': 'Versatile tablet for work'},
      {'name': 'Smartwatch', 'desc': 'Multi-function smart watch'},
      {'name': 'Camera', 'desc': 'Professional digital camera'},
      {
        'name': 'Bluetooth Speaker',
        'desc': 'Wireless speaker with vivid sound',
      },
      {'name': 'SSD Drive', 'desc': 'High-speed solid state drive'},
    ],
    2: [
      // Books
      {
        'name': 'Programming Book',
        'desc': 'Programming guide from basic to advanced',
      },
      {'name': 'Novel', 'desc': 'Best literary works'},
      {'name': 'Business Book', 'desc': 'Effective business strategies'},
      {
        'name': 'Children Book',
        'desc': 'Comics and educational books for children',
      },
      {'name': 'Self-help Book', 'desc': 'Personal development skills'},
      {'name': 'Cookbook', 'desc': 'Delicious and easy cooking recipes'},
      {'name': 'History Book', 'desc': 'Explore historical stories'},
      {'name': 'Science Book', 'desc': 'Popular science knowledge'},
    ],
    3: [
      // Fashion
      {'name': 'T-shirt', 'desc': 'Premium cotton t-shirt'},
      {'name': 'Jeans', 'desc': 'Fashionable jeans'},
      {'name': 'Sneakers', 'desc': 'Stylish sports shoes'},
      {'name': 'Handbag', 'desc': 'Women fashion handbag'},
      {'name': 'Jacket', 'desc': 'Youthful style jacket'},
      {'name': 'Evening Dress', 'desc': 'Elegant dress for parties'},
      {
        'name': 'Fashion Accessories',
        'desc': 'Beautiful jewelry and accessories',
      },
      {'name': 'High Heels', 'desc': 'Elegant high heel shoes'},
    ],
    4: [
      // Home Appliances
      {'name': 'Rice Cooker', 'desc': 'Smart electric rice cooker'},
      {'name': 'Blender', 'desc': 'Multi-purpose blender for family'},
      {'name': 'Dinnerware Set', 'desc': 'Premium porcelain dinnerware set'},
      {'name': 'Vacuum Cleaner', 'desc': 'Convenient cordless vacuum cleaner'},
      {'name': 'Microwave', 'desc': 'Multi-function microwave oven'},
      {
        'name': 'Mini Washing Machine',
        'desc': 'Compact energy-saving washing machine',
      },
      {'name': 'Steam Iron', 'desc': 'Steam technology iron'},
      {'name': 'Mini Fridge', 'desc': 'Mini fridge for office'},
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
  static Map<int, List<Map<String, String>>> get allTemplates =>
      _productTemplates;

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
