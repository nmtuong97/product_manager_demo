import 'dart:convert';

/// Domain entity representing a product
///
/// This entity follows Clean Architecture principles and is framework-agnostic.
/// It contains only business logic and no external dependencies.
class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final int categoryId;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  /// Creates a copy of this product with the given fields replaced with new values
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    int? categoryId,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
          print(
            '   - Result: $result (from JSON list, length: ${result.length})',
          );
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

  /// Converts this product to a map for data persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'images': jsonEncode(
        images,
      ), // Serialize to JSON string for database storage
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a product from a map (typically from database or API)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      categoryId: map['categoryId'],
      images: _parseImages(map['images']), // Handle both JSON string and List
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  /// Safely parses DateTime from various input types
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // If parsing fails, return current time as fallback
        return DateTime.now();
      }
    }
    
    // For any other type, return current time as fallback
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.quantity == quantity &&
        other.categoryId == categoryId &&
        other.images.length == images.length &&
        other.images.every((element) => images.contains(element)) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      price,
      quantity,
      categoryId,
      Object.hashAll(images),
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, price: $price, quantity: $quantity, categoryId: $categoryId, images: $images, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
