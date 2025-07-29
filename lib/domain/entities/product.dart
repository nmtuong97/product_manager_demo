class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final int categoryId;
  final String images;
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'images': images,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      quantity: map['quantity'],
      categoryId: map['categoryId'],
      images: map['images'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}