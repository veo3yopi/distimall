class CategoryItem {
  const CategoryItem({
    this.id,
    required this.name,
    this.slug,
    this.iconUrl,
    this.productsCount,
  });

  final int? id;
  final String name;
  final String? slug;
  final String? iconUrl;
  final int? productsCount;

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: _intOrNull(json['id']),
      name: (json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
      productsCount: _intOrNull(json['products_count']),
      iconUrl: json['icon_url']?.toString(),
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
