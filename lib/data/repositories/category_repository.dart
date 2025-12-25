import 'package:flutter/material.dart';

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
    CategoryItem(name: 'Makanan'),
    CategoryItem(name: 'Pakaian'),
    CategoryItem(name: 'Kesehatan'),
    CategoryItem(name: 'Kecantikan'),
    CategoryItem(name: 'Craft'),
    CategoryItem(name: 'Laundry'),
    CategoryItem(name: 'Cellular'),
  ];
}
