class ProductCategory {
  const ProductCategory({
    this.id,
    required this.name,
    this.slug,
  });

  final int? id;
  final String name;
  final String? slug;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: _intOrNull(json['id']),
      name: (json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
    );
  }

  static int? _intOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}

class ProductItem {
  const ProductItem({
    this.id,
    required this.name,
    this.slug,
    this.price,
    this.stock,
    this.isFeatured,
    this.thumbnailUrl,
    this.category,
  });

  final int? id;
  final String name;
  final String? slug;
  final double? price;
  final int? stock;
  final bool? isFeatured;
  final String? thumbnailUrl;
  final ProductCategory? category;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: ProductCategory._intOrNull(json['id']),
      name: (json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
      price: _doubleOrNull(json['price']),
      stock: ProductCategory._intOrNull(json['stock']),
      isFeatured: json['is_featured'] is bool ? json['is_featured'] as bool : null,
      thumbnailUrl: json['thumbnail_url']?.toString(),
      category: json['category'] is Map<String, dynamic>
          ? ProductCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  static double? _doubleOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}
