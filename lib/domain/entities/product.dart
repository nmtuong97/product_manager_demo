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

  /// Parse images from various formats (JSON string, List, or single string)
  static List<String> _parseImages(dynamic imagesData) {

    
    if (imagesData == null) {

      return [];
    }
    
    if (imagesData is List) {
      // Direct list format (from API or memory)
      return List<String>.from(imagesData);
    } else if (imagesData is String) {
      try {
        // Try to decode as JSON string (from database)
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

  /// Get thumbnail image (first image in the list)
  String? get thumbnail => images.isNotEmpty ? images.first : null;

  /// Get images with maximum limit of 5
  List<String> get limitedImages => images.take(5).toList();

  Map<String, dynamic> toMap() {
    final encodedImages = json.encode(images);
    
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'images': encodedImages, // Serialize to JSON string for SQLite
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
