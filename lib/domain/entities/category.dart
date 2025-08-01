/// Domain entity representing a product category
///
/// This entity follows Clean Architecture principles and is framework-agnostic.
/// It contains only business logic and no external dependencies.
class Category {
  final int? id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this category with the given fields replaced with new values
  Category copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this category to a map for data persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a category from a map (typically from database or API)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, createdAt, updatedAt);
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
