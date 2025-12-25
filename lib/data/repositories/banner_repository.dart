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
        .map(_resolveImageUrl)
        .toList();
  }

  BannerItem _resolveImageUrl(BannerItem item) {
    final imageUrl = item.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return item;
    }
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      return item;
    }
    if (uri.isAbsolute) {
      if (uri.host == '127.0.0.1') {
        final base = Uri.parse(ApiConfig.baseUrl);
        final updated = uri.replace(
          host: base.host,
          port: base.hasPort ? base.port : uri.port,
          scheme: base.scheme,
        );
        return item.copyWith(imageUrl: updated.toString());
      }
      return item;
    }
    final base = Uri.parse(ApiConfig.baseUrl);
    final resolved = base.resolveUri(uri);
    return item.copyWith(imageUrl: resolved.toString());
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
