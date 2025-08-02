import 'dart:convert';

class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final int categoryId;
  final List<String> images;
  final String createdAt;
  final String updatedAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.categoryId,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse images from various formats (List or single string)
  static List<String> _parseImages(dynamic imagesData) {
    print('🔍 Product._parseImages called:');
    print('   - Input data: $imagesData');
    print('   - Input type: ${imagesData.runtimeType}');
    
    if (imagesData == null) {
      print('   - Result: [] (null input)');
      return [];
    }
    
    if (imagesData is List) {
      // Direct list format (from API or memory)
      final result = List<String>.from(imagesData);
      print('   - Result: $result (direct list, length: ${result.length})');
      return result;
    } else if (imagesData is String) {
      try {
        // Try to decode as JSON string (for backward compatibility)
        final decoded = json.decode(imagesData);
        print('   - Decoded JSON: $decoded (type: ${decoded.runtimeType})');
        
        if (decoded is List) {
          final result = List<String>.from(decoded);
          print('   - Result: $result (from JSON list, length: ${result.length})');
          return result;
        } else {
          // Single string format (backward compatibility)
          print('   - Result: [$imagesData] (single string)');
          return [imagesData];
        }
      } catch (e) {
        // If JSON decode fails, treat as single string
        print('   - JSON decode failed: $e');
        print('   - Result: [$imagesData] (fallback single string)');
        return [imagesData];
      }
    }
    
    print('   - Result: [] (unknown type)');
    return [];
  }

  /// Get thumbnail image (first image in the list)
  String? get thumbnail => images.isNotEmpty ? images.first : null;

  /// Get images with maximum limit of 5
  List<String> get limitedImages => images.take(5).toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'images': jsonEncode(images), // Serialize to JSON string for database storage
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      categoryId: map['categoryId'],
      images: _parseImages(map['images']), // Handle both JSON string and List
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
