import 'dart:convert';
import '../../domain/entities/product.dart';

/// Data model for Product entity
///
/// This model extends the domain entity and adds serialization capabilities
/// for API communication and data persistence.
class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.quantity,
    required super.categoryId,
    required super.images,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a ProductModel from a Product entity
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      quantity: product.quantity,
      categoryId: product.categoryId,
      images: product.images,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  /// Creates a ProductModel from JSON (API response)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      categoryId: json['categoryId'] as int,
      images: _parseImages(json['images']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Converts ProductModel to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a ProductModel from a map (database)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      categoryId: map['categoryId'] as int,
      images: _parseImages(map['images']),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  /// Converts ProductModel to map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'images': jsonEncode(images), // Serialize to JSON string for database
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields
  @override
  ProductModel copyWith({
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
    return ProductModel(
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
    if (imagesData == null) {
      return [];
    }

    if (imagesData is List) {
      // Direct list format (from API or memory)
      return List<String>.from(imagesData);
    } else if (imagesData is String) {
      try {
        // Try to decode as JSON string (for backward compatibility)
        final decoded = json.decode(imagesData);

        if (decoded is List) {
          return List<String>.from(decoded);
        } else {
          // Single string format (backward compatibility)
          return [imagesData];
        }
      } catch (e) {
        // If JSON decode fails, treat as single string
        return [imagesData];
      }
    }

    return [];
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
}
