import '../../config/api_config.dart';
import '../models/category_item.dart';
import '../services/api_client.dart';

class CategoryRepository {
  CategoryRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<CategoryItem>> fetchCategories() async {
    final payload = await apiClient.getList(ApiConfig.categoriesEndpoint);
    return payload
        .whereType<Map<String, dynamic>>()
        .map(CategoryItem.fromJson)
        .toList();
  }

  static const List<CategoryItem> dummyCategories = [
    CategoryItem(id: 1, name: 'Makanan'),
    CategoryItem(id: 2, name: 'Pakaian'),
    CategoryItem(id: 3, name: 'Kesehatan'),
    CategoryItem(id: 4, name: 'Kecantikan'),
    CategoryItem(id: 5, name: 'Craft'),
    CategoryItem(id: 6, name: 'Laundry'),
    CategoryItem(id: 7, name: 'Cellular'),
  ];
}
