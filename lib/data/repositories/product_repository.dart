import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../models/product_item.dart';
import '../services/api_client.dart';

class ProductRepository {
  ProductRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<ProductItem>> fetchProducts() async {
    final payload = await apiClient.getList(ApiConfig.productsEndpoint);
    return payload
        .whereType<Map<String, dynamic>>()
        .map(ProductItem.fromJson)
        .toList();
  }

  Future<ProductItem> fetchProductDetail(int id) async {
    final payload =
        await apiClient.getMap('${ApiConfig.productsEndpoint}$id');
    return ProductItem.fromJson(payload);
  }

  static const List<ProductItem> dummyFeaturedProducts = [
    ProductItem(
      name: 'Maxi Dress Rayon',
      price: 2500,
      isFeatured: true,
      category: ProductCategory(name: 'Paket Katering Sehat'),
    ),
    ProductItem(
      name: 'Tas Rajut',
      price: 125000,
      isFeatured: true,
      category: ProductCategory(name: 'Handmade'),
    ),
    ProductItem(
      name: 'Herbal Syrup',
      price: 45000,
      isFeatured: true,
      category: ProductCategory(name: 'Kesehatan'),
    ),
    ProductItem(
      name: 'Tas Rajut Mini',
      price: 95000,
      isFeatured: true,
      category: ProductCategory(name: 'Limited'),
    ),
  ];
}
