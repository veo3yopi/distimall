import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../models/banner_item.dart';
import '../services/api_client.dart';

class BannerRepository {
  BannerRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<BannerItem>> fetchBanners() async {
    final payload = await apiClient.getList(ApiConfig.bannersEndpoint);
    return payload
        .whereType<Map<String, dynamic>>()
        .map(BannerItem.fromJson)
        .toList();
  }

  static const List<BannerItem> dummyBanners = [
    BannerItem(
      title: 'KOLESI\nLEBARAN\n50%',
      subtitle: 'Diskon Terbatas',
      backgroundColor: Color(0xFFD9B7AA),
    ),
    BannerItem(
      title: 'MAKANAN\nSEHAT\nDISKON 10%',
      subtitle: 'Fresh & Halal',
      backgroundColor: Color(0xFFCE9B6B),
    ),
    BannerItem(
      title: 'DISTY\nCELLULAR',
      subtitle: 'Gadget Terbaru',
      backgroundColor: Color(0xFF7DA283),
    ),
  ];
}
